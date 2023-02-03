import Helpers
import SwiftUI
import StaticSite

struct Buttons: Rule {
    var body: some Rule {
        /*
         Facets:

         - Light/Dark
         - Dynamic Type
         - Accessibility
         - Pressed/Depressed
         - Disabled?
         */
        EmptyRule()
    }
}

protocol Sample: View {
    var code: String { get }

}

extension Sample {
    var any: AnySample {
        AnySample(view: AnyView(self), code: code)
    }
}

struct AnySample {
    var view: AnyView
    var code: String
}

fileprivate let all: [AnySample] {
    PlainButton().any
}

struct PlainButton: Sample {
    var code: String {
        """
        Button("My Button", action: {})
        """
    }

    var body: some View {
        Button("My Button", action: {})
    }
}

