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
    
    /**
     Initializes a new User object with the provided parameters, and saves the new user object to CloudKit and CoreData.
     
     - Parameters:
        - firstName: The first name of the user.
        - funds:  The total amount of funds available for a user.
        - lastName: The last name of the user.
        - ckManager:  A CloudKitManager object.
        - completion: A completion handler which takes no arguments and returns a Void type.
     
     - Returns:  Returns an error if unable to save the user record to CloudKit.
     */
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
                                        }
                                        completion()
        }
        CoreDataStack.shared.save()
        
        budgetController?.add(budgetWithTitle: <#T##String#>, budgetType: <#T##String#>, budgetAmount: <#T##Double#>, balance: <#T##Double#>, id: <#T##UUID#>, isShared: <#T##Bool#>, user: <#T##User#>, completion: <#T##() -> Void#>)
    }
    
}
