//
//  ContentView.swift
//  DailyBudgetApp-Xcode
//
//  Created by Philipp Hoffmann on 12.05.25.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @StateObject private var budgetModel = BudgetModel()
    @State private var showingAddExpense = false
    @State private var newExpenseAmount = ""
    @State private var newExpenseDescription = ""
    
    var body: some View {
        NavigationView {
            VStack {
                // Daily Budget Input
                HStack {
                    Text("Tagesbudget:")
                    TextField("Betrag", value: $budgetModel.dailyBudget, format: .currency(code: "EUR"))
                        .keyboardType(.decimalPad)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                }
                .padding()
                
                // Remaining Budget Display
                VStack {
                    Text("Verbleibendes Budget")
                        .font(.headline)
                    Text(budgetModel.calculateRemainingBudget(), format: .currency(code: "EUR"))
                        .font(.title)
                        .foregroundColor(budgetModel.calculateRemainingBudget() >= 0 ? .green : .red)
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
