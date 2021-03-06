//
//  ExpenseRepresentation.swift
//  Financify
//
//  Created by Chris Gonzales on 5/23/20.
//  Copyright © 2020 Chris Gonzales. All rights reserved.
//

import Foundation

struct ExpenseRepresentation: Codable {
    var amount: Double?
    var expenseDescription: String?
    var id: UUID?
}
