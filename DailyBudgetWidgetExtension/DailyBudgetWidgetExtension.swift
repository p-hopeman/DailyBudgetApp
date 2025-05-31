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
    
    // Deutscher NumberFormatter für Geldbeträge
    private let currencyFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = Locale(identifier: "de_DE")
        formatter.currencySymbol = "€"
        formatter.currencyCode = "EUR"
        return formatter
    }()
    
    // Konvertiere den colorStatus in eine Color
    private func getColorForStatus(_ status: Int) -> Color {
        switch status {
        case 0:
            return .red
        case 1:
            return .yellow
        case 2:
            return .green
        default:
            return .yellow
        }
    }

    var body: some View {
        VStack(spacing: 8) {
            Text(currencyFormatter.string(from: NSNumber(value: entry.dailyBudget)) ?? "0,00 €")
                .font(.satoshi(size: 28, weight: .bold))
                .foregroundColor(.white)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
                .fixedSize(horizontal: false, vertical: true)
            
            Text("Tagesbudget")
                .font(.satoshi(size: 14, weight: .light))
                .foregroundColor(.white)
        }
        .padding()
        .containerBackground(getColorForStatus(entry.colorStatus), for: .widget)
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
