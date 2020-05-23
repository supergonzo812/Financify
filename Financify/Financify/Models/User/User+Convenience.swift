//
//  User+Convenience.swift
//  Financify
//
//  Created by Chris Gonzales on 5/23/20.
//  Copyright © 2020 Chris Gonzales. All rights reserved.
//

import Foundation
import CoreData

extension User {
    
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
}
