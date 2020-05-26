//
//  OnboardingViewController.swift
//  Financify
//
//  Created by Enrique Gongora on 5/25/20.
//  Copyright © 2020 Chris Gonzales. All rights reserved.
//

import UIKit

class OnboardingViewController: UIViewController, OnboardingPageViewControllerDelegate {
    
    // MARK: - Properties
    weak var onboardingPageViewController: OnboardingPageViewController?
    
    // MARK: - IBOutlets
    @IBOutlet weak var skipButton: UIButton!
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var nextButton: UIButton! {
        didSet {
            nextButton.layer.cornerRadius = 25.0
            nextButton.layer.masksToBounds = true
        }
    }
    
    // MARK: - IBActions
    @IBAction func nextButtonTapped(_ sender: UIButton) {
        if let index = onboardingPageViewController?.currentIndex {
            switch index {
            case 0:
                onboardingPageViewController?.forwardPage()
            case 1:
                onboardingPageViewController?.forwardPage()
            case 2:
                onboardingPageViewController?.forwardPage()
            case 3:
                UserDefaults.standard.set(true, forKey: "hasViewedOnboarding")
                dismiss(animated: true)
            default:
                break
            }
        }
        updateUI()
    }
    
    @IBAction func skipButtonTapped(_ sender: UIButton) {
        UserDefaults.standard.set(true, forKey: "hasViewedOnboarding")
        dismiss(animated: true)
    }
    
    // MARK: - Methods
    func didUpdatePageIndex(currentIndex: Int) {
        updateUI()
    }
    
    func updateUI() {
        if let index = onboardingPageViewController?.currentIndex {
            switch index { // TODO - Add cases for allowing notifications
            case 0:
                nextButton.setTitle("Next", for: .normal)
                skipButton.isHidden = false
            case 1:
                nextButton.setTitle("Allow Notifications", for: .normal)
                skipButton.isHidden = false
            case 2:
                nextButton.setTitle("Next", for: .normal)
            case 3:
                nextButton.setTitle("Get started", for: .normal)
                skipButton.isHidden = true
            default:
                break
            }
            pageControl.currentPage = index
        }
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let pageViewController = segue.destination as? OnboardingPageViewController {
            onboardingPageViewController = pageViewController
            onboardingPageViewController?.onboardingPageViewDelegate = self
        }
    }
}
