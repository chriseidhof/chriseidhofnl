# The Attribute Graph

The attribute graph is the structure that makes SwiftUI observe state changes. It works by building a directed acyclic graph of dependencies. It is based on the ideas of the eval/vite system (see references). The big idea is that when a node in the graph becomes invalid (e.g. a source node changes state) it recursively marks all dependent nodes as "potentially invalid". It also marks its direct outgoing edges as "pending". Whenever another node is requested, it goes through the following process to recompute:

- If the node isn't potentially dirty, it uses the previous (cached) value
- The node recomputes every incoming edge
- If the node now has incoming pending edges, it recomputes itself, otherwise, nothing has changed so it doesn't need to recompute
- The node marks all its incoming edges as not pending

(When there is an edge A -> B we say that A has an outgoing edge to B and B has an incoming edge from A. These are the same edge reference type, e.g. changing the pending state in the outgoing edge also changes the pending state of the corresponding incoming edge).

In the paper, an optimization is described for optional/conditional branches. For example, if we have a dependency on an if-statement, we only want to evaluate the body if the condition does not change.

The attribute graph is one way to implement *Incremental Computing* by only computing what's needed. It feels like phase one (marking all dependent nodes as potentially dirty) might be a bit expensive, but somehow that information needs to be propagated anyway.

## Example

Let's consider the following expression (this is written in plain Swift):

```swift
var a = 10
var b = 20
var c = a + b
var d = c * 2
```

When you model this using the attribute graph, you get out the following structure:

![](/images/media/2024-11-1208-43PastedImage.png)

When `a` changes, the outgoing edge will be marked as pending (denoted by the ⨉) and everything that depends directly (or indirectly) on a will be marked as potentially dirty (gray):

![](/images/media/2024-11-1208-47PastedImage.png)

Nothing else happens. When the value of `d` is requested, it first evaluates all its dependencies (just `c`). Evaluating `c` will evaluate both `a` and `b`. In either case, there is nothing to be done, but after the evaluation of `c`'s dependencies, the pending edge will still be there. Whenever there is a pending edge, `c` will reevaluate its expression (`a` + `b`). When the result changes, `c` will mark its outgoing edges as pending. `d` will see that its one incoming edge is pending and will re-evaluate itself as well.

## References

The attribute graph is based on the ideas in this paper:

```
@inproceedings{Hudson1993ASF,
  title={A System for Efficient and Flexible One-Way Constraint Evaluation in C++},
  author={Scott E. Hudson},
  year={1993},
  url={https://api.semanticscholar.org/CorpusID:55468721}
}
```

<https://citeseerx.ist.psu.edu/document?repid=rep1&type=pdf&doi=9609985dbef43633f4deb88c949a9776e0cd766b>
