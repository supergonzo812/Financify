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
    
//    var ckRecordID: CKRecord.ID {
//        if !recordID {
//            recordID = CKRecord.ID(recordName: UUID().uuidString)
//        }
//    }
    
    private static let typeKey = "Budget"
    private static let balanceKey = "balance"
    private static let budgetTypeKey = "budgetType"
    
    var cloudKitRecord: CKRecord {
        let record = CKRecord(recordType: Budget.typeKey, recordID: CKRecord.ID(recordName: recordID!.uuidString,
                                                                                zoneID: ShareController.sharingZoneID))

        record.setValue(self.balance, forKey: Budget.balanceKey)
        return record
    }
    
    @discardableResult convenience init(balance: Double,
                                        budgetAmount: Double,
                                        budgetType: String,
                                        isSharedBudget: Bool,
                                        recordID: UUID,
                                        title: String,
                                        context: NSManagedObjectContext = CoreDataStack.shared.mainContext) {
        self.init(context: context)
        
        self.balance = balance
        self.budgetAmount = budgetAmount
        self.budgetType = budgetType
        self.isSharedBudget = isSharedBudget
        self.recordID = recordID
        self.title = title
    }
    
    @discardableResult convenience init?(budgetRepresentation: BudgetRepresentation, context: NSManagedObjectContext) {
        self.init()
        guard
            let balance = budgetRepresentation.balance,
            let budgetAmount = budgetRepresentation.budgetAmount,
            let budgetType = budgetRepresentation.budgetType,
            let recordID = budgetRepresentation.recordID,
            let title = budgetRepresentation.title else {
                return nil
        }
        
        self.init(balance: balance,
                  budgetAmount: budgetAmount,
                  budgetType: budgetType,
                  isSharedBudget: isSharedBudget,
                  recordID: recordID,
                  title: title)
    }
    
    @discardableResult convenience init?(cloudKitRecord: CKRecord, isSharedBudget: Bool = false) {
        
        self.init()
        guard
                 let budgetType = budgetType,
                 let recordID = recordID,
                 let title = title else {
                     return nil
             }
        
        self.balance = balance
        self.budgetAmount = budgetAmount
        self.budgetType = budgetType
        self.recordID = recordID
        self.title = title
        self.isSharedBudget = isSharedBudget
    }
}
