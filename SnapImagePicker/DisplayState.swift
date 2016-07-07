enum DisplayState {
    case Image
    case Album
        
    var offset: Double {
        switch self {
        case .Image: return 0.0
        case .Album: return 0.85
        }
    }
}