protocol Traceable {}

extension Traceable {
    
    func dumpPrefix(function: StaticString = #function) -> String {
        "\(Self.self).\(function)"
    }
    
    func dump<T>(_ value: T, name: String? = nil, function: StaticString = #function, maxDepth: Int = .max) {
        let nameSuffix = (name.flatMap { ": " + $0 } ?? "")
        let prefix = dumpPrefix(function: function) + nameSuffix
        if ({ false }()) {
            Swift.dump(value, name: prefix, maxDepth: maxDepth)
        } else {
            print(prefix + ": " + "\(value)")
        }
    }
}
