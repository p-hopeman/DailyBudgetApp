import Foundation

class BudgetModel: ObservableObject {
    @Published var dailyBudget: Double {
        didSet {
            UserDefaults.standard.set(dailyBudget, forKey: "balance")
        }
    }
    @Published var expenses: [Expense] = []
    @Published var deposits: [Deposit] = []
    
    // Gemeinsame UserDefaults für App und Widget
    private let userDefaults = UserDefaults(suiteName: "group.com.dailybudget.app") ?? UserDefaults.standard
    
    init() {
        self.dailyBudget = UserDefaults.standard.double(forKey: "balance")
        loadTransactions()
        filterCurrentMonthTransactions()
    }
    
    struct Expense: Identifiable, Codable {
        let id = UUID()
        let amount: Double
        let description: String
        let date: Date
    }
    
    struct Deposit: Identifiable, Codable {
        let id = UUID()
        let amount: Double
        let description: String
        let date: Date
    }
    
    // Lade alle gespeicherten Transaktionen
    private func loadTransactions() {
        // Lade Ausgaben
        if let expensesData = userDefaults.data(forKey: "allExpenses"),
           let decodedExpenses = try? JSONDecoder().decode([Expense].self, from: expensesData) {
            // Hier werden alle Ausgaben geladen, aber wir filtern später für die Anzeige
        }
        
        // Lade Einzahlungen
        if let depositsData = userDefaults.data(forKey: "allDeposits"),
           let decodedDeposits = try? JSONDecoder().decode([Deposit].self, from: depositsData) {
            // Hier werden alle Einzahlungen geladen, aber wir filtern später für die Anzeige
        }
    }
    
    // Filtere Transaktionen für den aktuellen Monat
    private func filterCurrentMonthTransactions() {
        let calendar = Calendar.current
        let now = Date()
        let currentMonth = calendar.component(.month, from: now)
        let currentYear = calendar.component(.year, from: now)
        
        // Lade alle gespeicherten Ausgaben
        if let expensesData = userDefaults.data(forKey: "allExpenses"),
           let allExpenses = try? JSONDecoder().decode([Expense].self, from: expensesData) {
            
            expenses = allExpenses.filter { expense in
                let expenseMonth = calendar.component(.month, from: expense.date)
                let expenseYear = calendar.component(.year, from: expense.date)
                return expenseMonth == currentMonth && expenseYear == currentYear
            }
        }
        
        // Lade alle gespeicherten Einzahlungen
        if let depositsData = userDefaults.data(forKey: "allDeposits"),
           let allDeposits = try? JSONDecoder().decode([Deposit].self, from: depositsData) {
            
            deposits = allDeposits.filter { deposit in
                let depositMonth = calendar.component(.month, from: deposit.date)
                let depositYear = calendar.component(.year, from: deposit.date)
                return depositMonth == currentMonth && depositYear == currentYear
            }
        }
    }
    
    // Speichere alle Transaktionen persistent
    private func saveAllTransactions() {
        // Lade existierende Transaktionen und füge neue hinzu
        var allExpenses: [Expense] = []
        var allDeposits: [Deposit] = []
        
        // Lade existierende Ausgaben
        if let expensesData = userDefaults.data(forKey: "allExpenses"),
           let existingExpenses = try? JSONDecoder().decode([Expense].self, from: expensesData) {
            allExpenses = existingExpenses
        }
        
        // Lade existierende Einzahlungen
        if let depositsData = userDefaults.data(forKey: "allDeposits"),
           let existingDeposits = try? JSONDecoder().decode([Deposit].self, from: depositsData) {
            allDeposits = existingDeposits
        }
        
        // Füge aktuelle Monatstransaktionen zu den existierenden hinzu (falls sie noch nicht existieren)
        for expense in expenses {
            if !allExpenses.contains(where: { $0.id == expense.id }) {
                allExpenses.append(expense)
            }
        }
        
        for deposit in deposits {
            if !allDeposits.contains(where: { $0.id == deposit.id }) {
                allDeposits.append(deposit)
            }
        }
        
        // Speichere alle Transaktionen
        if let expensesData = try? JSONEncoder().encode(allExpenses) {
            userDefaults.set(expensesData, forKey: "allExpenses")
        }
        
        if let depositsData = try? JSONEncoder().encode(allDeposits) {
            userDefaults.set(depositsData, forKey: "allDeposits")
        }
    }
    
    func addExpense(amount: Double, description: String) {
        let expense = Expense(amount: amount, description: description, date: Date())
        expenses.append(expense)
        saveAllTransactions()
    }
    
    func addDeposit(amount: Double, description: String) {
        let deposit = Deposit(amount: amount, description: description, date: Date())
        deposits.append(deposit)
        saveAllTransactions()
    }
    
    func calculateRemainingBudget() -> Double {
        let totalExpenses = expenses.reduce(0) { $0 + $1.amount }
        let totalDeposits = deposits.reduce(0) { $0 + $1.amount }
        return dailyBudget + totalDeposits - totalExpenses
    }
    
    // Funktion zum manuellen Aktualisieren der Anzeige (z.B. bei Monatswechsel)
    func refreshCurrentMonthTransactions() {
        filterCurrentMonthTransactions()
    }
} 