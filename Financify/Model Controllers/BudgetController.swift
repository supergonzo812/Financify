//
//  BudgetController.swift
//  Financify
//
//  Created by Chris Gonzales on 5/26/20.
//  Copyright © 2020 Chris Gonzales. All rights reserved.
//

import Foundation
import CloudKit
import CoreData

class BudgetController {
    
    
    // MARK: - Properties
    
    var userController: UserController?
    var budgetController: BudgetController?
    var ckManager: CloudKitManager?
    var expenseController = ExpenseController()
    // should expenseController be an instance or optional passed in by the VC.
    
    var budgets: [Budget] = []
    
    // MARK: Public Methods
    
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
            
            self.budgets = budgets
            
            completion()
        }
    }
    
    func fetchExpensesFrom(budget: Budget, completion: @escaping () -> Void) {
        let budgetReference = CKRecord.Reference(recordID: budget.cloudKitRecord.recordID,
                                                 action: .deleteSelf)
        let predicate = NSPredicate(format: "budgetReference == %@", budgetReference)
        
        guard let expenseRecordIDs = budget.expenses?.allObjects.compactMap({ ($0 as? Expense)?.ckRecordID }) else {
            completion(); return
        }
        
        let predicate2 = NSPredicate(format: "NOT(recordID IN %@", expenseRecordIDs)
        
        let compoundPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: [predicate,
        predicate2])
       
        guard let ckManager = ckManager
         else {
            completion(); return
        }
        
        ckManager.fetchRecordsOf(type: Expense.typeKey,
                                 predicate: compoundPredicate,
                                 database: CloudKitManager.database) { (expenses, error) in
                                    if let error = error {
                                        NSLog("Error fetching expenses from Cloudkit: \(error)")
                                    }
                                    
                                    guard let fetchedExpenses = expenses else {
                                        completion(); return
                                    }
                                    
                                    let expenses = fetchedExpenses.compactMap( {Expense(record: $0)} )
                                    
                                    self.expenseController.expenses.append(contentsOf: expenses)
        }
    }
    
    func add(budgetWithTitle title: String, type: String, budgetAmount: Double, budgetType: String, balance: Double, id: UUID, isShared: Bool, user: User, completion: @escaping () -> Void) {
        
        guard let ckManager = ckManager else { return }
        
        let budget = Budget(balance: balance,
                            budgetAmount: budgetAmount,
                            budgetType: budgetType,
                            isSharedBudget: isShared,
                            id: id,
                            title: title,
                            user: user)
        
        ckManager.saveRecordToCloudKit(record: budget.cloudKitRecord,
                                       database: CloudKitManager.database) { (record, error) in
                                        if let error = error {
                                            NSLog("Error saving budget to CloudKit: \(error.localizedDescription)")
                                        } else {
                                            self.budgets.append(budget)
                                        }
        }
        CoreDataStack.shared.save()
    }
    
    func delete(budget: Budget) {
        guard
            let index = budgets.firstIndex(of: budget) else { return }
        
        self.budgets.remove(at: index)
        
        CloudKitManager.database.delete(withRecordID: budget.ckRecordID) { (_, error) in
            if let error = error {
                NSLog("Error deleting budget from CloudKit: \(error.localizedDescription)")
            }
        }
        CoreDataStack.shared.mainContext.delete(budget)
        CoreDataStack.shared.save()
    }
    
    private func updateBudgets(with representations: [BudgetRepresentation]) throws {
        
        let budgetsWithID = representations.filter( { $0.id != nil})
        let budgetIDsToFetch = budgetsWithID.compactMap { UUID(uuidString: $0.id!.uuidString) }
        
        let representationByID = Dictionary(uniqueKeysWithValues: zip(budgetIDsToFetch, budgetsWithID))
        
        var budgetsToCreate = representationByID
        
        let fetchRequest: NSFetchRequest<Budget> = Budget.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "recordID IN %@", budgetIDsToFetch)
        
        let context = CoreDataStack.shared.container.newBackgroundContext()
        
        context.performAndWait {
            do{
                let existingBudget = try context.fetch(fetchRequest)
                
                for budget in existingBudget {
                    guard
                        let id = budget.id,
                        let representation = representationByID[id] else {
                        continue
                    }
                    self.update(budget: budget, with: representation)
                    
                    budgetsToCreate.removeValue(forKey: id)
                }
                
                for representation in budgetsToCreate.values {
                    Budget(budgetRepresentation: representation,
                           context: context)
                }
                
            } catch {
                NSLog("Error fetching budgets for UUIDs: \(error)")
            }
        }
        
        CoreDataStack.shared.save(context: context)
    }
    
    private func update(budget: Budget, with budgetRepresentation: BudgetRepresentation) {
        
        guard
            let balance = budgetRepresentation.balance,
            let budgetAmount = budgetRepresentation.budgetAmount,
            let budgetType = budgetRepresentation.budgetType,
            let id = budgetRepresentation.id,
            let title = budgetRepresentation.title else { return }
        
        budget.balance = balance
        budget.budgetAmount = budgetAmount
        budget.budgetType = budgetType
        budget.isSharedBudget = budgetRepresentation.isSharedBudget
        budget.id = id
        budget.title = title
    }
}

