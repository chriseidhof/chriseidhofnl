import Foundation
import SwiftUI

let logo: Image = {
    let img = NSImage(contentsOf: .homeDirectory.appending(path: "Sites/chriseidhofnl/Sources/Chris/Share Images/logo.pdf"))!
    return Image(nsImage: img)
}()

struct DefaultShareImageContents<Title: View, Subtitle: View>: View {
    @ViewBuilder var title: Title
    @ViewBuilder var subtitle: Subtitle

    var body: some View {
        VStack(alignment: .leading) {
            title
                .font(.custom("Concourse 4", size: 100))
                .minimumScaleFactor(0.3)
            subtitle
                .minimumScaleFactor(0.3)
                .font(.custom("Concourse 4", size: 70))
                .foregroundColor(.secondary)
        }
    }
}

struct ShareImage<Contents: View>: View {
    init(@ViewBuilder contents: () -> Contents) {
        self.contents = contents()
    }

    var contents: Contents

    var body: some View {
        Rectangle()
            .fill(.background)
            .frame(width: 1200, height: 630)
            .overlay {
                contents
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .padding(.bottom, 100)
                    .padding(100)
            }
            .overlay(alignment: .bottom) {
                logo
                    .renderingMode(.template)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(height: 100)
                    .padding(50)
                    .opacity(0.1)
            }
//            .colorScheme(.dark)
    }
}

struct ShareImage_Previews: PreviewProvider {
    static var previews: some View {
        let result = ShareImage {
            DefaultShareImageContents(title: { Text("This is my title") }, subtitle: { Text("This is the subtitle") })
        }
        result.colorScheme(.dark)
        result.colorScheme(.light)

        ShareImage {
            DefaultShareImageContents(title: {
                Text("Accessing an API using CoreData's NSIncrementalStore")
            }, subtitle: {
                EmptyView()

            })
        }
    }
}
