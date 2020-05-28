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
    var user: User?
    var categoryArray: [String] = ["Expenses", "Bills", "Income", "Budget"]
    
    // MARK: - IBActions
    @IBAction func addUserTapped(_ sender: UIBarButtonItem) {
        let alert = UIAlertController(title: "Create New User", message: "Enter your first and last name and your budget total", preferredStyle: .alert)
        alert.addTextField()
        alert.addTextField()
        alert.addTextField()
        
        alert.textFields![0].placeholder = "First Name"
        alert.textFields![1].placeholder = "Last Name"
        alert.textFields![2].placeholder = "Budget Total"
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Enter", style: .default, handler: { [weak self, weak alert] _ in
            guard let firstName = alert?.textFields?[0].text else { return }
            guard let lastName = alert?.textFields?[1].text else { return }
            guard let budget = alert?.textFields?[2].text, let totalBudget = Double(budget) else { return }
            self?.createUser(firstName, lastName, totalBudget)
        }))
        self.present(alert, animated: true)
    }
    
    // MARK: - Methods
    func createUser(_ firstName: String, _ lastName: String, _ funds: Double) {
        let id = UUID()
        self.user = User(firstName: firstName, funds: funds, lastName: lastName, id: id)
        userController.createUserWith(firstName: firstName, funds: funds, lastName: lastName, ckManager: cloudController) {
            print("User created")
            return
        }
    }
    
    func totalForAllBudgets(_ budgets: [Budget]) -> Double {
        var total: Double = 0
        for budget in budgets{
            total += budget.budgetAmount
        }
        return total
    }
    
    // MARK: - View LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.reloadData()
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
        return categoryArray.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CategoryCell", for: indexPath)
        cell.textLabel?.text = categoryArray[indexPath.row]
        cell.detailTextLabel?.text = "$0.00"
        return cell
    }
}
