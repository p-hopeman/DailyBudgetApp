import SwiftUI
import UIKit

extension Font {
    static func satoshi(size: CGFloat, weight: Font.Weight = .regular) -> Font {
        // Debug-Ausgabe für verfügbare Schriftarten
        #if DEBUG
        for family in UIFont.familyNames.sorted() {
            print("Widget - Schriftfamilie: \(family)")
            for name in UIFont.fontNames(forFamilyName: family).sorted() {
                print("   - \(name)")
            }
        }
        #endif
        
        switch weight {
        case .bold:
            // Versuche verschiedene Varianten des Namens
            if let _ = UIFont(name: "Satoshi-Bold", size: 12) {
                return .custom("Satoshi-Bold", size: size)
            } else if let _ = UIFont(name: "Satoshi Bold", size: 12) {
                return .custom("Satoshi Bold", size: size)
            } else {
                print("⚠️ Widget - Satoshi Bold nicht gefunden, verwende System-Schriftart")
                return .system(size: size, weight: .bold)
            }
        case .medium:
            if let _ = UIFont(name: "Satoshi-Medium", size: 12) {
                return .custom("Satoshi-Medium", size: size)
            } else if let _ = UIFont(name: "Satoshi Medium", size: 12) {
                return .custom("Satoshi Medium", size: size)
            } else {
                print("⚠️ Widget - Satoshi Medium nicht gefunden, verwende System-Schriftart")
                return .system(size: size, weight: .medium)
            }
        case .light:
            if let _ = UIFont(name: "Satoshi-Light", size: 12) {
                return .custom("Satoshi-Light", size: size)
            } else if let _ = UIFont(name: "Satoshi Light", size: 12) {
                return .custom("Satoshi Light", size: size)
            } else {
                print("⚠️ Widget - Satoshi Light nicht gefunden, verwende System-Schriftart")
                return .system(size: size, weight: .light)
            }
        default:
            if let _ = UIFont(name: "Satoshi-Regular", size: 12) {
                return .custom("Satoshi-Regular", size: size)
            } else if let _ = UIFont(name: "Satoshi Regular", size: 12) {
                return .custom("Satoshi Regular", size: size)
            } else {
                print("⚠️ Widget - Satoshi Regular nicht gefunden, verwende System-Schriftart")
                return .system(size: size, weight: .regular)
            }
        }
    }
} 