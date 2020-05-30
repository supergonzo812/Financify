//
//  OnboardingPageViewController.swift
//  Financify
//
//  Created by Enrique Gongora on 5/25/20.
//  Copyright © 2020 Chris Gonzales. All rights reserved.
//

import UIKit

protocol OnboardingPageViewControllerDelegate: AnyObject {
    func didUpdatePageIndex(currentIndex: Int)
}

class OnboardingPageViewController: UIPageViewController, UIPageViewControllerDataSource, UIPageViewControllerDelegate {
    
    // MARK: - Properties
    weak var onboardingPageViewDelegate: OnboardingPageViewControllerDelegate?
    var pageHeadings = ["Welcome to Financify", "Automatic Updating", "Allow Notifications", "You're all done!"]
    var pageImages = ["Financify Onboarding Logo", "iCloud Logo", "Notification", "You're All Done"]
    var pageSubHeadings = ["We’ll help make it easier for you to keep track of your spendings and earnings.",
                           "With iCloud, we'll update all your information with no work required on your part.",
                           "Let us keep you up to date with your finances so you never miss a beat",
                           "Setup is now complete. Let's take you to the app!"]
    var currentIndex = 0
    
    // MARK: - Methods
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let index = (viewController as? OnboardingContentViewController)?.index else { return UIViewController() }
        var newIndex = index
        newIndex -= 1
        return contentViewController(at: index)
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let index = (viewController as? OnboardingContentViewController)?.index else { return UIViewController() }
        var newIndex = index
        newIndex += 1
        return contentViewController(at: index)
    }
    
    func contentViewController(at index: Int) -> OnboardingContentViewController? {
        if index < 0 || index >= pageHeadings.count {
            return nil
        }
        let storyboard = UIStoryboard(name: "Onboarding", bundle: nil)
        if let pageContentViewController = storyboard.instantiateViewController(identifier: "OnboardingContentViewController") as? OnboardingContentViewController {
            pageContentViewController.imageFile = pageImages[index]
            pageContentViewController.heading = pageHeadings[index]
            pageContentViewController.subHeading = pageSubHeadings[index]
            pageContentViewController.index = index
            return pageContentViewController
        }
        return nil
    }
    
    func forwardPage() {
        currentIndex += 1
        if let nextViewController = contentViewController(at: currentIndex) {
            setViewControllers([nextViewController], direction: .forward, animated: true)
        }
    }
    
    func pageViewController(_ pageViewController: UIPageViewController,
                            didFinishAnimating finished: Bool,
                            previousViewControllers: [UIViewController],
                            transitionCompleted completed: Bool) {
        if completed {
            if let contentViewController = pageViewController.viewControllers?.first as? OnboardingContentViewController {
                currentIndex = contentViewController.index
                onboardingPageViewDelegate?.didUpdatePageIndex(currentIndex: currentIndex)
            }
        }
    }
    
    // MARK: - View LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        dataSource = self
        delegate = self
        if let startingViewController = contentViewController(at: 0) {
            setViewControllers([startingViewController], direction: .forward, animated: true)
        }
    }
}
