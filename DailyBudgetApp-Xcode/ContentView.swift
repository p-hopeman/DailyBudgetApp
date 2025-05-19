//
//  ContentView.swift
//  DailyBudgetApp-Xcode
//
//  Created by Philipp Hoffmann on 12.05.25.
//

import SwiftUI
import SwiftData
import WidgetKit

struct ContentView: View {
    @StateObject private var budgetModel = BudgetModel()
    @State private var showingAddTransaction = false
    @State private var transactionAmount = ""
    @State private var transactionDescription = ""
    @State private var isDeposit = true  // true für Einzahlung, false für Auszahlung
    @Environment(\.colorScheme) private var colorScheme  // Für Zugriff auf das System-Farbschema
    // Gemeinsame UserDefaults für App und Widget
    private let userDefaults = UserDefaults(suiteName: "group.com.dailybudget.app") ?? UserDefaults.standard
    
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
                            Text(userDefaults.double(forKey: "dailyBudget"), format: .currency(code: "EUR"))
                                .font(.system(size: 48, weight: .bold))
                                .padding(.top, 30)
                                .foregroundColor(.white)
                            
                            Text("Tagesbudget")
                                .font(.system(size: 24))
                                .padding(.bottom, 20)
                                .foregroundColor(.white)
                        }
                        
                        // Untere Informationszeile
                        HStack(spacing: 0) {
                            // Verbleibende Tage
                            VStack {
                                Text("\(userDefaults.integer(forKey: "remainingDays"))")
                                    .font(.system(size: 32, weight: .bold))
                                    .foregroundColor(.white)
                                
                                Text("verbleibende Tage")
                                    .font(.system(size: 14))
                                    .foregroundColor(.white)
                            }
                            .frame(maxWidth: .infinity)
                            
                            // Verbleibendes Budget
                            VStack {
                                Text(userDefaults.double(forKey: "remainingBudget"), format: .currency(code: "EUR"))
                                    .font(.system(size: 32, weight: .bold))
                                    .foregroundColor(.white)
                                
                                Text("verbleibendes Budget")
                                    .font(.system(size: 14))
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
                                    .font(.headline)
                                
                                // Beschreibung
                                Spacer()
                                Text(expense.description)
                                    .font(.body)
                                Spacer()
                                
                                // Betrag
                                Text(expense.amount, format: .currency(code: "EUR"))
                                    .foregroundColor(.red)
                            }
                            .listRowBackground(colorScheme == .dark ? Color.black.opacity(0.8) : Color.white)
                        }
                        
                        // Einzahlungen anzeigen
                        ForEach(budgetModel.deposits) { deposit in
                            HStack {
                                // Datum
                                Text(formatDate(deposit.date))
                                    .font(.headline)
                                
                                // Beschreibung
                                Spacer()
                                Text(deposit.description)
                                    .font(.body)
                                Spacer()
                                
                                // Betrag
                                Text(deposit.amount, format: .currency(code: "EUR"))
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
                            if let amount = Double(transactionAmount) {
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
