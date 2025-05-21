import Foundation
import CoreText
import UIKit

class FontRegistration {
    static func registerFonts() {
        // Pfade zu den Schriftartdateien
        let fontNames = ["Satoshi-Regular", "Satoshi-Medium", "Satoshi-Bold", "Satoshi-Light"]
        let fontExtension = "otf"
        
        // Registriere jede Schriftart
        for fontName in fontNames {
            // Versuche zuerst den normalen Weg
            if let fontURL = Bundle.main.url(forResource: fontName, withExtension: fontExtension, subdirectory: "Fonts") {
                print("📝 Versuche, Schriftart zu registrieren: \(fontName).\(fontExtension)")
                var error: Unmanaged<CFError>?
                let success = CTFontManagerRegisterFontsForURL(fontURL as CFURL, .process, &error)
                if success {
                    print("✅ Schriftart erfolgreich registriert: \(fontName).\(fontExtension)")
                } else {
                    print("❌ Fehler beim Registrieren der Schriftart: \(fontName).\(fontExtension)")
                    if let error = error?.takeRetainedValue() {
                        print("   Fehler: \(error)")
                    }
                }
            } else {
                print("⚠️ Konnte Schriftart nicht finden: \(fontName).\(fontExtension)")
                
                // Alternativer Ansatz: Versuche, die Schriftart direkt aus dem Bundle-Pfad zu laden
                if let resourcePath = Bundle.main.resourcePath {
                    let fontPath = resourcePath + "/Fonts/" + fontName + "." + fontExtension
                    let fontURL = URL(fileURLWithPath: fontPath)
                    print("🔍 Versuche alternativen Pfad: \(fontPath)")
                    
                    if FileManager.default.fileExists(atPath: fontPath) {
                        print("📄 Datei existiert am alternativen Pfad")
                        var error: Unmanaged<CFError>?
                        let success = CTFontManagerRegisterFontsForURL(fontURL as CFURL, .process, &error)
                        if success {
                            print("✅ Schriftart erfolgreich über alternativen Pfad registriert: \(fontName).\(fontExtension)")
                        } else {
                            print("❌ Fehler beim Registrieren der Schriftart über alternativen Pfad: \(fontName).\(fontExtension)")
                            if let error = error?.takeRetainedValue() {
                                print("   Fehler: \(error)")
                            }
                        }
                    } else {
                        print("❌ Datei existiert nicht am alternativen Pfad")
                    }
                }
            }
        }
        
        // Liste alle verfügbaren Schriftarten zur Überprüfung
        print("📋 Verfügbare Schriftarten:")
        for family in UIFont.familyNames.sorted() {
            print("👨‍👩‍👧‍👦 \(family)")
            for name in UIFont.fontNames(forFamilyName: family).sorted() {
                print("   - \(name)")
            }
        }
    }
} 