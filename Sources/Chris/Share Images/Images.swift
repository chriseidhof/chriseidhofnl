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
//    @Environment(\.st)

    var body: some View {
        VStack(alignment: .leading) {
            title
                .font(.system(size: 100, design: .rounded))
                .minimumScaleFactor(0.3)
            subtitle
                .minimumScaleFactor(0.3)
                .font(.system(size: 60, weight: .light, design: .default))
        }
    }
}

extension Color {
    static let accentBlue = Color(red: 0, green: 122/255.0, blue: 1)
}

struct ShareImage<Contents: View>: View {
    init(@ViewBuilder contents: () -> Contents) {
        self.contents = contents()
    }

    var contents: Contents

    var theLogo: some View {
        logo.resizable()
            .renderingMode(.template)
            .scaledToFit()
            .frame(height: 60)
            .opacity(0.5)
            .foregroundStyle(.white)
            .blendMode(.screen)
    }

    var body: some View {
        Rectangle()
            .fill(Color.cyan.gradient)
            .overlay {
                    Color.clear.overlay {
                        VStack(alignment: .leading) {
                            contents
                                .frame(maxHeight: .infinity)
                                .overlay(alignment: .topLeading) {
                                    theLogo
                                }
                        }
                            .bold()
                                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                        }
                    .foregroundStyle(.white)
                    .padding(80)
            }
            .frame(idealWidth: shareImageSize.width, idealHeight: shareImageSize.height)
    }
}

let shareImageSize = CGSize(width: 1200, height: 630)

struct ShareImage_Previews: PreviewProvider {
    static var previews: some View {
        let result = ShareImage {
            DefaultShareImageContents(title: { Text("This is my title") }, subtitle: { Text("This is the subtitle") })
        }
//        result.colorScheme(.dark)
        result.colorScheme(.light)
            .scaleEffect(0.5)
            .frame(width: 1200*0.5, height: 630*0.5)

        ShareImage {
            DefaultShareImageContents(title: {
                Text("Accessing an API using CoreData's NSIncrementalStore")
            }, subtitle: {
                EmptyView()

            })
        }
    }
}
