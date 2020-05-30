//
//  DetailTableViewController.swift
//  Financify
//
//  Created by Enrique Gongora on 5/26/20.
//  Copyright © 2020 Chris Gonzales. All rights reserved.
//

import UIKit

class DetailTableViewController: UITableViewController {
    
    // MARK: - Properties
    var expenseController = ExpenseController()
    var budget: Budget?
    var user: User?
    
    // MARK: - IBActions
    @IBAction func addButtonTapped(_ sender: UIBarButtonItem) {
        showAlert()
    }
    
    // MARK: - View LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.reloadData()
    }
    
    // MARK: - Methods
    func showAlert() {
        let alert = UIAlertController(title: "New Expense", message: "Enter the expense name and the amount", preferredStyle: .alert)
        
        alert.addTextField()
        alert.addTextField()
        
        alert.textFields![0].placeholder = "Expense Name"
        alert.textFields![1].placeholder = "Amount"
        alert.textFields![1].keyboardType = UIKeyboardType.decimalPad
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Enter", style: .default, handler: { [weak self, weak alert] _ in
            guard let expense = alert?.textFields?[0].text else { return }
            guard let amount = alert?.textFields?[1].text, let doubleAmount = Double(amount) else { return }
            self?.submitEntry(expense, doubleAmount)
        }))
        
        self.present(alert, animated: true)
    }
    
    func submitEntry(_ expense: String, _ amount: Double) {
        let id = UUID()
        guard let budget = budget, let user = user else { return }
        expenseController.add(expenseWithDescription: expense, toBudget: budget, amount: amount, id: id, user: user) {
            print("Expense Added")
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
            return
        }
    }
    
    // MARK: - Table view data source
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        budget?.expenses?.count ?? 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "DetailCell", for: indexPath)
        let expense = budget?.expenses?.object(at: indexPath.row) as? Expense
        cell.textLabel?.text = expense?.expenseDescription
        cell.detailTextLabel?.text = "$\(expense?.amount ?? 0)"
        return cell
    }
}
