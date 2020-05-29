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
    var ckManager = CloudKitManager()
    var expenseController = ExpenseController()
    /// The array of budgets for a single user.
    var budgets: [Budget] = []
    
    // MARK: Public Methods
    /**
     Fetches all the records for 'Budget.typeKey', and sets the returning values to the 'budgets' object on the 'BudgetController' as an array of 'Budget' objects.
     
     - Returns:
     - completion: A completion handler which takes no arguments and returns a Void type.
     */
    func fetchAllBudgetsFromCloudKit(completion: @escaping () -> Void) {
        
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
    /**
     Fetches all the records for 'Expense.typeKey' on the passed in budget, and sets the returning values to the 'expenses' object on the 'ExpenseViewController' as an array of 'Expense' objects.
     
     - Parameters:
     -budget: A 'Budget' object
     -completion: A completion handler which takes no arguments and returns a Void type.
     */
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
    /**
     Creates a new 'Budget' object with the provided parameters.  Then saves the new 'Budget' object to CloudKit as well as CoreData, and appends the new 'Budget' object to the 'budgets' array on the 'BudgetController'.
     
     - Parameters:
     - Parameter budgetWithTitle:  A String value describing the budget.
     - Parameter budgetType: A String value which describes the classification of the budget (i.e. utilities, insurance)
     - Parameter budgetAmount: A Double value representing the dollar amount allocated to this budget.
     - Parameter balance:  A Double value representing the remaining balance.
     - Parameter id:  A UUID value representing the budget identifier.
     - Parameter isShared:  A Bool indicating if the created budget is shared.
     - Parameter user: A User object which represents the individual creating the budget.
     
     - Returns:
        completion: A completion handler which takes no arguments and returns a Void type.
     */
    func add(budgetWithTitle title: String, budgetType: String, budgetAmount: Double, balance: Double, id: UUID, isShared: Bool, user: User, completion: @escaping () -> Void) {
        
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
                                            completion()
                                        } else {
                                            self.budgets.append(budget)
                                            CoreDataStack.shared.save()
                                            completion()
                                        }
        }
    }
    /**
     Verifies the passed 'Budget' object exists in the 'budgets' array then deletes the passed in object from CloudKit, from CoreDate, and from the 'budgets' array.
     
     - Parameters:
     - budget: A Budget object.
     */
    func delete(budget: Budget) {
        guard
            let index = budgets.firstIndex(of: budget) else { return }
        
        CloudKitManager.database.delete(withRecordID: budget.ckRecordID) { (_, error) in
            if let error = error {
                NSLog("Error deleting budget from CloudKit: \(error.localizedDescription)")
            }
        }
        CoreDataStack.shared.mainContext.delete(budget)
        CoreDataStack.shared.save()
        self.budgets.remove(at: index)
    }
    /**
     Returns the sum of the 'budget.budgetAmount' values for the passed in 'Budget' object.
     
     */
    func totalForAllBudgets(_ budgets: [Budget]) -> Double {
        var total: Double = 0
        for budget in budgets{
            total += budget.budgetAmount
        }
        return total
    }
    
    // MARK: - Private Methods
    
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

