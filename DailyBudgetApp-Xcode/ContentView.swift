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
    @State private var showingAddExpense = false
    @State private var newExpenseAmount = ""
    @State private var newExpenseDescription = ""
    // Gemeinsame UserDefaults für App und Widget
    private let userDefaults = UserDefaults(suiteName: "group.com.dailybudget.app") ?? UserDefaults.standard
    
    private func getRemainingDaysInMonth() -> Int {
        let calendar = Calendar.current
        let today = Date()
        let range = calendar.range(of: .day, in: .month, for: today)!
        let totalDays = range.count
        let currentDay = calendar.component(.day, from: today)
        return totalDays - currentDay + 1
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
            }
            .navigationTitle("Tagesbudget")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingAddExpense = true }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .onAppear {
                // Berechne das Tagesbudget beim Start der App
                _ = calculateDailyBudget()
            }
            .sheet(isPresented: $showingAddExpense) {
                NavigationView {
                    Form {
                        TextField("Betrag", text: $newExpenseAmount)
                            .keyboardType(.decimalPad)
                        TextField("Beschreibung", text: $newExpenseDescription)
                    }
                    .navigationTitle("Neue Ausgabe")
                    .navigationBarItems(
                        leading: Button("Abbrechen") {
                            showingAddExpense = false
                        },
                        trailing: Button("Hinzufügen") {
                            if let amount = Double(newExpenseAmount) {
                                budgetModel.addExpense(amount: amount, description: newExpenseDescription)
                                newExpenseAmount = ""
                                newExpenseDescription = ""
                                showingAddExpense = false
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
