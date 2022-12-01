extension Collection {
    public func group<Prop: Equatable>(by: (Element) -> Prop) -> [[Element]] {
        var result: [[Element]] = []
        var last: Prop? { result.last?.last.map(by) }
        for el in self {
            if let l = last, l == by(el) {
                result[result.endIndex-1].append(el)
            } else {
                result.append([el])
            }
        }
        return result
    }
}
