//
//  ExpenseController.swift
//  Financify
//
//  Created by Chris Gonzales on 5/26/20.
//  Copyright © 2020 Chris Gonzales. All rights reserved.
//

import Foundation
import CloudKit

class ExpenseController {
    
    var userController: UserController?
       var budgetController: BudgetController?
       var ckManager: CloudKitManager?
       
       var expenses: [Expense] = []
       
       func add(expensetWithDescriptoin description: String, amount: Double, completion: @escaping () -> Void) {
           
       }
       
       func delete(expense: Expense) {
           
       }
}
