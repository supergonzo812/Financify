//
//  ShareController.swift
//  Financify
//
//  Created by Chris Gonzales on 5/24/20.
//  Copyright © 2020 Chris Gonzales. All rights reserved.
//

import UIKit
import CloudKit

class ShareController: NSObject {
    
    // MARK: - Properties
    
    static var sharingZoneID: CKRecordZone.ID = {
        return CKRecordZone.ID(zoneName: "ShareZone", ownerName: CKCurrentUserDefaultName)
    }()
    
    
    
    private var userToSave: User?
    private var budgetToSave: Budget?
    private var expenseToSave: Expense?
    
    private (set) var sharedBudgets: [Budget] = [] {
        didSet {
            DispatchQueue.main.async {
                NotificationCenter.default.post(name: .budgetsWereSet, object: self)
            }
        }
    }
    
    // MARK: - Initializer
    
    override init() {
        super.init()
        createShareZone()
        self.fetchAllSharedBudgets()
    }
    
    // MARK: - New Shares
    
    func createCloudSharingController(with budget: Budget) -> UICloudSharingController {
        
        self.budgetToSave = budget
        
        let share = CKShare(rootRecord: budget.cloudKitRecord,
                            shareID: budget.cloudKitRecord.recordID)
        
        share.setValue(budget.title, forKey: CKShare.SystemFieldKey.title)
        share.setValue(kCFBundleIdentifierKey, forKey: CKShare.SystemFieldKey.shareType)
        
        let controller = UICloudSharingController { (controller, completion) in
            self.share(rootRecord: budget.cloudKitRecord, completion: completion)
        }
        
        controller.availablePermissions = []
        controller.delegate = self
        
        return controller
    }
    
    func share(rootRecord: CKRecord, completion: @escaping (CKShare?, CKContainer?, Error?) -> Void) {
        
        let shareRecord = CKShare(rootRecord: rootRecord)
        let recordsToSave = [rootRecord, shareRecord]
        
        let operation = CKModifyRecordsOperation(recordsToSave: recordsToSave, recordIDsToDelete: [])
        operation.savePolicy = .changedKeys
        
        operation.perRecordCompletionBlock = { (record, error) in
            if let error = error {
                print("CloudKit error: \(error)")
            }
        }
        
        operation.modifyRecordsCompletionBlock = { (savedRecords, deletedRecordIDs, error) in
            if let error = error {
                completion(nil, nil, error)
            } else {
                completion(shareRecord, CKContainer.default(), nil)
            }
        }
        
        CKContainer.default().privateCloudDatabase.add(operation)
    }
    
    // MARK: - Set Up
    
    func createShareZone() {
        
        guard !UserDefaults.standard.bool(forKey: "sharingZoneHasBeenCreated") else { return }
        
        let shareZone = CKRecordZone(zoneID: ShareController.sharingZoneID)
        
        let modifyZoneOperation = CKModifyRecordZonesOperation(recordZonesToSave: [shareZone], recordZoneIDsToDelete: nil)
        
        modifyZoneOperation.modifyRecordZonesCompletionBlock =  { (_, _, error) in
            
            if let error = error {
                NSLog("Error creating sharing zone: \(error)")
            }
            
            UserDefaults.standard.set(true, forKey: "sharingZoneHasBeenCreated")
        }
        
        CKContainer.default().privateCloudDatabase.add(modifyZoneOperation)
    }
    
    // MARK: - Share Fetching
    
    func fetchAllSharedBudgets(completion: @escaping (() -> Void) = { }) {
        
        let predicate = NSPredicate(value: true)
        let query = CKQuery(recordType: "Budget", predicate: predicate)
        
        guard let zoneIDDictionaries = Self.loadSavedZoneIDs(),
            zoneIDDictionaries.count > 0 else {
                completion()
                return
        }
        
        let zoneIDs = zoneIDDictionaries.compactMap({ CKRecordZone.ID(dictionary: $0) })
        
        let group = DispatchGroup()
        
        var sharedBudgets: [CKRecord] = []
        
        for zoneID in zoneIDs {
            
            group.enter()
            
            CKContainer.default().sharedCloudDatabase.perform(query, inZoneWith: zoneID) { (budgets, error) in
                
                if let error = error {
                    NSLog("Error fetching shared budgets: \(error)")
                }
                
                guard let budgets = budgets else { return }
                
                sharedBudgets.append(contentsOf: budgets)
                
                group.leave()
            }
            
        }
        
        group.notify(queue: DispatchQueue.main) {
            self.sharedBudgets = sharedBudgets.compactMap({
                Budget(cloudKitRecord: $0, isSharedBudget: true)
                
            })
            completion()
        }
    }
}

// MARK: - Persisting Shared Zones
extension ShareController {
    
    static var zoneIDFileURL: URL? {
        guard let documentsDir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            return nil
        }
        
        return documentsDir.appendingPathComponent("savedZoneIDs")
    }
    
    static func loadSavedZoneIDs() -> [[String: String]]? {
        
        guard let zoneIDFileURL = zoneIDFileURL else { return nil }
        
        do {
            let savedZoneIDsData = try Data(contentsOf: zoneIDFileURL)
            
            let zoneIDs = try JSONSerialization.jsonObject(with: savedZoneIDsData, options: .allowFragments) as? [[String: String]]
            
            return zoneIDs
        } catch {
            NSLog("Error loading saved zone IDs: \(error)")
            return nil
        }
    }
    
    static func saveZoneIDs(_ zoneIDs: [[String: String]]) {
        
        guard let zoneIDFileURL = zoneIDFileURL else { return }
        
        do {
            let zoneIDsData = try JSONSerialization.data(withJSONObject: zoneIDs, options: .fragmentsAllowed)
            
            try zoneIDsData.write(to: zoneIDFileURL)
        } catch {
            NSLog("Error saving zone IDs: \(error)")
        }
    }
}

extension ShareController: UICloudSharingControllerDelegate {
    
    func cloudSharingController(_ csc: UICloudSharingController,
                                failedToSaveShareWithError error: Error) {
        NSLog("Error saving share: \(error)")
        NotificationCenter.default.post(name: .failedToSaveShare, object: csc, userInfo: ["error": error])
    }
    
    func cloudSharingControllerDidSaveShare(_ csc: UICloudSharingController) {
        NotificationCenter.default.post(name: .didSaveShare, object: csc)
    }
    
    func itemTitle(for csc: UICloudSharingController) -> String? {
        budgetToSave?.title
    }
}
