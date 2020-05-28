//
//  DetailTableViewController.swift
//  Financify
//
//  Created by Enrique Gongora on 5/26/20.
//  Copyright © 2020 Chris Gonzales. All rights reserved.
//

import UIKit

class DetailTableViewController: UITableViewController {
    
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
        // TODO - Expense and amount will go here
        // Sample code: expenseName.insert(expense, at: 0)
        // amountArray.append(amount)
        tableView.reloadData()
        return
    }
    
    // MARK: - Table view data source
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 0 //Name of the expense.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "DetailCell", for: indexPath)
        /*
         cell.textLabel?.text = expenseName[indexPath.row]
         cell.detailTextLabel?.text = "$\(amountArray[indexPath.row])"
         */
        return cell
    }
}
