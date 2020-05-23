//
//  Budget+Convenience.swift
//  Financify
//
//  Created by Chris Gonzales on 5/23/20.
//  Copyright © 2020 Chris Gonzales. All rights reserved.
//

import Foundation
import CoreData

extension Budget {
    
    @discardableResult convenience init(balance: Double,
                                        budgetAmount: Double,
                                        budgetType: String,
                                        recordID: UUID,
                                        context: NSManagedObjectContext = CoreDataStack.shared.mainContext) {
        self.init(context: context)
        
        self.balance = balance
        self.budgetAmount = budgetAmount
        self.budgetType = budgetType
        self.recordID = recordID
    }
    
    @discardableResult convenience init?(budgetRepresentation: BudgetRepresentation, context: NSManagedObjectContext) {
        guard
            let balance = budgetRepresentation.balance,
            let budgetAmount = budgetRepresentation.budgetAmount,
            let budgetType = budgetRepresentation.budgetType,
            let recordID = budgetRepresentation.recordID else {
                return nil
        }
        
        self.init(balance: balance,
                  budgetAmount: budgetAmount,
                  budgetType: budgetType,
                  recordID: recordID)
    }
}
