import Foundation

class BudgetModel: ObservableObject {
    @Published var dailyBudget: Double {
        didSet {
            UserDefaults.standard.set(dailyBudget, forKey: "balance")
        }
    }
    @Published var expenses: [Expense] = []
    
    init() {
        self.dailyBudget = UserDefaults.standard.double(forKey: "balance")
    }
    
    struct Expense: Identifiable {
        let id = UUID()
        let amount: Double
        let description: String
        let date: Date
    }
    
    func addExpense(amount: Double, description: String) {
        let expense = Expense(amount: amount, description: description, date: Date())
        expenses.append(expense)
    }
    
    func calculateRemainingBudget() -> Double {
        let totalExpenses = expenses.reduce(0) { $0 + $1.amount }
        return dailyBudget - totalExpenses
    }
} 