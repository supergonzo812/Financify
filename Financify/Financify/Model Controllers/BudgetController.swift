//
//  BudgetController.swift
//  Financify
//
//  Created by Chris Gonzales on 5/26/20.
//  Copyright © 2020 Chris Gonzales. All rights reserved.
//

import Foundation
import CloudKit

class BudgetController {
    
    let ckManager: CloudKitManager?
    
    func fetchAllBudgetsFromCloudKit(completion: @escaping () -> Void) {
        guard let ckManager = ckManager else { return }
        
        ckManager.fetchRecordsOf(type: Budget., database: <#T##CKDatabase#>, completion: <#T##([CKRecord]?, Error?) -> Void#>)
    }
}
