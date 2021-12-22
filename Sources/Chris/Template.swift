import StaticSite
import HTML

struct Main: Template {
    func run(environment: EnvironmentValues, content: Node) -> Node {
        let theTitle = environment.title.map { "\($0) — Chris Eidhof" } ?? "Chris Eidhof"
        return html() {
            head() {
                meta(charset: "utf-8")
                meta(content: "IE=edge,chrome=1", httpEquiv: "X-UA-Compatible")
                meta(content: "width=device-width, initial-scale=1", name: "viewport")
                script(src: "//use.typekit.net/bwu1cse.js", type: "text/javascript")
                script(type: "text/javascript") {
                    "try{Typekit.load();}catch(e){}"
                    
                }
                link(href: "/images/favicon.ico", rel: "shortcut icon")
                link(href: "/css/style.css", rel: "stylesheet")
                link(href: "http://chris.eidhof.nl//index.xml", rel: "alternate", title: "RSS", type: "application/rss+xml")
                title {
                    theTitle
                }
//                meta(content: "Chris Eidhof", property: "og:title")
//                meta(content: "website", property: "og:type")
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
                            if let c = environment.extraFooterContent {
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
