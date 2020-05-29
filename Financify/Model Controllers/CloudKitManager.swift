//
//  CloudKitManager.swift
//  Financify
//
//  Created by Chris Gonzales on 5/26/20.
//  Copyright © 2020 Chris Gonzales. All rights reserved.
//

import Foundation
import CloudKit

class CloudKitManager {
    
    static let database = CKContainer.default().privateCloudDatabase
    
    func saveRecordToCloudKit(record: CKRecord, database: CKDatabase, completion: @escaping (CKRecord?, Error?) -> Void = { (_, _ ) in }) {
        
        let modifyRecordsOp = CKModifyRecordsOperation(recordsToSave: [record])
        
        // This allows information to be changed
        modifyRecordsOp.savePolicy = .changedKeys
        
        // This gets called once everything gets saved
        modifyRecordsOp.modifyRecordsCompletionBlock = { (records, _, error) in
            if let error = error {
                NSLog("Error saving entry to CloudKit: \(error)")
                return
            }
            completion(records?.first, error)
        }
        database.add(modifyRecordsOp)
    }
    func deleteRecordFromCloudKitWith(recordID: CKRecord.ID, database: CKDatabase, completion: @escaping (Error?) -> Void) {
        database.delete(withRecordID: recordID) { (_, error) in
            completion(error)
        }
    }
    
    func fetchRecordsOf(type: String, predicate: NSPredicate = NSPredicate(value: true), database: CKDatabase, completion: @escaping ([CKRecord]?, Error?) -> Void) {
        
        let query = CKQuery(recordType: type, predicate: predicate)
        
        database.perform(query, inZoneWith: nil, completionHandler: completion)
        
    }
    
}
