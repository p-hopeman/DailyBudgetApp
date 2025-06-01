//
//  ContentView.swift
//  DailyBudgetApp-Xcode
//
//  Created by Philipp Hoffmann on 12.05.25.
//

import SwiftUI
import SwiftData
import WidgetKit
import UIKit

struct ContentView: View {
    @StateObject private var budgetModel = BudgetModel()
    @State private var showingAddTransaction = false
    @State private var transactionAmount = ""
    @State private var transactionDescription = ""
    @State private var isDeposit = true
    @Environment(\.colorScheme) private var colorScheme
    private let userDefaults = UserDefaults(suiteName: "group.com.dailybudget.app") ?? UserDefaults.standard
    
    @State private var currentMonth = Calendar.current.component(.month, from: Date())
    
    // Deutscher NumberFormatter für Geldbeträge
    private let currencyFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = Locale(identifier: "de_DE")
        formatter.currencySymbol = "€"
        formatter.currencyCode = "EUR"
        return formatter
    }()
    
    // Moderne Premium-Farben inspiriert von den Screenshots
    private var premiumColors = PremiumColors()
    
    private func getRemainingDaysInMonth() -> Int {
        let calendar = Calendar.current
        let today = Date()
        let range = calendar.range(of: .day, in: .month, for: today)!
        let totalDays = range.count
        let currentDay = calendar.component(.day, from: today)
        let remainingDays = totalDays - currentDay + 1
        
        // Speichere die verbleibenden Tage in UserDefaults
        userDefaults.set(remainingDays, forKey: "remainingDays")
        
        return remainingDays
    }
    
    private func calculateDailyBudget() -> Double {
        let remainingBudget = userDefaults.double(forKey: "remainingBudget")
        let remainingDays = getRemainingDaysInMonth()
        let dailyBudget = remainingDays > 0 ? remainingBudget / Double(remainingDays) : 0
        // Speichere das berechnete Tagesbudget in UserDefaults
        userDefaults.set(dailyBudget, forKey: "dailyBudget")
        // Speichere den Farbstatus in UserDefaults für das Widget
        userDefaults.set(getColorStatusForBudget(dailyBudget), forKey: "budgetColorStatus")
        // Aktualisiere das Widget
        WidgetCenter.shared.reloadAllTimelines()
        return dailyBudget
    }
    
    private func updateRemainingBudget(amount: Double) {
        let currentBudget = userDefaults.double(forKey: "remainingBudget")
        let newBudget = isDeposit ? currentBudget + amount : currentBudget - amount
        userDefaults.set(newBudget, forKey: "remainingBudget")
        _ = calculateDailyBudget()
    }
    
    // Formatiere das Datum auf Deutsch
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd. MMMM yyyy"
        formatter.locale = Locale(identifier: "de_DE")
        return formatter.string(from: date)
    }
    
    // Bestimme die Farbe basierend auf dem Tagesbudget
    private func getColorForBudget(_ budget: Double) -> Color {
        if budget < 0 {
            return .red
        } else if budget < 10 {
            return .yellow
        } else {
            return .green
        }
    }
    
    // Speichere den Farbstatus als Int für das Widget
    private func getColorStatusForBudget(_ budget: Double) -> Int {
        if budget < 0 {
            return 0 // Rot
        } else if budget < 10 {
            return 1 // Gelb
        } else {
            return 2 // Grün
        }
    }
    
    // Hilfsfunktion für Gradient-Farben basierend auf Budget
    private func getGradientColors(for budget: Double) -> [Color] {
        if budget < 0 {
            // Rot Gradient
            return [
                Color(red: 1.0, green: 0.3, blue: 0.3),     // Kräftiges Rot
                Color(red: 1.0, green: 0.7, blue: 0.7),     // Helles Rosa
                Color(red: 1.0, green: 0.85, blue: 0.85),   // Sehr helles Rosa
                Color(red: 1.0, green: 0.95, blue: 0.95),   // Fast Weiß mit Hauch Rosa
                Color.white,
                Color.white
            ]
        } else if budget < 10 {
            // Gelb Gradient
            return [
                Color(red: 1.0, green: 0.8, blue: 0.1),     // Kräftiges Gelb
                Color(red: 1.0, green: 0.9, blue: 0.5),     // Helles Gelb
                Color(red: 1.0, green: 0.95, blue: 0.8),    // Sehr helles Gelb
                Color(red: 1.0, green: 0.98, blue: 0.9),    // Fast Weiß mit Hauch Gelb
                Color.white,
                Color.white
            ]
        } else {
            // Grün Gradient
            return [
                Color(red: 0.2, green: 0.8, blue: 0.4),     // Kräftiges Grün
                Color(red: 0.6, green: 0.9, blue: 0.7),     // Helles Grün
                Color(red: 0.8, green: 0.95, blue: 0.85),   // Sehr helles Grün
                Color(red: 0.9, green: 0.98, blue: 0.95),   // Fast Weiß mit Hauch Grün
                Color.white,
                Color.white
            ]
        }
    }
    
    // Hilfsfunktion zum Testen der Schriftarten
    private func testFontAvailability() -> [String] {
        let fontNames = ["Satoshi-Regular", "Satoshi-Medium", "Satoshi-Bold", "Satoshi-Light"]
        var results: [String] = []
        
        for fontName in fontNames {
            if UIFont(name: fontName, size: 12) != nil {
                results.append("✅ \(fontName) ist verfügbar")
            } else {
                results.append("❌ \(fontName) ist NICHT verfügbar")
            }
        }
        
        return results
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                // Dynamischer Premium Hintergrund basierend auf dem Tagesbudget
                let gradientColors = getGradientColors(for: userDefaults.double(forKey: "dailyBudget"))
                LinearGradient(
                    gradient: Gradient(stops: [
                        .init(color: gradientColors[0], location: 0.0),
                        .init(color: gradientColors[1], location: 0.1),
                        .init(color: gradientColors[2], location: 0.2),
                        .init(color: gradientColors[3], location: 0.25),
                        .init(color: gradientColors[4], location: 0.3),
                        .init(color: gradientColors[5], location: 1.0)
                    ]),
                    startPoint: .top,
                    endPoint: .bottom
                )
                .edgesIgnoringSafeArea(.all)
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Hero Section mit verbesserter Lesbarkeit
                        VStack(spacing: 20) {
                            // Status Text
                            Text("VERFÜGBAR")
                                .font(.satoshi(size: 13, weight: .medium))
                                .foregroundStyle(Color(red: 0.4, green: 0.4, blue: 0.4))
                                .tracking(1.5)
                                .padding(.top, 40)
                            
                            // Hauptbetrag - sehr groß und gut lesbar
                            Text(currencyFormatter.string(from: NSNumber(value: userDefaults.double(forKey: "dailyBudget"))) ?? "0,00 €")
                                .font(.satoshi(size: 64, weight: .bold))
                                .foregroundStyle(Color(red: 0.1, green: 0.1, blue: 0.1))
                                .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
                                .padding(.horizontal, 20)
                                .multilineTextAlignment(.center)
                            
                            // Subtitle
                            Text("Tagesbudget")
                                .font(.satoshi(size: 20, weight: .medium))
                                .foregroundStyle(Color(red: 0.3, green: 0.3, blue: 0.3))
                                .padding(.bottom, 10)
                        }
                        .padding(.horizontal, 24)
                        
                        // Quick Stats Row - vergrößert
                        HStack(spacing: 16) {
                            // Verbleibendes Budget
                            VStack(spacing: 8) {
                                Text("VERBLEIBENDES\nBUDGET")
                                    .font(.satoshi(size: 11, weight: .semibold))
                                    .foregroundStyle(Color(red: 0.4, green: 0.4, blue: 0.4))
                                    .tracking(0.5)
                                    .multilineTextAlignment(.center)
                                
                                Text(currencyFormatter.string(from: NSNumber(value: userDefaults.double(forKey: "remainingBudget"))) ?? "0,00 €")
                                    .font(.satoshi(size: 20, weight: .bold))
                                    .foregroundStyle(Color(red: 0.1, green: 0.1, blue: 0.1))
                                    .lineLimit(1)
                                    .minimumScaleFactor(0.8)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 20)
                            .padding(.horizontal, 12)
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(.white)
                                    .shadow(color: .black.opacity(0.06), radius: 12, x: 0, y: 2)
                            )
                            
                            // Übrige Tage / Monats-Fortschritt  
                            VStack(spacing: 8) {
                                Text("VERBLEIBENDE\nTAGE")
                                    .font(.satoshi(size: 11, weight: .semibold))
                                    .foregroundStyle(Color(red: 0.4, green: 0.4, blue: 0.4))
                                    .tracking(0.5)
                                    .multilineTextAlignment(.center)
                                
                                Text("\(userDefaults.integer(forKey: "remainingDays"))")
                                    .font(.satoshi(size: 20, weight: .bold))
                                    .foregroundStyle(Color(red: 0.1, green: 0.1, blue: 0.1))
                                    .lineLimit(1)
                                    .minimumScaleFactor(0.8)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 20)
                            .padding(.horizontal, 12)
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(.white)
                                    .shadow(color: .black.opacity(0.06), radius: 12, x: 0, y: 2)
                            )
                        }
                        .padding(.horizontal, 24)
                        
                        // Recent Transactions - nur anzeigen wenn vorhanden
                        if !budgetModel.expenses.isEmpty || !budgetModel.deposits.isEmpty {
                            VStack(alignment: .leading, spacing: 16) {
                                HStack {
                                    Text("LETZTE TRANSAKTIONEN")
                                        .font(.satoshi(size: 13, weight: .semibold))
                                        .foregroundStyle(Color(red: 0.4, green: 0.4, blue: 0.4))
                                        .tracking(1.0)
                                    Spacer()
                                    Text("\(budgetModel.expenses.count + budgetModel.deposits.count)")
                                        .font(.satoshi(size: 12, weight: .semibold))
                                        .foregroundStyle(.white)
                                        .padding(.horizontal, 10)
                                        .padding(.vertical, 6)
                                        .background(Color(red: 0.5, green: 0.5, blue: 0.5))
                                        .cornerRadius(10)
                                }
                                .padding(.horizontal, 24)
                                
                                VStack(spacing: 12) {
                                    // Letzte 5 Transaktionen vertikal
                                    ForEach(getRecentTransactions(), id: \.id) { transaction in
                                        ImprovedTransactionCard(transaction: transaction, currencyFormatter: currencyFormatter)
                                    }
                                }
                                .padding(.horizontal, 24)
                            }
                        }
                        
                        // Spacer für Floating Buttons
                        Spacer(minLength: 120)
                    }
                }
                
                // Floating Action Buttons - Position verbessert
                VStack {
                    Spacer()
                    HStack(spacing: 16) {
                        // Einzahlung Button
                        Button(action: {
                            isDeposit = true
                            showingAddTransaction = true
                        }) {
                            HStack(spacing: 12) {
                                Image(systemName: "plus")
                                    .font(.system(size: 18, weight: .semibold))
                                Text("Einzahlung")
                                    .font(.satoshi(size: 16, weight: .semibold))
                            }
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 18)
                            .background(
                                RoundedRectangle(cornerRadius: 20)
                                    .fill(
                                        LinearGradient(
                                            gradient: Gradient(colors: [premiumColors.success, premiumColors.successSecondary]),
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                    )
                                    .shadow(color: premiumColors.success.opacity(0.3), radius: 12, x: 0, y: 8)
                            )
                        }
                        
                        // Auszahlung Button
                        Button(action: {
                            isDeposit = false
                            showingAddTransaction = true
                        }) {
                            HStack(spacing: 12) {
                                Image(systemName: "minus")
                                    .font(.system(size: 18, weight: .semibold))
                                Text("Auszahlung")
                                    .font(.satoshi(size: 16, weight: .semibold))
                            }
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 18)
                            .background(
                                RoundedRectangle(cornerRadius: 20)
                                    .fill(
                                        LinearGradient(
                                            gradient: Gradient(colors: [premiumColors.error, premiumColors.errorSecondary]),
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                    )
                                    .shadow(color: premiumColors.error.opacity(0.3), radius: 12, x: 0, y: 8)
                            )
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 34)
                }
            }
            .navigationBarHidden(true)
            .onAppear {
                // Berechne die verbleibenden Tage beim Start der App
                _ = getRemainingDaysInMonth()
                // Berechne das Tagesbudget beim Start der App
                _ = calculateDailyBudget()
                // Aktualisiere die Transaktionen für den aktuellen Monat
                budgetModel.refreshCurrentMonthTransactions()
                
                // Starte Timer für Monatswechsel-Überwachung
                Timer.scheduledTimer(withTimeInterval: 3600, repeats: true) { _ in
                    let newMonth = Calendar.current.component(.month, from: Date())
                    if newMonth != currentMonth {
                        currentMonth = newMonth
                        // Neuer Monat erkannt - aktualisiere die Anzeige
                        budgetModel.refreshCurrentMonthTransactions()
                        _ = getRemainingDaysInMonth()
                        _ = calculateDailyBudget()
                    }
                }
            }
            .sheet(isPresented: $showingAddTransaction) {
                PremiumTransactionSheet(
                    isPresented: $showingAddTransaction,
                    transactionAmount: $transactionAmount,
                    transactionDescription: $transactionDescription,
                    isDeposit: isDeposit,
                    currencyFormatter: currencyFormatter,
                    onAdd: { amount, description in
                        updateRemainingBudget(amount: amount)
                        if isDeposit {
                            budgetModel.addDeposit(amount: amount, description: description)
                        } else {
                            budgetModel.addExpense(amount: amount, description: description)
                        }
                        transactionAmount = ""
                        transactionDescription = ""
                        showingAddTransaction = false
                    }
                )
            }
        }
    }
    
    // Helper Functions
    private func getBudgetProgress() -> Double {
        let budget = userDefaults.double(forKey: "dailyBudget")
        let maxBudget = 100.0 // Annahme: 100€ als "perfektes" Tagesbudget
        return min(budget / maxBudget, 1.0)
    }
    
    private func getTodayExpenses() -> Double {
        let today = Calendar.current.startOfDay(for: Date())
        return budgetModel.expenses
            .filter { Calendar.current.isDate($0.date, inSameDayAs: today) }
            .reduce(0) { $0 + $1.amount }
    }
    
    private func getTodayDeposits() -> Double {
        let today = Calendar.current.startOfDay(for: Date())
        return budgetModel.deposits
            .filter { Calendar.current.isDate($0.date, inSameDayAs: today) }
            .reduce(0) { $0 + $1.amount }
    }
    
    private func getRecentTransactions() -> [TransactionItem] {
        var transactions: [TransactionItem] = []
        
        transactions.append(contentsOf: budgetModel.expenses.map { 
            TransactionItem(id: $0.id, amount: $0.amount, description: $0.description, date: $0.date, isExpense: true)
        })
        
        transactions.append(contentsOf: budgetModel.deposits.map { 
            TransactionItem(id: $0.id, amount: $0.amount, description: $0.description, date: $0.date, isExpense: false)
        })
        
        return transactions
            .sorted { $0.date > $1.date }
            .prefix(5)
            .map { $0 }
    }
}

