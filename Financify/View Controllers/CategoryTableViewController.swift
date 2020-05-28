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
    var shareController = ShareController()
    
    var budget = [Budget]()
    
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
    
    @IBAction func addButtonTapped(_ sender: UIBarButtonItem) {
        let alert = UIAlertController(title: "Create New Budget", message: "Enter Budget Name, Type, & Amount", preferredStyle: .alert)
        alert.addTextField()
        alert.addTextField()
        alert.addTextField()
        
        alert.textFields![0].placeholder = "Budget Name"
        alert.textFields![1].placeholder = "Budget Type"
        alert.textFields![2].placeholder = "Budget Amount"
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Enter", style: .default, handler: { [weak self, weak alert] _ in
            
        }))
        self.present(alert, animated: true)
        
    }
    
    // MARK: - Methods
    func createUser(_ firstName: String, _ lastName: String, _ funds: Double) {
        userController.createUserWith(firstName: firstName, funds: funds, lastName: lastName, ckManager: cloudController) {
            print("User created")
            return
        }
    }
    
    func createBudget(_ budgetWithTitle: String, _ type: String, _ budgetAmount: Double) {
        budgetController.add(budgetWithTitle: budgetWithTitle, type: type, budgetAmount: budgetAmount, budgetType: <#T##String#>, balance: 0.00, id: <#T##UUID#>, isShared: true, user: <#T##User#>) {
            print("Budget Created")
            return
        }
        // BudgetWithTitle - The Budget Name
        // Type - ???
        // BudgetAmount -
        // BudgetType -
        // Balance - $0
        // 
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
        return budgetController.budgets.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "CategoryCell") else { return UITableViewCell()}
        cell.textLabel?.text = budgetController.budgets[indexPath.row].budgetType
        cell.detailTextLabel?.text = "$\(budgetController.budgets[indexPath.row].balance)"
        return cell
    }
}
