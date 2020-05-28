//
//  UserRepresentation.swift
//  Financify
//
//  Created by Chris Gonzales on 5/23/20.
//  Copyright © 2020 Chris Gonzales. All rights reserved.
//

import Foundation

struct UserRepresentation: Codable {
    var firstName: String?
    var funds: Double?
    var lastName: String?
    var id: UUID?
}