// Premium Farb-System inspiriert von den Screenshots
struct PremiumColors {
    let accent = Color(red: 1.0, green: 0.45, blue: 0.85)        // Pink wie in Screenshot 3
    let accentSecondary = Color(red: 0.9, green: 0.3, blue: 0.7)
    
    let success = Color(red: 0.0, green: 0.78, blue: 0.35)
    let successSecondary = Color(red: 0.0, green: 0.68, blue: 0.38)
    
    let error = Color(red: 1.0, green: 0.31, blue: 0.31)         // Rot wie in Screenshot 2
    let errorSecondary = Color(red: 0.9, green: 0.2, blue: 0.2)
    
    let warning = Color(red: 1.0, green: 0.76, blue: 0.03)
    let warningSecondary = Color(red: 0.92, green: 0.65, blue: 0.05)
}

// Transaction Item für einheitliche Darstellung
struct TransactionItem: Identifiable {
    let id: UUID
    let amount: Double
    let description: String
    let date: Date
    let isExpense: Bool
}

// Verbesserte Transaction Card mit besserer Lesbarkeit - für vertikale Liste
struct ImprovedTransactionCard: View {
    let transaction: TransactionItem
    let currencyFormatter: NumberFormatter
    
    var body: some View {
        HStack(spacing: 16) {
            // Datum
            VStack(alignment: .leading, spacing: 4) {
                Text(formatDate(transaction.date))
                    .font(.satoshi(size: 12, weight: .medium))
                    .foregroundStyle(Color(red: 0.5, green: 0.5, blue: 0.5))
                
                Text(transaction.description)
                    .font(.satoshi(size: 14, weight: .medium))
                    .foregroundStyle(Color(red: 0.2, green: 0.2, blue: 0.2))
                    .lineLimit(2)
            }
            
            Spacer()
            
            // Betrag
            Text(currencyFormatter.string(from: NSNumber(value: transaction.amount)) ?? "0,00 €")
                .font(.satoshi(size: 16, weight: .bold))
                .foregroundStyle(transaction.isExpense ? Color(red: 0.9, green: 0.2, blue: 0.2) : Color(red: 0.0, green: 0.6, blue: 0.3))
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(.white)
                .shadow(color: .black.opacity(0.06), radius: 8, x: 0, y: 2)
        )
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d. MMM"
        formatter.locale = Locale(identifier: "de_DE")
        return formatter.string(from: date)
    }
}

