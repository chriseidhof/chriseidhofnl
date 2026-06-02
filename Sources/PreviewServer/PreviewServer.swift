import Darwin
import Foundation

struct Configuration {
    var port: UInt16 = 8000
    var directory = "docs"
    var watch = true
    var watchPath = "site/posts"

    init(arguments: [String]) throws {
        var index = 1
        while index < arguments.count {
            switch arguments[index] {
            case "--port", "-p":
                index += 1
                guard index < arguments.count, let value = UInt16(arguments[index]) else {
                    throw ServerError.invalidArguments("Expected a port after \(arguments[index - 1])")
                }
                port = value
            case "--directory", "-d":
                index += 1
                guard index < arguments.count else {
                    throw ServerError.invalidArguments("Expected a directory after \(arguments[index - 1])")
                }
                directory = arguments[index]
            case "--watch":
                index += 1
                guard index < arguments.count else {
                    throw ServerError.invalidArguments("Expected a path after \(arguments[index - 1])")
                }
                watch = true
                watchPath = arguments[index]
            case "--no-watch":
                watch = false
            case "--help", "-h":
                throw ServerError.help
            default:
                throw ServerError.invalidArguments("Unknown argument: \(arguments[index])")
            }
            index += 1
        }
    }
}

enum ServerError: Error, CustomStringConvertible {
    case help
    case invalidArguments(String)
    case missingDirectory(String)
    case missingPackageRoot
    case socket(String)

    var description: String {
        switch self {
        case .help:
            return """
            Usage: PreviewServer [--port 8000] [--directory docs] [--watch site/posts] [--no-watch]

            Serves the generated site from the docs directory and rebuilds when site/posts changes.
            """
        case let .invalidArguments(message):
            return "\(message)\n\nUsage: PreviewServer [--port 8000] [--directory docs] [--watch site/posts] [--no-watch]"
        case let .missingDirectory(path):
            return "Could not find directory: \(path)"
        case .missingPackageRoot:
            return "Could not find Package.swift"
        case let .socket(message):
            return message
        }
    }
}

@main
struct PreviewServer {
    static func main() {
        do {
            signal(SIGPIPE, SIG_IGN)

            let configuration = try Configuration(arguments: CommandLine.arguments)
            let root = try siteRoot(for: configuration.directory)
            let server = try StaticServer(root: root, port: configuration.port)
            let watcher = configuration.watch
                ? try SiteWatcher(packageRoot: try packageRoot(), watchPath: configuration.watchPath)
                : nil

            watcher?.start()

            try server.run()
        } catch ServerError.help {
            print(ServerError.help.description)
        } catch {
            fputs("\(error)\n", stderr)
            exit(EXIT_FAILURE)
        }
    }

