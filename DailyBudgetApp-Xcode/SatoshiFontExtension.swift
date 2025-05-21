import SwiftUI

extension Font {
    static func satoshi(size: CGFloat, weight: Font.Weight = .regular) -> Font {
        switch weight {
        case .bold:
            return .custom("Satoshi-Bold", size: size)
        case .medium:
            return .custom("Satoshi-Medium", size: size)
        case .light:
            return .custom("Satoshi-Light", size: size)
        default:
            return .custom("Satoshi-Regular", size: size)
        }
    }
    
    // Zusätzliche Hilfsmethoden für spezifische Textgrößen
    static func satoshiTitle() -> Font {
        return .satoshi(size: 28, weight: .bold)
    }
    
    static func satoshiHeadline() -> Font {
        return .satoshi(size: 20, weight: .bold)
    }
    
    static func satoshiBody() -> Font {
        return .satoshi(size: 16, weight: .regular)
    }
    
    static func satoshiCaption() -> Font {
        return .satoshi(size: 12, weight: .light)
    }
} 