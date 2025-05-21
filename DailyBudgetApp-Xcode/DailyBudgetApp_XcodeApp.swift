//
//  DailyBudgetApp_XcodeApp.swift
//  DailyBudgetApp-Xcode
//
//  Created by Philipp Hoffmann on 12.05.25.
//

import SwiftUI
import CoreText

@main
struct DailyBudgetApp_XcodeApp: App {
    init() {
        // Registriere benutzerdefinierte Schriftarten
        FontRegistration.registerFonts()
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
