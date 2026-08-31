    import XCTest
    import HTML
    @testable import Chris

    final class ChrisTests: XCTestCase {
        func testExample() {
            // This is an example of a functional test case.
            // Use XCTAssert and related functions to verify your tests produce the correct
            // results.
//            XCTAssertEqual(Chris().text, "Hello, World!")
        }

        func testPostScriptIsOnlyRenderedWhenConfigured() {
            let plain = BlogPost(
                metadata: .init(
                    headline: "Headline",
                    title: "Plain",
                    date: "2026-08-31"
                ),
                body: .markdown("Body"),
                link: "/post/plain"
            )
            let interactive = BlogPost(
                metadata: .init(
                    headline: "Headline",
                    title: "Interactive",
                    date: "2026-08-31",
                    script: "/js/shake-comparison.js"
                ),
                body: .markdown("Body"),
                link: "/post/interactive"
            )

            XCTAssertFalse(plain.page.render(xml: false).contains("shake-comparison.js"))
            let rendered = interactive.page.render(xml: false)
            XCTAssertTrue(rendered.contains(#"src="/js/shake-comparison.js""#))
            XCTAssertTrue(rendered.contains("defer"))
        }
    }
