import Foundation

class BudgetModel: ObservableObject {
    @Published var dailyBudget: Double {
        didSet {
            UserDefaults.standard.set(dailyBudget, forKey: "balance")
        }
    }
    @Published var expenses: [Expense] = []
    @Published var deposits: [Deposit] = []
    
    init() {
        self.dailyBudget = UserDefaults.standard.double(forKey: "balance")
    }
    
    struct Expense: Identifiable {
        let id = UUID()
        let amount: Double
        let description: String
        let date: Date
    }
    
    struct Deposit: Identifiable {
        let id = UUID()
        let amount: Double
        let description: String
        let date: Date
    }
    
    func addExpense(amount: Double, description: String) {
        let expense = Expense(amount: amount, description: description, date: Date())
        expenses.append(expense)
    }
    
    func addDeposit(amount: Double, description: String) {
        let deposit = Deposit(amount: amount, description: description, date: Date())
        deposits.append(deposit)
    }
    
    func calculateRemainingBudget() -> Double {
        let totalExpenses = expenses.reduce(0) { $0 + $1.amount }
        let totalDeposits = deposits.reduce(0) { $0 + $1.amount }
        return dailyBudget + totalDeposits - totalExpenses
    }
} 