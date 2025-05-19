//
//  DailyBudgetWidgetExtension.swift
//  DailyBudgetApp-Xcode
//
//  Created by Philipp Hoffmann on 12.05.25.
//

import WidgetKit
import SwiftUI

struct Provider: TimelineProvider {
    // Gemeinsame UserDefaults für App und Widget
    let userDefaults = UserDefaults(suiteName: "group.com.dailybudget.app") ?? UserDefaults.standard
    
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), dailyBudget: 0.0, remainingDays: 0)
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
        return SimpleEntry(date: date, dailyBudget: dailyBudget, remainingDays: remainingDays)
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
}

struct DailyBudgetWidgetExtensionEntryView : View {
    var entry: Provider.Entry

    var body: some View {
        VStack(spacing: 8) {
            Text(String(format: "%.2f €", entry.dailyBudget))
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(.primary)
            
            Text("Tagesbudget")
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.secondary)
            
            Text("\(entry.remainingDays) Tage übrig")
                .font(.system(size: 12))
                .foregroundColor(.secondary)
        }
        .padding()
        .containerBackground(.fill.tertiary, for: .widget)
    }
}

struct DailyBudgetWidgetExtension: Widget {
    let kind: String = "DailyBudgetWidgetExtension"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            DailyBudgetWidgetExtensionEntryView(entry: entry)
        }
        .configurationDisplayName("Tagesbudget")
        .description("Zeigt Ihr tägliches Budget und die verbleibenden Tage an.")
        .supportedFamilies([.systemSmall])
    }
}

#Preview(as: .systemSmall) {
    DailyBudgetWidgetExtension()
} timeline: {
    SimpleEntry(date: .now, dailyBudget: 0.0, remainingDays: 0)
    SimpleEntry(date: .now, dailyBudget: 0.0, remainingDays: 0)
}
