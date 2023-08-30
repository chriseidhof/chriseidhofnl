import SwiftUI

@MainActor
extension View {
    public func render(size: ProposedViewSize, background: Bool = true, colorScheme: ColorScheme = .dark) -> Data {
        let view = self
            .padding()
            .background {
                if background {
                    Rectangle()
                        .fill(.background)
                }
            }
            .colorScheme(colorScheme)
            .preferredColorScheme(colorScheme)
        let renderer = ImageRenderer(content: view)
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

