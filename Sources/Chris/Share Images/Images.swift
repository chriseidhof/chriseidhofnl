import Foundation
import SwiftUI

let logo: Image = {
    let url = Bundle.module.url(forResource: "logo", withExtension: "pdf")!
    let img = NSImage(contentsOf: url)!
    return Image(nsImage: img)
}()

struct DefaultShareImageContents<Title: View, Subtitle: View>: View {
    @ViewBuilder var title: Title
    @ViewBuilder var subtitle: Subtitle

    var body: some View {
        VStack(alignment: .leading) {
            title
                .font(.system(size: 100))
                .minimumScaleFactor(0.3)
            subtitle
                .minimumScaleFactor(0.3)
                .font(.system(size: 70, design: .rounded))
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
            .overlay {
                contents
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .padding(.bottom, 100)
                    .padding(100)
            }
            .overlay(alignment: .bottom) {
                Text("Chris Eidhof")
                    .font(.system(size: 50))
                    .frame(height: 100)
                    .padding(50)
            }
            .frame(width: 1200, height: 630)
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
