//
//  Notifications.swift
//  Financify
//
//  Created by Chris Gonzales on 5/24/20.
//  Copyright © 2020 Chris Gonzales. All rights reserved.
//

import Foundation

extension Notification.Name {
    static var budgetsWereSet = Notification.Name("budgetsWereSet")
    static var failedToSaveShare = Notification.Name("failedToSaveShare")
    static var didSaveShare = Notification.Name("didSaveShare")
    static var didAcceptShare = Notification.Name("didAcceptShare")
}
