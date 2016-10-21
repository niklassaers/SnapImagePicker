//TODO: FIND A BETTER SOLUTION (Extensions) (talk to niklas)

func findPrecedingElementsOfRange(_ first: CountableRange<Int>, other: CountableRange<Int>) -> CountableRange<Int> {
    if other.lowerBound < first.lowerBound {
        return other.lowerBound..<first.lowerBound
    } else {
        return other.startIndex..<other.startIndex.advanced(by: 1)
    }
}
    
func findTrailingElementsOfRange(_ first: CountableRange<Int>, other: CountableRange<Int>) -> CountableRange<Int> {
    if other.upperBound > first.upperBound {
        return first.upperBound - 1..<other.upperBound
    } else {
        return other.endIndex..<other.endIndex.advanced(by: 1)
    }
}

func span(_ range: CountableRange<Int>) -> Int {
    return range.upperBound - range.lowerBound
}

func expandRange(_ range: CountableRange<Int>, byAmount amount: Int, withLowerBound lowerBound: Int, andUpperBound upperBound: Int) -> CountableRange<Int> {
    return max(lowerBound, range.lowerBound - amount)..<min(upperBound, range.upperBound + amount)
}
