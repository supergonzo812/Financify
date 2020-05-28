//
//  UserController.swift
//  Financify
//
//  Created by Chris Gonzales on 5/26/20.
//  Copyright © 2020 Chris Gonzales. All rights reserved.
//

import Foundation
import CloudKit

class UserController {
    
var budgetController: BudgetController?
   var ckManager: CloudKitManager?
   

   func createUserWith(firstName: String,
               funds: Double,
               lastName: String,
               ckManager: CloudKitManager,
               completion: @escaping () -> Void) {
       let user = User(firstName: firstName,
                       funds: funds,
                       lastName: lastName,
                       id: UUID())
       
       ckManager.saveRecordToCloudKit(record: user.cloudKitRecord,
                                      database: CloudKitManager.database) { (record, error) in
                                       if let error = error {
                                           print("Error saving user record to CloudKit: \(error.localizedDescription)")
                                       } else {
                                           ckManager.saveRecordToCloudKit(record: user.cloudKitRecord,
                                                                          database: CloudKitManager.database)
                                       }
                                       completion()
       }
   }
    
}
