//
//  Expense+Convenience.swift
//  Financify
//
//  Created by Chris Gonzales on 5/23/20.
//  Copyright © 2020 Chris Gonzales. All rights reserved.
//

import Foundation
import CoreData
import CloudKit

extension Expense {
    
    @discardableResult convenience init(amount: Double,
                                        expenseDescription: String,
                                        recordID: UUID,
                                        context: NSManagedObjectContext = CoreDataStack.shared.mainContext) {
        self.init(context: context)
        
        self.amount = amount
        self.expenseDescription = expenseDescription
        self.recordID = recordID
    }
    
    @discardableResult convenience init?(expenseRepresentation: ExpenseRepresentation,
                                         context: NSManagedObjectContext) {
        guard
            let amount = expenseRepresentation.amount,
            let expenseDescription = expenseRepresentation.expenseDescription,
            let recordID = expenseRepresentation.recordID else {
                return nil
        }
        
        self.init(amount: amount,
                  expenseDescription: expenseDescription,
                  recordID: recordID)
    }
    
    @discardableResult convenience init?(cloudKitRecord: CKRecord, isSharedBudget: Bool = false) {
        
        self.init()
        guard
                 let expenseDescription = expenseDescription,
                 let recordID = recordID else {
                     return nil
             }
        
        self.amount = amount
        self.expenseDescription = expenseDescription
        self.recordID = recordID
    }
}
