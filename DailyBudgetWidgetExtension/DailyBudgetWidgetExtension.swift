//
//  DailyBudgetWidgetExtension.swift
//  DailyBudgetApp-Xcode
//
//  Created by Philipp Hoffmann on 12.05.25.
//

import WidgetKit
import SwiftUI

struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), dailyBudget: 0.0, remainingDays: 0)
    }

    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        let (dailyBudget, remainingDays) = calculateDailyBudget()
        let entry = SimpleEntry(date: Date(), dailyBudget: dailyBudget, remainingDays: remainingDays)
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        let (dailyBudget, remainingDays) = calculateDailyBudget()
        let entry = SimpleEntry(date: Date(), dailyBudget: dailyBudget, remainingDays: remainingDays)
        let timeline = Timeline(entries: [entry], policy: .atEnd)
        completion(timeline)
    }
    
    private func calculateDailyBudget() -> (Double, Int) {
        let balance = UserDefaults.standard.double(forKey: "balance")
        let calendar = Calendar.current
        let today = Date()
        
        let range = calendar.range(of: .day, in: .month, for: today)!
        let daysInMonth = range.count
        let currentDay = calendar.component(.day, from: today)
        let remainingDays = daysInMonth - currentDay + 1
        
        let dailyBudget = balance / Double(remainingDays)
        return ((dailyBudget * 100).rounded() / 100, remainingDays)
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
