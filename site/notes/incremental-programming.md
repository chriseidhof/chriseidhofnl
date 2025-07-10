---
title: "Incremental Programming"
created: 2025-07-10
---

The idea of incremental programming is to build up a representation of our program that can efficiently react to changes. Instead of recomputing everything all the time, we try to compute *minimal updates*. The [Attribute Graph](/note/attribute-graph) is an example of an incremental system.

## Examples

- Makefiles
- Spreadsheets
- Build Systems
- [Attribute Graph](/note/attribute-graph)
- …

## References

- [Build Systems a la Carte](https://simon.peytonjones.org/assets/pdfs/build-systems-jfp.pdf) is a Haskell paper about different approaches to incremental programming. It compares spreadsheets, build systems and other things through a unified framework.
- [How to Recalculate a Spreadsheet](https://lord.io/spreadsheets/). This shows different strategies of incremental computing as applied to spreadsheet computation. It talks about *dirty marking* (similar to the Attribute Graph) and *topological sorting* (similar to [incremental](https://github.com/chriseidhof/incremental-simplified)).
- [Seven Implementations of Incremental](https://blog.janestreet.com/seven-implementations-of-incremental/)
- [Demystify Parallelization in Swift Builds](https://developer.apple.com/videos/play/wwdc2022/110364) talks about how Swift builds are incremental.
