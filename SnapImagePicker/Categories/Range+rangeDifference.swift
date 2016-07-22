//TODO: FIND A BETTER SOLUTION (Extensions) (talk to niklas)

func findPrecedingElementsOfRange(first: Range<Int>, other: Range<Int>) -> Range<Int> {
    if other.startIndex < first.startIndex {
        return other.startIndex..<first.endIndex
    } else {
        return other.startIndex...other.startIndex
    }
}
    
func findTrailingElementsOfRange(first: Range<Int>, other: Range<Int>) -> Range<Int> {
    if other.endIndex > first.endIndex {
        return first.endIndex - 1...other.endIndex
    } else {
        return other.endIndex...other.endIndex
    }
}

func span(range: Range<Int>) -> Int {
    return range.endIndex - range.startIndex
}
