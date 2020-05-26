//
//  OnboardingContentViewController.swift
//  Financify
//
//  Created by Enrique Gongora on 5/25/20.
//  Copyright © 2020 Chris Gonzales. All rights reserved.
//

import UIKit

class OnboardingContentViewController: UIViewController {
    
    // MARK: - Properties
    var index = 0
    var heading = ""
    var subHeading = ""
    var imageFile = ""
    
    // MARK: - IBOutlets
    @IBOutlet weak var headingLabel: UILabel! {
        didSet {
            headingLabel.numberOfLines = 0
        }
    }
    @IBOutlet weak var subHeadingLabel: UILabel! {
        didSet {
            subHeadingLabel.numberOfLines = 0
        }
    }
    @IBOutlet weak var contentImageView: UIImageView!
    
    // MARK: - View LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        headingLabel.text = heading
        subHeadingLabel.text = subHeading
        contentImageView.image = UIImage(named: imageFile)
    }
}
