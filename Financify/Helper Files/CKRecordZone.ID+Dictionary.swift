//
//  CKRecordZone.ID+Dictionary.swift
//  Financify
//
//  Created by Chris Gonzales on 5/25/20.
//  Copyright © 2020 Chris Gonzales. All rights reserved.
//

import CloudKit

extension CKRecordZone.ID {
    
    private static var zoneNameKey: String { "zoneName" }
    private static var ownerNameKey: String { "ownerName" }

    var dictionaryRepresentation: [String: String] {
        [Self.zoneNameKey: zoneName, Self.ownerNameKey: ownerName]
    }
    
    convenience init?(dictionary: [String: String]) {
        guard let zoneName = dictionary[Self.zoneNameKey],
            let ownerName = dictionary[Self.ownerNameKey] else { return nil }

        self.init(zoneName: zoneName, ownerName: ownerName)
    }
}
