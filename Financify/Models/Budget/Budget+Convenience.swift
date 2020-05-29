//
//  Budget+Convenience.swift
//  Financify
//
//  Created by Chris Gonzales on 5/23/20.
//  Copyright © 2020 Chris Gonzales. All rights reserved.
//

import Foundation
import CoreData
import CloudKit

extension Budget {
    
    static let typeKey = "Budget"
    private static let balanceKey = "balance"
    private static let budgetAmountKey = "budgetAmount"
    private static let budgetTypeKey = "budgetType"
    private static let isSharedKey = "isSharedBudget"
    private static let recordIDKey = "id"
    static let titleKey = "title"
    
    var totalRemaining: Double {
        guard let expenses = expenses?.array as? [Expense] else { return balance }
        let totalSpent = expenses.reduce(0) { (result, expense) -> Double in
            result + expense.amount
        }
        return balance - totalSpent
    }
    
    var cloudKitRecord: CKRecord {
        let idString = id?.uuidString ?? UUID().uuidString
        let record = CKRecord(recordType: Budget.typeKey, recordID: CKRecord.ID(recordName: idString,
                                                                                zoneID: ShareController.sharingZoneID))
        record.setValue(self.balance,
                        forKey: Budget.balanceKey)
        record.setValue(self.budgetAmount,
                        forKey: Budget.budgetAmountKey)
        record.setValue(self.budgetType,
                        forKey: Budget.budgetTypeKey)
        record.setValue(self.isSharedBudget,
                        forKey: Budget.isSharedKey)
        record.setValue(self.title,
                        forKey: Budget.titleKey)
        return record
    }
    
    var ckRecordID: CKRecord.ID {
        let recordIDString = id?.uuidString ?? UUID().uuidString
        return CKRecord.ID(recordName: recordIDString,
                           zoneID: ShareController.sharingZoneID)
    }
    /// TODO:  Create initialize which sets the starting balance to the budgetAmount.
    
    @discardableResult convenience init(balance: Double ,
                                        budgetAmount: Double,
                                        budgetType: String,
                                        isSharedBudget: Bool,
                                        id: UUID,
                                        title: String,
                                        user: User,
                                        context: NSManagedObjectContext = CoreDataStack.shared.mainContext) {
        self.init(context: context)
        
        self.balance = balance
        self.budgetAmount = budgetAmount
        self.budgetType = budgetType
        self.isSharedBudget = isSharedBudget
        self.id = id
        self.title = title
        self.user = user
    }
    
    @discardableResult convenience init?(budgetRepresentation: BudgetRepresentation,
                                         context: NSManagedObjectContext) {
        self.init()
        guard
            let balance = budgetRepresentation.balance,
            let budgetAmount = budgetRepresentation.budgetAmount,
            let budgetType = budgetRepresentation.budgetType,
            let id = budgetRepresentation.id,
            let title = budgetRepresentation.title,
            let user = user else {
                return nil
        }
        
        self.init(balance: balance,
                  budgetAmount: budgetAmount,
                  budgetType: budgetType,
                  isSharedBudget: isSharedBudget,
                  id: id,
                  title: title,
                  user: user)
    }
    
    @discardableResult convenience init?(cloudKitRecord: CKRecord) {
        self.init()
        guard
            let budgetType = budgetType,
            let id = id,
            let title = title else {
                return nil
        }
        
        self.balance = balance
        self.budgetAmount = budgetAmount
        self.budgetType = budgetType
        self.id = id
        self.title = title
        self.isSharedBudget = isSharedBudget
        self.user = user
    }
}

func == (lhs: Budget, rhs: Budget) -> Bool {
    lhs.id == rhs.id
}
