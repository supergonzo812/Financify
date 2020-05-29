//
//  CategoryTableVC+UICloudSharingControllerDelegate.swift
//  Financify
//
//  Created by Chris Gonzales on 5/29/20.
//  Copyright © 2020 Chris Gonzales. All rights reserved.
//

import UIKit

extension CategoryTableViewController: UICloudSharingControllerDelegate {
   func cloudSharingControllerDidSaveShare(_ csc: UICloudSharingController) {
        print("saved successfully")
    }
     
    func cloudSharingController(_ csc: UICloudSharingController, failedToSaveShareWithError error: Error) {
        print("failed to save: \(error.localizedDescription)")
    }
     
    func itemThumbnailData(for csc: UICloudSharingController) -> Data? {
        nil //You can set a hero image in your share sheet. Nil uses the default.
    }
     
    func itemTitle(for csc: UICloudSharingController) -> String? {
        nil
    }
    
    func cloudSharingControllerDidStopSharing(_ csc: UICloudSharingController) {
        print("stopped")
    }
    
}
