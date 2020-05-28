//
//  BudgetRepresentation.swift
//  Financify
//
//  Created by Chris Gonzales on 5/23/20.
//  Copyright © 2020 Chris Gonzales. All rights reserved.
//

import Foundation

struct BudgetRepresentation: Codable {
    var balance: Double?
    var budgetAmount: Double?
    var budgetType: String?
    var isSharedBudget: Bool
    var id: UUID?
    var title: String?
}
