import StaticSite
import Helpers
import SwiftUI
import HTML

struct SwiftUIView<V: View>: PostPiece {
    var size: ProposedViewSize = .unspecified
    var background: Bool = true
    @ViewBuilder var view: V

    func render(state: inout FState, id: Int, prefix: String) -> Node {
        p {
            picture(class: "swiftui") {
                source(media: "(prefers-color-scheme: dark)", srcset: prefix + "/\(id)-dark.png 2x")
                img(srcset: prefix + "/\(id).png 2x", style: "width: auto;")
            }
        }
    }

    func generateImages(id: Int) -> some Rule {
        Write(outputName: "\(id).png", data: view.render(size: size, background: background, colorScheme: .light))
        Write(outputName: "\(id)-dark.png", data: view.render(size: size, background: background, colorScheme: .dark))
    }
}
