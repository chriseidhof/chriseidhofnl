import StaticSite
import HTML

struct Main: Template {
    @Environment(\.title) var title
    @Environment(\.extraFooterContent) var extraFooterContent
    @Environment(\.openGraphImage) var openGraphImage

    func run(content: Node) -> Node {
        let theTitle = title!.map { "\($0) — Chris Eidhof" } ?? "Chris Eidhof"
        return html() {
            head() {
                meta(charset: "utf-8")
                meta(content: "IE=edge,chrome=1", httpEquiv: "X-UA-Compatible")
                meta(content: "width=device-width, initial-scale=1", name: "viewport")
                link(href: "/images/favicon.ico", rel: "shortcut icon")
                link(href: "/css/style.css", rel: "stylesheet")
                link(href: "http://chris.eidhof.nl//index.xml", rel: "alternate", title: "RSS", type: "application/rss+xml")
                HTML.title {
                    theTitle
                }
                meta(content: theTitle, customAttributes: ["property": "og:title"])
                meta(content: "website", customAttributes: ["property": "og:type"])
                if let i = openGraphImage, let content = i, !content.isEmpty {
                    meta(content: content, customAttributes: ["property": "og:image"])
                }
//                meta(content: "http://chris.eidhof.nl/", property: "og:url")
                
            }
            body {
                section(id: "content") {
                    section(id: "outer-container") {
                        section(id: "wrapper") {
                            header(id: "header") {
                                a(href: "/", id: "title") {
                                    img(src: "/images/logo.png", style: "width: 2em")
                                    
                                }
                                
                            }
                            content
                            if let c = extraFooterContent! {
                                c
                            }
                        }
                        
                    }
                    
                }
//                script(src: "/js/main.js/")
            }
            
            
        }
    }
    
}
