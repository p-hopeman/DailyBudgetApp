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
    @State private var isDeposit = true  // true für Einzahlung, false für Auszahlung
    @Environment(\.colorScheme) private var colorScheme  // Für Zugriff auf das System-Farbschema
    // Gemeinsame UserDefaults für App und Widget
    private let userDefaults = UserDefaults(suiteName: "group.com.dailybudget.app") ?? UserDefaults.standard
    
    // Für die Überwachung des Monatswechsels
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
                // Hintergrundfarbe für die gesamte App
                (colorScheme == .dark ? Color.black : Color.white)
                    .edgesIgnoringSafeArea(.all)
                
                VStack(spacing: 0) {
                    // Oberer Bereich mit dynamischer Hintergrundfarbe
                    VStack {
                        // Hauptanzeige für Tagesbudget
                        VStack(spacing: 0) {
                            Text(currencyFormatter.string(from: NSNumber(value: userDefaults.double(forKey: "dailyBudget"))) ?? "0,00 €")
                                .font(.satoshi(size: 52, weight: .bold))
                                .padding(.top, 30)
                                .foregroundColor(.white)
                            
                            Text("Tagesbudget")
                                .font(.satoshi(size: 24, weight: .light))
                                .padding(.bottom, 20)
                                .foregroundColor(.white)
                        }
                        
                        // Untere Informationszeile
                        HStack(spacing: 0) {
                            // Verbleibende Tage
                            VStack {
                                Text("\(userDefaults.integer(forKey: "remainingDays"))")
                                    .font(.satoshi(size: 36, weight: .bold))
                                    .foregroundColor(.white)
                                
                                Text("verbleibende Tage")
                                    .font(.satoshi(size: 14, weight: .light))
                                    .foregroundColor(.white)
                            }
                            .frame(maxWidth: .infinity)
                            
                            // Verbleibendes Budget
                            VStack {
                                Text(currencyFormatter.string(from: NSNumber(value: userDefaults.double(forKey: "remainingBudget"))) ?? "0,00 €")
                                    .font(.satoshi(size: 36, weight: .bold))
                                    .foregroundColor(.white)
                                
                                Text("verbleibendes Budget")
                                    .font(.satoshi(size: 14, weight: .light))
                                    .foregroundColor(.white)
                            }
                            .frame(maxWidth: .infinity)
                        }
                        .padding(.horizontal)
                        .padding(.bottom, 30)
                    }
                    .background(getColorForBudget(userDefaults.double(forKey: "dailyBudget")))
                    
                    Divider()
                        .frame(height: 1)
                        .background(Color.gray)
                    
                    // Expenses List
                    List {
                        ForEach(budgetModel.expenses) { expense in
                            HStack {
                                // Datum
                                Text(formatDate(expense.date))
                                    .font(.satoshi(size: 16, weight: .light))
                                
                                // Beschreibung
                                Spacer()
                                Text(expense.description)
                                    .font(.satoshi(size: 16, weight: .light))
                                Spacer()
                                
                                // Betrag
                                Text(currencyFormatter.string(from: NSNumber(value: expense.amount)) ?? "0,00 €")
                                    .font(.satoshi(size: 16, weight: .bold))
                                    .foregroundColor(.red)
                            }
                            .listRowBackground(colorScheme == .dark ? Color.black.opacity(0.8) : Color.white)
                        }
                        
                        // Einzahlungen anzeigen
                        ForEach(budgetModel.deposits) { deposit in
                            HStack {
                                // Datum
                                Text(formatDate(deposit.date))
                                    .font(.satoshi(size: 16, weight: .light))
                                
                                // Beschreibung
                                Spacer()
                                Text(deposit.description)
                                    .font(.satoshi(size: 16, weight: .light))
                                Spacer()
                                
                                // Betrag
                                Text(currencyFormatter.string(from: NSNumber(value: deposit.amount)) ?? "0,00 €")
                                    .font(.satoshi(size: 16, weight: .bold))
                                    .foregroundColor(.green)
                            }
                            .listRowBackground(colorScheme == .dark ? Color.black.opacity(0.8) : Color.white)
                        }
                    }
                    .listStyle(PlainListStyle())
                    
                    Spacer()
                    
                    // Buttons für Ein- und Auszahlungen
                    HStack(spacing: 20) {
                        Button(action: {
                            isDeposit = true
                            showingAddTransaction = true
                        }) {
                            VStack {
                                Image(systemName: "plus.circle.fill")
                                    .font(.system(size: 32))
                                    .foregroundColor(.black)
                                Text("Einzahlung")
                                    .foregroundColor(.black)
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.green.opacity(0.8))
                            .cornerRadius(10)
                        }
                        
                        Button(action: {
                            isDeposit = false
                            showingAddTransaction = true
                        }) {
                            VStack {
                                Image(systemName: "minus.circle.fill")
                                    .font(.system(size: 32))
                                    .foregroundColor(.black)
                                Text("Auszahlung")
                                    .foregroundColor(.black)
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.red.opacity(0.8))
                            .cornerRadius(10)
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("Tagesbudget")
            .navigationBarTitleDisplayMode(.inline)
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
                NavigationView {
                    Form {
                        TextField("Betrag", text: $transactionAmount)
                            .keyboardType(.decimalPad)
                        TextField("Beschreibung", text: $transactionDescription)
                    }
                    .navigationTitle(isDeposit ? "Neue Einzahlung" : "Neue Auszahlung")
                    .navigationBarItems(
                        leading: Button("Abbrechen") {
                            showingAddTransaction = false
                        },
                        trailing: Button("Hinzufügen") {
                            // Deutsche Komma-Eingaben unterstützen
                            let cleanAmount = transactionAmount.replacingOccurrences(of: ",", with: ".")
                            if let amount = Double(cleanAmount) {
                                updateRemainingBudget(amount: amount)
                                if isDeposit {
                                    budgetModel.addDeposit(amount: amount, description: transactionDescription)
                                } else {
                                    budgetModel.addExpense(amount: amount, description: transactionDescription)
                                }
                                transactionAmount = ""
                                transactionDescription = ""
                                showingAddTransaction = false
                            }
                        }
                    )
                }
            }
        }
    }
}

#Preview {
    ContentView()
}
