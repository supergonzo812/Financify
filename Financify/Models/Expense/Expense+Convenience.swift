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
    
    static let typeKey = "Expense"
    private static let amountKey = "amount"
    private static let expenseDescriptionKey = "expenseDescription"
    private static let recordIDKey = "id"
    
    
    var cloudKitRecord: CKRecord {
        let recordIDString = id?.uuidString ?? UUID().uuidString
        let record = CKRecord(recordType: Budget.typeKey, recordID: CKRecord.ID(recordName: recordIDString,
                                                                                zoneID: ShareController.sharingZoneID))
        record.setValue(self.amount,
                        forKey: Expense.amountKey)
        record.setValue(self.expenseDescription,
                        forKey: Expense.expenseDescriptionKey)
        record.setValue(self.id,
                        forKey: Expense.recordIDKey)
        return record
    }
    
    var ckRecordID: CKRecord.ID {
        let recordIDString = id?.uuidString ?? UUID().uuidString
        return CKRecord.ID(recordName: recordIDString,
                           zoneID: ShareController.sharingZoneID)
    }
    
    @discardableResult convenience init(amount: Double,
                                        expenseDescription: String,
                                        id: UUID,
                                        budget: Budget,
                                        user: User,
                                        context: NSManagedObjectContext = CoreDataStack.shared.mainContext) {
        self.init(context: context)
        
        self.amount = amount
        self.expenseDescription = expenseDescription
        self.id = id
        self.budget = budget
        self.user = user
    }
    
    @discardableResult convenience init?(expenseRepresentation: ExpenseRepresentation,
                                         budget: Budget,
                                         user: User,
                                         context: NSManagedObjectContext) {
        guard
            let amount = expenseRepresentation.amount,
            let expenseDescription = expenseRepresentation.expenseDescription,
            let id = expenseRepresentation.id else {
                return nil
        }
        
        self.init(amount: amount,
                  expenseDescription: expenseDescription,
                  id: id,
                  budget: budget,
                  user: user)
    }
    
    @discardableResult convenience init?(cloudKitRecord: CKRecord,
                                         budget: Budget,
                                         user: User,
                                         isSharedBudget: Bool = false) {
        
        self.init()
        guard
            let expenseDescription = expenseDescription,
            let id = id else {
                return nil
        }
        
        self.amount = amount
        self.expenseDescription = expenseDescription
        self.id = id
        self.budget = budget
        self.user = user
    }
    
    @discardableResult convenience init?(record: CKRecord) {
        self.init()
        guard
            let amount = record[Expense.amountKey] as? Double,
            let expenseDescription = record[Expense.expenseDescriptionKey] as? String,
            let id = record[Expense.recordIDKey] as? UUID else {
                return nil
        }
        
        self.amount = amount
        self.expenseDescription = expenseDescription
        self.id = id
    }
}
