import SwiftUI
import HTML

extension BlogPost {
    @MainActor
    var images: [Data] {
        switch body {
        case .markdown: return []
        case .pieces(let p):
            return p.compactMap {
                guard case let .swiftUI(view, size) = $0 else { return nil }
                return view.render(size: size)
            }
        }
    }
}

@MainActor
extension View {
    func render(size: ProposedViewSize) -> Data {
        let renderer = ImageRenderer(content: self)
        renderer.scale = 2
        renderer.proposedSize = size
        return renderer.cgImage!.png!
    }
}

extension CGImage {
    var png: Data? {
        let data = NSMutableData()
        guard let destination = CGImageDestinationCreateWithData(data, kUTTypePNG, 1, nil) else { return nil }
        CGImageDestinationAddImage(destination, self, nil)
        guard CGImageDestinationFinalize(destination) else { return nil }
        return data as Data
    }
}