    static func siteRoot(for directory: String) throws -> URL {
        let fileManager = FileManager.default
        let directoryURL = URL(fileURLWithPath: directory, relativeTo: URL(fileURLWithPath: fileManager.currentDirectoryPath))
            .standardizedFileURL

        if isDirectory(directoryURL) {
            return directoryURL
        }

        let sourceFile = URL(fileURLWithPath: #filePath).deletingLastPathComponent()
        if let packageRoot = findPackageRoot(startingAt: sourceFile) {
            let url = packageRoot.appendingPathComponent(directory).standardizedFileURL
            if isDirectory(url) {
                return url
            }
        }

        if let packageRoot = findPackageRoot(startingAt: URL(fileURLWithPath: fileManager.currentDirectoryPath)) {
            let url = packageRoot.appendingPathComponent(directory).standardizedFileURL
            if isDirectory(url) {
                return url
            }
        }

        let executable = URL(fileURLWithPath: CommandLine.arguments[0]).standardizedFileURL
        if let packageRoot = findPackageRoot(startingAt: executable.deletingLastPathComponent()) {
            let url = packageRoot.appendingPathComponent(directory).standardizedFileURL
            if isDirectory(url) {
                return url
            }
        }

        throw ServerError.missingDirectory(directory)
    }

    static func packageRoot() throws -> URL {
        let fileManager = FileManager.default
        let sourceFile = URL(fileURLWithPath: #filePath).deletingLastPathComponent()
        if let packageRoot = findPackageRoot(startingAt: sourceFile) {
            return packageRoot
        }

        if let packageRoot = findPackageRoot(startingAt: URL(fileURLWithPath: fileManager.currentDirectoryPath)) {
            return packageRoot
        }

        let executable = URL(fileURLWithPath: CommandLine.arguments[0]).standardizedFileURL
        if let packageRoot = findPackageRoot(startingAt: executable.deletingLastPathComponent()) {
            return packageRoot
        }

        throw ServerError.missingPackageRoot
    }

    static func findPackageRoot(startingAt url: URL) -> URL? {
        var candidate = url.standardizedFileURL
        while true {
            let packageFile = candidate.appendingPathComponent("Package.swift")
            if FileManager.default.fileExists(atPath: packageFile.path) {
                return candidate
            }

            let parent = candidate.deletingLastPathComponent()
            if parent.path == candidate.path {
                return nil
            }
            candidate = parent
        }
    }

    static func isDirectory(_ url: URL) -> Bool {
        var isDirectory: ObjCBool = false
        return FileManager.default.fileExists(atPath: url.path, isDirectory: &isDirectory) && isDirectory.boolValue
    }
}

final class SiteWatcher {
    let packageRoot: URL
    let watchURL: URL
    let queue = DispatchQueue(label: "PreviewServer.SiteWatcher")
    var timer: DispatchSourceTimer?
    var snapshot: [String: Date] = [:]
    var rebuilding = false

    init(packageRoot: URL, watchPath: String) throws {
        self.packageRoot = packageRoot.standardizedFileURL
        self.watchURL = URL(fileURLWithPath: watchPath, relativeTo: packageRoot).standardizedFileURL

        guard PreviewServer.isDirectory(watchURL) else {
            throw ServerError.missingDirectory(watchURL.path)
        }
    }

    deinit {
        timer?.cancel()
    }

    func start() {
        snapshot = currentSnapshot()

        let timer = DispatchSource.makeTimerSource(queue: queue)
        timer.schedule(deadline: .now() + .seconds(1), repeating: .seconds(1))
        timer.setEventHandler { [weak self] in
            self?.checkForChanges()
        }
        timer.resume()

        self.timer = timer
        print("Watching \(watchURL.path)")
    }

    func currentSnapshot() -> [String: Date] {
        let fileManager = FileManager.default
        let urls = (try? fileManager.contentsOfDirectory(
            at: watchURL,
            includingPropertiesForKeys: [.isRegularFileKey, .contentModificationDateKey],
            options: [.skipsHiddenFiles]
        )) ?? []

        var result: [String: Date] = [:]
        for url in urls {
            let values = try? url.resourceValues(forKeys: [.isRegularFileKey, .contentModificationDateKey])
            guard values?.isRegularFile == true else {
                continue
            }

            result[url.path] = values?.contentModificationDate ?? .distantPast
        }
        return result
    }

    func checkForChanges() {
        guard !rebuilding else {
            return
        }

        let latest = currentSnapshot()
        guard latest != snapshot else {
            return
        }

        snapshot = latest
        rebuild()
    }

    func rebuild() {
        if rebuilding {
            return
        }

        rebuilding = true

        DispatchQueue.global().async {
            print("Rebuilding site...")
            let process = Process()
            process.executableURL = URL(fileURLWithPath: "/usr/bin/xcrun")
            process.arguments = ["swift", "run", "Website"]
            process.currentDirectoryURL = self.packageRoot

            do {
                try process.run()
                process.waitUntilExit()

                if process.terminationStatus == 0 {
                    print("Finished rebuilding site.")
                } else {
                    fputs("Site rebuild failed with status \(process.terminationStatus)\n", stderr)
                }
            } catch {
                fputs("Could not rebuild site: \(error)\n", stderr)
            }

            self.queue.async {
                self.snapshot = self.currentSnapshot()
                self.rebuilding = false
            }
        }
    }
}

final class StaticServer {
    let root: URL
    let port: UInt16

    init(root: URL, port: UInt16) throws {
        self.root = root.standardizedFileURL
        self.port = port
    }

    func run() throws {
        let sockets = try makeServerSockets()
        defer { sockets.forEach { close($0) } }

        print("Serving \(root.path)")
        print("Open http://localhost:\(port)/")

        for serverSocket in sockets.dropFirst() {
            DispatchQueue.global().async {
                self.acceptConnections(on: serverSocket)
            }
        }

        acceptConnections(on: sockets[0])
    }

    func acceptConnections(on serverSocket: Int32) {
        while true {
            let clientSocket = accept(serverSocket, nil, nil)
            guard clientSocket >= 0 else {
                continue
            }
            handle(clientSocket: clientSocket)
            close(clientSocket)
        }
    }

    func makeServerSockets() throws -> [Int32] {
        var sockets: [Int32] = []
        do {
            sockets.append(try makeIPv6Socket())
            sockets.append(try makeIPv4Socket())
            return sockets
        } catch {
            sockets.forEach { close($0) }
            throw error
        }
    }

    func configure(_ serverSocket: Int32) throws {
        var enabled: Int32 = 1
        guard setsockopt(serverSocket, SOL_SOCKET, SO_REUSEADDR, &enabled, socklen_t(MemoryLayout<Int32>.size)) == 0 else {
            throw ServerError.socket("Could not configure socket")
        }
    }

    func makeIPv4Socket() throws -> Int32 {
        let serverSocket = socket(AF_INET, SOCK_STREAM, 0)
        guard serverSocket >= 0 else {
            throw ServerError.socket("Could not create IPv4 socket")
        }

        do {
            try configure(serverSocket)

            var address = sockaddr_in(
                sin_len: UInt8(MemoryLayout<sockaddr_in>.size),
                sin_family: sa_family_t(AF_INET),
                sin_port: port.bigEndian,
                sin_addr: in_addr(s_addr: inet_addr("127.0.0.1")),
                sin_zero: (0, 0, 0, 0, 0, 0, 0, 0)
            )

            let bindResult = withUnsafePointer(to: &address) { pointer in
                pointer.withMemoryRebound(to: sockaddr.self, capacity: 1) { rebound in
                    bind(serverSocket, rebound, socklen_t(MemoryLayout<sockaddr_in>.size))
                }
            }
            guard bindResult == 0 else {
                throw ServerError.socket("Could not bind to 127.0.0.1:\(port)")
            }

            guard listen(serverSocket, SOMAXCONN) == 0 else {
                throw ServerError.socket("Could not listen on 127.0.0.1:\(port)")
            }

            return serverSocket
        } catch {
            close(serverSocket)
            throw error
        }
    }

    func makeIPv6Socket() throws -> Int32 {
        let serverSocket = socket(AF_INET6, SOCK_STREAM, 0)
        guard serverSocket >= 0 else {
            throw ServerError.socket("Could not create IPv6 socket")
        }

        do {
            try configure(serverSocket)

            var v6Only: Int32 = 1
            guard setsockopt(serverSocket, IPPROTO_IPV6, IPV6_V6ONLY, &v6Only, socklen_t(MemoryLayout<Int32>.size)) == 0 else {
                throw ServerError.socket("Could not configure IPv6 socket")
            }

            var address = sockaddr_in6()
            address.sin6_len = UInt8(MemoryLayout<sockaddr_in6>.size)
            address.sin6_family = sa_family_t(AF_INET6)
            address.sin6_port = port.bigEndian
            address.sin6_addr = in6addr_loopback

            let bindResult = withUnsafePointer(to: &address) { pointer in
                pointer.withMemoryRebound(to: sockaddr.self, capacity: 1) { rebound in
                    bind(serverSocket, rebound, socklen_t(MemoryLayout<sockaddr_in6>.size))
                }
            }
            guard bindResult == 0 else {
                throw ServerError.socket("Could not bind to [::1]:\(port)")
            }

            guard listen(serverSocket, SOMAXCONN) == 0 else {
                throw ServerError.socket("Could not listen on [::1]:\(port)")
            }

            return serverSocket
        } catch {
            close(serverSocket)
            throw error
        }
    }

    func handle(clientSocket: Int32) {
        var buffer = [UInt8](repeating: 0, count: 16 * 1024)
        let bytesRead = recv(clientSocket, &buffer, buffer.count, 0)
        guard bytesRead > 0 else {
            return
        }

        let request = String(decoding: buffer.prefix(bytesRead), as: UTF8.self)
        guard let firstLine = request.split(separator: "\r\n", maxSplits: 1, omittingEmptySubsequences: false).first else {
            sendResponse(status: "400 Bad Request", body: Data("Bad Request".utf8), contentType: "text/plain", to: clientSocket)
            return
        }

        let parts = firstLine.split(separator: " ")
        guard parts.count >= 2, parts[0] == "GET" || parts[0] == "HEAD" else {
            sendResponse(status: "405 Method Not Allowed", body: Data("Method Not Allowed".utf8), contentType: "text/plain", to: clientSocket)
            return
        }

        let includeBody = parts[0] == "GET"
        serve(path: String(parts[1]), includeBody: includeBody, to: clientSocket)
    }

    func serve(path requestPath: String, includeBody: Bool, to clientSocket: Int32) {
        guard let fileURL = fileURL(for: requestPath) else {
            sendResponse(status: "403 Forbidden", body: Data("Forbidden".utf8), contentType: "text/plain", to: clientSocket)
            return
        }

        var isDirectory: ObjCBool = false
        if FileManager.default.fileExists(atPath: fileURL.path, isDirectory: &isDirectory) {
            let resolvedURL = isDirectory.boolValue ? fileURL.appendingPathComponent("index.html") : fileURL
            if let data = try? Data(contentsOf: resolvedURL) {
                sendResponse(
                    status: "200 OK",
                    body: data,
                    contentType: contentType(for: resolvedURL),
                    includeBody: includeBody,
                    to: clientSocket
                )
                return
            }
        }

        sendResponse(status: "404 Not Found", body: Data("Not Found".utf8), contentType: "text/plain", to: clientSocket)
    }

    func fileURL(for requestPath: String) -> URL? {
        let pathWithoutQuery = requestPath.split(separator: "?", maxSplits: 1, omittingEmptySubsequences: false).first.map(String.init) ?? "/"
        let decodedPath = pathWithoutQuery.removingPercentEncoding ?? pathWithoutQuery
        let components = decodedPath.split(separator: "/").map(String.init)

        guard !components.contains("..") else {
            return nil
        }

        let relativePath = components.filter { !$0.isEmpty && $0 != "." }.joined(separator: "/")
        let candidate = relativePath.isEmpty
            ? root
            : root.appendingPathComponent(relativePath)
        let standardized = candidate.standardizedFileURL

        guard standardized.path == root.path || standardized.path.hasPrefix(root.path + "/") else {
            return nil
        }
        return standardized
    }

    func sendResponse(
        status: String,
        body: Data,
        contentType: String,
        includeBody: Bool = true,
        to clientSocket: Int32
    ) {
        let headers = """
        HTTP/1.1 \(status)\r
        Content-Length: \(body.count)\r
        Content-Type: \(contentType)\r
        Connection: close\r
        \r

        """

        sendAll(Data(headers.utf8), to: clientSocket)
        if includeBody {
            sendAll(body, to: clientSocket)
        }
    }

    func sendAll(_ data: Data, to clientSocket: Int32) {
        data.withUnsafeBytes { rawBuffer in
            guard let baseAddress = rawBuffer.baseAddress else {
                return
            }

            var sent = 0
            while sent < data.count {
                let result = send(clientSocket, baseAddress.advanced(by: sent), data.count - sent, 0)
                if result <= 0 {
                    return
                }
                sent += result
            }
        }
    }

    func contentType(for url: URL) -> String {
        switch url.pathExtension.lowercased() {
        case "html", "htm": return "text/html; charset=utf-8"
        case "css": return "text/css; charset=utf-8"
        case "js": return "text/javascript; charset=utf-8"
        case "json": return "application/json; charset=utf-8"
        case "xml": return "application/xml; charset=utf-8"
        case "txt": return "text/plain; charset=utf-8"
        case "png": return "image/png"
        case "jpg", "jpeg": return "image/jpeg"
        case "gif": return "image/gif"
        case "svg": return "image/svg+xml"
        case "ico": return "image/x-icon"
        case "pdf": return "application/pdf"
        case "mp4": return "video/mp4"
        case "webm": return "video/webm"
        case "woff": return "font/woff"
        case "woff2": return "font/woff2"
        default: return "application/octet-stream"
        }
    }
}
