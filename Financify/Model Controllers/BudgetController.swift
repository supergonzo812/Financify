//
//  BudgetController.swift
//  Financify
//
//  Created by Chris Gonzales on 5/26/20.
//  Copyright © 2020 Chris Gonzales. All rights reserved.
//

import Foundation
import CloudKit

class BudgetController {
    
    var userController: UserController?
    var budgetController: BudgetController?
    var ckManager: CloudKitManager?
    
    var budgets: [Budget] = []
    var expenses: [Expense] = []
    
    func fetchAllBudgetsFromCloudKit(completion: @escaping () -> Void) {
        guard let ckManager = ckManager else {
            completion()
            return
        }
        ckManager.fetchRecordsOf(type: Budget.typeKey, database: CloudKitManager.database) { (records, error) in
            if let error = error {
                print("Error fetching budgets from CloudKit: \(error.localizedDescription)")
            }
            
            guard let records = records else { completion(); return }
            let budgets = records.compactMap({ Budget(cloudKitRecord: $0) })
            
            // need to check ownship of the budget, then save to CoreData
            // Tasks project - verify if budgets already exist
            self.budgets = budgets
            
            completion()
        }
    }
    
    func fetchExpensesFrom(budget: Budget, completion: @escaping () -> Void) {
        let budgetReference = CKRecord.Reference(recordID: budget.cloudKitRecord.recordID,
                                                 action: .deleteSelf)
        let predicate = NSPredicate(format: "budgetReference == %@", budgetReference)
        
        guard let expenseRecordIDs = budget.expenses?.allObjects.compactMap({ ($0 as? Expense)?.ckRecordID }) else {
            completion()
            return
        }
        // check if expenses already exist, and if not add them to the budget (budget.add...)
    }
    
    func add(budgetWithTitle title: String, type: BudgeType, budgetAmount: Double, isShared: Bool, completion: @escaping () -> Void) {
        
    }
    
    func delete(budget: Budget) {
        
    }
    
}


// update relationship
