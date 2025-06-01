//
//  DailyBudgetWidgetExtension.swift
//  DailyBudgetApp-Xcode
//
//  Created by Philipp Hoffmann on 12.05.25.
//

import WidgetKit
import SwiftUI
import CoreText
#if canImport(UIKit)
import UIKit
#endif

// Registriere Schriftarten beim Laden des Moduls
private let fontRegistrationDone: Bool = {
    FontRegistration.registerFonts()
    return true
}()

struct Provider: TimelineProvider {
    // Gemeinsame UserDefaults für App und Widget
    let userDefaults = UserDefaults(suiteName: "group.com.dailybudget.app") ?? UserDefaults.standard
    
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), dailyBudget: 0.0, remainingDays: 0, colorStatus: 1)
    }

    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        let entry = loadEntry()
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        let entry = loadEntry()
        
        // Aktualisiere das Widget alle 15 Minuten
        var currentDate = Date()
        var entries: [SimpleEntry] = [entry]
        
        // Erstelle mehrere Einträge für regelmäßige Aktualisierungen
        for _ in 0..<24 {
            currentDate = Calendar.current.date(byAdding: .minute, value: 15, to: currentDate)!
            let entry = loadEntry(date: currentDate)
            entries.append(entry)
        }
        
        let timeline = Timeline(entries: entries, policy: .atEnd)
        completion(timeline)
    }
    
    private func loadEntry(date: Date = Date()) -> SimpleEntry {
        let dailyBudget = userDefaults.double(forKey: "dailyBudget")
        let remainingDays = userDefaults.integer(forKey: "remainingDays")
        let colorStatus = userDefaults.integer(forKey: "budgetColorStatus")
        return SimpleEntry(date: date, dailyBudget: dailyBudget, remainingDays: remainingDays, colorStatus: colorStatus)
    }
    
    // Diese Funktion wird nicht mehr benötigt, da wir die verbleibenden Tage aus UserDefaults lesen
    // Wir behalten sie als Fallback, falls keine Daten in UserDefaults vorhanden sind
    private func calculateRemainingDays() -> Int {
        let calendar = Calendar.current
        let today = Date()
        let range = calendar.range(of: .day, in: .month, for: today)!
        let daysInMonth = range.count
        let currentDay = calendar.component(.day, from: today)
        return daysInMonth - currentDay + 1
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let dailyBudget: Double
    let remainingDays: Int
    let colorStatus: Int
}

struct DailyBudgetWidgetExtensionEntryView : View {
    var entry: Provider.Entry
    
    // Hilfsfunktion für Gradient-Farben basierend auf Budget (identisch zur App)
    private func getGradientColors(for budget: Double) -> [Color] {
        if budget < 0 {
            // Rot Gradient
            return [
                Color(red: 1.0, green: 0.3, blue: 0.3),     // Kräftiges Rot
                Color(red: 0.8, green: 0.2, blue: 0.2),     // Dunkleres Rot für Widget
                Color(red: 0.6, green: 0.1, blue: 0.1)      // Noch dunkler für Tiefe
            ]
        } else if budget < 10 {
            // Gelb Gradient
            return [
                Color(red: 1.0, green: 0.8, blue: 0.1),     // Kräftiges Gelb
                Color(red: 0.9, green: 0.7, blue: 0.0),     // Dunkleres Gelb
                Color(red: 0.8, green: 0.6, blue: 0.0)      // Noch dunkler
            ]
        } else {
            // Grün Gradient
            return [
                Color(red: 0.2, green: 0.8, blue: 0.4),     // Kräftiges Grün
                Color(red: 0.1, green: 0.7, blue: 0.3),     // Dunkleres Grün
                Color(red: 0.0, green: 0.6, blue: 0.2)      // Noch dunkler
            ]
        }
    }
    
    // Berechne den Monatsfortschritt in Prozent
    private func getMonthProgress() -> Int {
        let calendar = Calendar.current
        let now = Date()
        let range = calendar.range(of: .day, in: .month, for: now)!
        let totalDays = range.count
        let currentDay = calendar.component(.day, from: now)
        let progressPercent = Int((Double(currentDay) / Double(totalDays)) * 100)
        return min(progressPercent, 100)
    }

    var body: some View {
        let gradientColors = getGradientColors(for: entry.dailyBudget)
        
        VStack(alignment: .leading, spacing: 8) {
            // Riesige Hauptzahl mit € Symbol ganz oben
            Text("\(String(format: "%.0f", entry.dailyBudget))€")
                .font(.satoshi(size: 156, weight: .bold))
                .foregroundColor(.white)
                .lineLimit(1)
                .minimumScaleFactor(0.3)
                .shadow(color: .black.opacity(0.15), radius: 3, x: 0, y: 2)
            
            // "Tagesbudget" sehr klein damit es komplett reinpasst
            Text("Tagesbudget")
                .font(.satoshi(size: 12, weight: .medium))
                .foregroundColor(.white.opacity(0.8))
            
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .padding(20)
        .containerBackground(for: .widget) {
            // Dynamischer Hintergrund-Gradient wie in der App
            LinearGradient(
                gradient: Gradient(colors: gradientColors),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
    }
}

struct DailyBudgetWidgetExtension: Widget {
    let kind: String = "DailyBudgetWidgetExtension"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            DailyBudgetWidgetExtensionEntryView(entry: entry)
        }
        .configurationDisplayName("Tagesbudget")
        .description("Zeigt Ihr tägliches Budget an.")
        .supportedFamilies([.systemSmall])
    }
}

#Preview(as: .systemSmall) {
    DailyBudgetWidgetExtension()
} timeline: {
    SimpleEntry(date: .now, dailyBudget: 14.91, remainingDays: 0, colorStatus: 1)
    SimpleEntry(date: .now, dailyBudget: 15.00, remainingDays: 0, colorStatus: 2)
}
