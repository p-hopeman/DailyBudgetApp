import SwiftUI
import UIKit

extension Font {
    static func satoshi(size: CGFloat, weight: Font.Weight = .regular) -> Font {
        // Debug-Ausgabe für verfügbare Schriftarten
        #if DEBUG
        for family in UIFont.familyNames.sorted() {
            print("Schriftfamilie: \(family)")
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
                print("⚠️ Satoshi Bold nicht gefunden, verwende System-Schriftart")
                return .system(size: size, weight: .bold)
            }
        case .medium:
            if let _ = UIFont(name: "Satoshi-Medium", size: 12) {
                return .custom("Satoshi-Medium", size: size)
            } else if let _ = UIFont(name: "Satoshi Medium", size: 12) {
                return .custom("Satoshi Medium", size: size)
            } else {
                print("⚠️ Satoshi Medium nicht gefunden, verwende System-Schriftart")
                return .system(size: size, weight: .medium)
            }
        case .light:
            if let _ = UIFont(name: "Satoshi-Light", size: 12) {
                return .custom("Satoshi-Light", size: size)
            } else if let _ = UIFont(name: "Satoshi Light", size: 12) {
                return .custom("Satoshi Light", size: size)
            } else {
                print("⚠️ Satoshi Light nicht gefunden, verwende System-Schriftart")
                return .system(size: size, weight: .light)
            }
        default:
            if let _ = UIFont(name: "Satoshi-Regular", size: 12) {
                return .custom("Satoshi-Regular", size: size)
            } else if let _ = UIFont(name: "Satoshi Regular", size: 12) {
                return .custom("Satoshi Regular", size: size)
            } else {
                print("⚠️ Satoshi Regular nicht gefunden, verwende System-Schriftart")
                return .system(size: size, weight: .regular)
            }
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