//
//  User+Convenience.swift
//  Financify
//
//  Created by Chris Gonzales on 5/23/20.
//  Copyright © 2020 Chris Gonzales. All rights reserved.
//

import Foundation
import CoreData
import CloudKit

extension User {
    
    private static let typeKey = "User"
    private static let firstNameKey = "firstName"
    private static let fundsKey = "funds"
    private static let lastName = "lastName"
    private static let recordIDKey = "recordID"
    
    var cloudKitRecord: CKRecord {
        let recordIDString = recordID?.uuidString ?? UUID().uuidString
        let record = CKRecord(recordType: User.typeKey,
                              recordID: CKRecord.ID(recordName: recordIDString,
                                                    zoneID: ShareController.sharingZoneID))
        record.setValue(self.firstName,
                        forKey: User.firstNameKey)
        record.setValue(self.funds,
                        forKey: User.fundsKey)
        record.setValue(self.lastName,
                        forKey: User.lastName)
        record.setValue(self.recordID,
                        forKey: User.recordIDKey)
        return record
    }
    
    var ckRecordID: CKRecord.ID {
        let recordIDString = recordID?.uuidString ?? UUID().uuidString
        return CKRecord.ID(recordName: recordIDString,
                           zoneID: ShareController.sharingZoneID)
    }
    
    @discardableResult convenience init(firstName: String,
                                        funds: Double,
                                        lastName: String,
                                        recordID: UUID,
                                        context: NSManagedObjectContext = CoreDataStack.shared.mainContext) {
        self.init(context: context)
        
        self.firstName = firstName
        self.funds = funds
        self.lastName = lastName
        self.recordID = recordID
    }
    
    @discardableResult convenience init?(userRepresentation: UserRepresentation,
                                         context: NSManagedObjectContext) {
        guard
            let firstName = userRepresentation.firstName,
            let funds = userRepresentation.funds,
            let lastName = userRepresentation.lastName,
            let recordID = userRepresentation.recordID
            else {
                return nil
        }
        
        self.init(firstName: firstName,
                  funds: funds,
                  lastName: lastName,
                  recordID: recordID)
    }
    
    @discardableResult convenience init?(cloudKitRecord: CKRecord, isSharedBudget: Bool = false) {
        
        self.init()
        guard
            let firstName = firstName,
            let lastName = lastName,
            let recordID = recordID else {
                return nil
        }
        
        self.firstName = firstName
        self.funds = funds
        self.lastName = lastName
        self.recordID = recordID
    }
}
