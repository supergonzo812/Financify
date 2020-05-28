//
//  ExpenseController.swift
//  Financify
//
//  Created by Chris Gonzales on 5/26/20.
//  Copyright © 2020 Chris Gonzales. All rights reserved.
//

import Foundation
import CloudKit

class ExpenseController {
    
    // MARK: - Properties
    var ckManager: CloudKitManager?
    var expenses: [Expense] = []
    
    // MARK: - Methods
    func add(expensetWithDescriptoin description: String, toBudget budget: Budget, amount: Double, id: UUID, user: User, completion: @escaping () -> Void) {
        
        guard let ckManager = ckManager else { return }
        
        let newExpense = Expense(amount: amount,
                                 expenseDescription: description,
                                 id: id,
                                 budget: budget,
                                 user: user)
        
        ckManager.saveRecordToCloudKit(record: newExpense.cloudKitRecord,
                                       database: CloudKitManager.database) { (record, error) in
                                        if let error = error {
                                            NSLog("Error saving budget to CloudKit: \(error.localizedDescription)")
                                        } else {
                                            self.expenses.append(newExpense)
                                        }
        }
        expenses.append(newExpense)
        CoreDataStack.shared.save()
    }
    
    func delete(expense: Expense) {
        guard
            let index = expenses.firstIndex(of: expense) else { return }
        
        self.expenses.remove(at: index)
        
        CloudKitManager.database.delete(withRecordID: expense.ckRecordID) { (_, error) in
            if let error = error {
                NSLog("Error deleting budget from CloudKit: \(error.localizedDescription)")
            }
        }
        CoreDataStack.shared.mainContext.delete(expense)
        CoreDataStack.shared.save()
    }
    
    func totalExpenses(for expenses: [Expense]) -> Double {
        var total: Double = 0
        for expense in expenses{
            total += expense.amount
        }
        return total
    }
}
