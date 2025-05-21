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
} 