import Foundation
import StaticSite
import Swim

struct OpenGraphImage: EnvironmentKey {
    static var defaultValue: String? = nil
}

struct ExtraFooterContent: EnvironmentKey {
    static var defaultValue: Node? = nil
}

extension EnvironmentValues {
    public var openGraphImage: String? {
        get { self[OpenGraphImage.self] }
        set { self[OpenGraphImage.self] = newValue }
    }

    public var extraFooterContent: Node? {
        get { self[ExtraFooterContent.self] }
        set { self[ExtraFooterContent.self] = newValue }
    }
}

extension Rule {
    public func extraFooterContent(_ node: Node) -> some Rule {
        self.environment(keyPath: \.extraFooterContent, value: node)
    }
}

enum Title: EnvironmentKey {
    static var defaultValue: String? = nil
}

extension EnvironmentValues {
    public var title: String? {
        get { self[Title.self] }
        set { self[Title.self] = newValue }
    }
}

extension Rule {
    public func title(_ string: String?) -> some Rule {
        self.environment(keyPath: \.title, value: string)
    }
}
