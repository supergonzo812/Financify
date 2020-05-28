//
//  CategoryTableViewController.swift
//  Financify
//
//  Created by Enrique Gongora on 5/26/20.
//  Copyright © 2020 Chris Gonzales. All rights reserved.
//

import UIKit

class CategoryTableViewController: UITableViewController {
    
    // MARK: - Properties
    var cloudController = CloudKitManager()
    var userController = UserController()
    var budgetController = BudgetController()
    
    // MARK: - IBActions
    
    @IBAction func addButtonTapped(_ sender: UIBarButtonItem) {
//        budgetController.add(budgetWithTitle: <#T##String#>, type: <#T##BudgeType#>, budgetAmount: <#T##Double#>, budgetType: <#T##String#>, balance: <#T##Double#>, recordID: <#T##UUID#>, isShared: <#T##Bool#>, user: <#T##User#>, completion: <#T##() -> Void#>)
    }
    
    // MARK: - View LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if UserDefaults.standard.bool(forKey: "hasViewedOnboarding") {
            return
        }
        let storyboard = UIStoryboard(name: "Onboarding", bundle: nil)
        if let onboardingViewController = storyboard.instantiateViewController(identifier: "OnboardingViewController") as? OnboardingViewController {
            onboardingViewController.modalPresentationStyle = .fullScreen
            present(onboardingViewController, animated: true)
        }
    }
    
    // MARK: - Table view data source
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return budgetController.budgets.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "CategoryCell") else { return UITableViewCell()}
        cell.textLabel?.text = budgetController.budgets[indexPath.row].budgetType
        cell.detailTextLabel?.text = "$\(budgetController.budgets[indexPath.row].balance)"
        return cell
    }
}