// Premium Transaction Sheet
struct PremiumTransactionSheet: View {
    @Binding var isPresented: Bool
    @Binding var transactionAmount: String
    @Binding var transactionDescription: String
    let isDeposit: Bool
    let currencyFormatter: NumberFormatter
    let onAdd: (Double, String) -> Void
    
    var body: some View {
        ZStack {
            // Premium Hintergrund
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(red: 0.98, green: 0.98, blue: 1.0),
                    Color(red: 0.95, green: 0.96, blue: 0.99)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 32) {
                // Header
                VStack(spacing: 16) {
                    // Close Button
                    HStack {
                        Button(action: { isPresented = false }) {
                            Image(systemName: "xmark")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundStyle(Color(red: 0.4, green: 0.4, blue: 0.4))
                                .padding(8)
                                .background(Circle().fill(.white))
                                .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
                        }
                        Spacer()
                    }
                    
                    // Icon und Titel
                    VStack(spacing: 12) {
                        ZStack {
                            Circle()
                                .fill(isDeposit ? Color.green.opacity(0.2) : Color.red.opacity(0.2))
                                .frame(width: 80, height: 80)
                            
                            Image(systemName: isDeposit ? "plus" : "minus")
                                .font(.system(size: 32, weight: .semibold))
                                .foregroundStyle(isDeposit ? Color(red: 0.0, green: 0.6, blue: 0.3) : Color(red: 0.9, green: 0.2, blue: 0.2))
                        }
                        
                        Text(isDeposit ? "Neue Einzahlung" : "Neue Auszahlung")
                            .font(.satoshi(size: 24, weight: .bold))
                            .foregroundStyle(Color(red: 0.1, green: 0.1, blue: 0.1))
                    }
                }
                .padding(.horizontal, 24)
                .padding(.top, 20)
                
                // Form
                VStack(spacing: 24) {
                    // Betrag Input
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Betrag")
                            .font(.satoshi(size: 14, weight: .semibold))
                            .foregroundStyle(Color(red: 0.4, green: 0.4, blue: 0.4))
                        
                        TextField("0,00", text: $transactionAmount)
                            .font(.satoshi(size: 24, weight: .bold))
                            .foregroundColor(Color(red: 0.1, green: 0.1, blue: 0.1))
                            .keyboardType(.decimalPad)
                            .padding(20)
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(.white)
                                    .shadow(color: .black.opacity(0.04), radius: 8, x: 0, y: 2)
                            )
                    }
                    
                    // Beschreibung Input
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Beschreibung")
                            .font(.satoshi(size: 14, weight: .semibold))
                            .foregroundStyle(Color(red: 0.4, green: 0.4, blue: 0.4))
                        
                        TextField("Wofür war das?", text: $transactionDescription)
                            .font(.satoshi(size: 18, weight: .medium))
                            .foregroundColor(Color(red: 0.1, green: 0.1, blue: 0.1))
                            .padding(20)
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(.white)
                                    .shadow(color: .black.opacity(0.04), radius: 8, x: 0, y: 2)
                            )
                    }
                }
                .padding(.horizontal, 24)
                
                Spacer()
                
                // Action Button
                Button(action: {
                    let cleanAmount = transactionAmount.replacingOccurrences(of: ",", with: ".")
                    if let amount = Double(cleanAmount), amount > 0 {
                        onAdd(amount, transactionDescription)
                    }
                }) {
                    Text("Hinzufügen")
                        .font(.satoshi(size: 18, weight: .semibold))
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 20)
                        .background(
                            RoundedRectangle(cornerRadius: 20)
                                .fill(isDeposit ? Color(red: 0.0, green: 0.6, blue: 0.3) : Color(red: 0.9, green: 0.2, blue: 0.2))
                                .shadow(color: (isDeposit ? Color(red: 0.0, green: 0.6, blue: 0.3) : Color(red: 0.9, green: 0.2, blue: 0.2)).opacity(0.3), radius: 12, x: 0, y: 8)
                        )
                }
                .disabled(transactionAmount.isEmpty || transactionDescription.isEmpty)
                .padding(.horizontal, 24)
                .padding(.bottom, 34)
            }
        }
    }
}

#Preview {
    ContentView()
}
