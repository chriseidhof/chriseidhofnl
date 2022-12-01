import Foundation

let df: DateFormatter = {
    var x = DateFormatter()
    x.dateFormat = "MMM d, yyyy"
    return x
}()

let dfDateTime: DateFormatter = {
    var x = DateFormatter()
    x.dateFormat = "MMM d, yyyy · HH:mm"
    return x
}()

let df2: DateFormatter = {
    var x = DateFormatter()
    x.dateFormat = "MMM d"
    return x
}()

public enum DateStyle {
    case dayMonth
    case dayMonthYear
    case dateTime

    var formatter: DateFormatter {
        switch self {
        case .dateTime: return dfDateTime
        case .dayMonth: return df2
        case .dayMonthYear: return df
        }
    }
}

extension Date {

    public func pretty(style: DateStyle) -> String {
        style.formatter.string(from: self)
    }
}
