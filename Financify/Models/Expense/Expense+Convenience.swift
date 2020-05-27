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
        private static let recordIDKey = "recordID"
       
        
        var cloudKitRecord: CKRecord {
            let recordIDString = recordID?.uuidString ?? UUID().uuidString
            let record = CKRecord(recordType: Budget.typeKey, recordID: CKRecord.ID(recordName: recordIDString,
                                                                                    zoneID: ShareController.sharingZoneID))
            record.setValue(self.amount,
                            forKey: Expense.amountKey)
            record.setValue(self.expenseDescription,
                            forKey: Expense.expenseDescriptionKey)
            record.setValue(self.recordID,
                            forKey: Expense.recordIDKey)
            return record
        }
        
        var ckRecordID: CKRecord.ID {
            let recordIDString = recordID?.uuidString ?? UUID().uuidString
            return CKRecord.ID(recordName: recordIDString,
                               zoneID: ShareController.sharingZoneID)
        }
        
        @discardableResult convenience init(amount: Double,
                                            expenseDescription: String,
                                            recordID: UUID,
                                            budget: Budget,
                                            user: User,
                                            context: NSManagedObjectContext = CoreDataStack.shared.mainContext) {
            self.init(context: context)
            
            self.amount = amount
            self.expenseDescription = expenseDescription
            self.recordID = recordID
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
                let recordID = expenseRepresentation.recordID else {
                    return nil
            }
            
            self.init(amount: amount,
                      expenseDescription: expenseDescription,
                      recordID: recordID,
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
                     let recordID = recordID else {
                         return nil
                 }
            
            self.amount = amount
            self.expenseDescription = expenseDescription
            self.recordID = recordID
            self.budget = budget
            self.user = user
        }
    }
