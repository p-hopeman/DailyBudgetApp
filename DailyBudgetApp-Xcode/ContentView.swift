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
    
    var body: some View {
        NavigationView {
            VStack {
                // Daily Budget Display
                HStack {
                    Text("Tagesbudget:")
                    Text(userDefaults.double(forKey: "dailyBudget"), format: .currency(code: "EUR"))
                        .font(.headline)
                }
                .padding()
                
                // Remaining Days Display
                HStack {
                    Text("Verbleibende Tage:")
                    Text("\(userDefaults.integer(forKey: "remainingDays"))")
                        .font(.headline)
                }
                .padding()
                
                // Remaining Budget Input
                HStack {
                    Text("Verbleibendes Budget:")
                    TextField("Betrag", value: Binding(
                        get: { userDefaults.double(forKey: "remainingBudget") },
                        set: { 
                            userDefaults.set($0, forKey: "remainingBudget")
                            // Berechne und aktualisiere das Tagesbudget bei Änderung des verbleibenden Budgets
                            _ = calculateDailyBudget()
                        }
                    ), format: .currency(code: "EUR"))
                    .keyboardType(.decimalPad)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                }
                .padding()
                
                // Remaining Budget Display
                VStack {
                    Text("Verbleibendes Budget")
                        .font(.headline)
                    Text(userDefaults.double(forKey: "remainingBudget"), format: .currency(code: "EUR"))
                        .font(.title)
                        .foregroundColor(userDefaults.double(forKey: "remainingBudget") >= 0 ? .green : .red)
                }
                .padding()
                
                // Expenses List
                List {
                    ForEach(budgetModel.expenses) { expense in
                        HStack {
                            VStack(alignment: .leading) {
                                Text(expense.description)
                                    .font(.headline)
                                Text(expense.date, style: .date)
                                    .font(.caption)
                            }
                            Spacer()
                            Text(expense.amount, format: .currency(code: "EUR"))
                                .foregroundColor(.red)
                        }
                    }
                }
                
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
                        .background(Color.green.opacity(0.2))
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
                        .background(Color.red.opacity(0.2))
                        .cornerRadius(10)
                    }
                }
                .padding()
            }
            .navigationTitle("Tagesbudget")
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
                                if !isDeposit {
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
