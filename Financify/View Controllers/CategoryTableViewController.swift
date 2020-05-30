//
//  CategoryTableViewController.swift
//  Financify
//
//  Created by Enrique Gongora on 5/26/20.
//  Copyright © 2020 Chris Gonzales. All rights reserved.
//

import UIKit
import CloudKit

class CategoryTableViewController: UITableViewController {
    
    // MARK: - Properties
    
    private var cloudController = CloudKitManager()
    private var userController = UserController()
    private var CloudShareController = UICloudSharingController()
    private var user: User?
    private var id = UUID()
    
    var budgetController = BudgetController()
    
    // MARK: - IBActions
    // change to set user once, then adjust total funds after
    @IBAction func addUserTapped(_ sender: UIBarButtonItem) {
        let alert = UIAlertController(title: "Create New User", message: "Enter your first and last name and your budget total", preferredStyle: .alert)
        alert.addTextField()
        alert.addTextField()
        alert.addTextField()
        
        alert.textFields![0].placeholder = "First Name"
        alert.textFields![1].placeholder = "Last Name"
        alert.textFields![2].placeholder = "Budget Total"
        alert.textFields![2].keyboardType = .decimalPad
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Enter", style: .default, handler: { [weak self, weak alert] _ in
            guard let firstName = alert?.textFields?[0].text else { return }
            guard let lastName = alert?.textFields?[1].text else { return }
            guard let budget = alert?.textFields?[2].text, let totalBudget = Double(budget) else { return }
            guard let self = self else { return }
            self.createUser(firstName, lastName, totalBudget)
        }))
        self.present(alert, animated: true)
    }
    
    @IBAction func addBudgetTapped(_ sender: UIBarButtonItem) {
        let alert = UIAlertController(title: "Create new Budget", message: "Enter title, type, and amount.", preferredStyle: .alert)
        alert.addTextField()
        alert.addTextField()
        alert.addTextField()
        
        alert.textFields![0].placeholder = "Budget Title"
        alert.textFields![1].placeholder = "Budget Type"
        alert.textFields![2].placeholder = "Budget Amount"
        alert.textFields![2].keyboardType = .decimalPad
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Enter", style: .default, handler: { [weak self, weak alert] _ in
            guard let budgetWithTitle = alert?.textFields?[0].text else { return }
            guard let budgetType = alert?.textFields?[1].text else { return }
            guard let amount = alert?.textFields?[2].text, let budgetAmount = Double(amount) else { return }
            self?.createBudget(budgetWithTitle, budgetType, budgetAmount: budgetAmount)
        }))
        self.present(alert, animated: true)
    }
    
    @IBAction func shareButtonTapped(_ sender: UIBarButtonItem) {
    }
    
    func createBudget(_ budgetWithTitle: String, _ budgetType: String, budgetAmount: Double ) {
        guard let user = self.user else { return }
        budgetController.add(budgetWithTitle: budgetWithTitle,
                             budgetType: budgetType,
                             budgetAmount: budgetAmount,
                             balance: budgetAmount,
                             id: id,
                             isShared: true,
                             user: user) {
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
            return
        }
    }
    
    // MARK: - Methods
    func createUser(_ firstName: String, _ lastName: String, _ funds: Double) {
        self.user = User(firstName: firstName, funds: funds, lastName: lastName, id: id)
        userController.createUserWith(firstName: firstName, funds: funds, lastName: lastName, ckManager: cloudController) { }
    }
    
    func totalForAllBudgets(_ budgets: [Budget]) -> Double {
        var total: Double = 0
        for budget in budgets {
            total += budget.budgetAmount
        }
        return total
    }
    
    private func prepareToShare(share: CKShare, record: CKRecord, cell: UITableViewCell) {
        
        let sharingViewController = UICloudSharingController(preparationHandler: {(UICloudSharingController,
            handler: @escaping (CKShare?, CKContainer?, Error?) -> Void) in
            
            let modRecordsList = CKModifyRecordsOperation(recordsToSave: [record, share], recordIDsToDelete: nil)
            modRecordsList.savePolicy = .changedKeys
            modRecordsList.modifyRecordsCompletionBlock = {
                (record, recordID, error) in
                
                handler(share, CKContainer.default(), error)
            }
            CKContainer.default().privateCloudDatabase.add(modRecordsList)
        })
        sharingViewController.popoverPresentationController?.sourceView = cell
        sharingViewController.delegate = self
        
        sharingViewController.availablePermissions = [.allowReadWrite,
                                                      .allowPrivate]
        self.navigationController?.present(sharingViewController, animated: true, completion: nil)
    }
    
    func fetchShare(_ cloudKitShareMetadata: CKShare.Metadata) {
        let ckOperation = CKFetchRecordsOperation(
            recordIDs: [cloudKitShareMetadata.rootRecordID])
        
        ckOperation.perRecordCompletionBlock = { record, _, error in
            guard error == nil, record != nil else {
                print("error \(error?.localizedDescription ?? "")")
                return
            }
        }
        ckOperation.fetchRecordsCompletionBlock = { _, error in
            guard error != nil else {
                print("error \(error?.localizedDescription ?? "")")
                return
            }
        }
        CKContainer.default().sharedCloudDatabase.add(ckOperation)
    }
    
    // MARK: - View LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        budgetController.fetchAllBudgetsFromCloudKit { }
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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }
    
    // MARK: - Table view data source
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        budgetController.budgets.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CategoryCell", for: indexPath)
        cell.textLabel?.text = budgetController.budgets[indexPath.row].title
        cell.detailTextLabel?.text = "$\(budgetController.budgets[indexPath.row].totalRemaining)"
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let budget = budgetController.budgets[indexPath.row]
        let cell = tableView.cellForRow(at: indexPath)
        let share = CKShare(rootRecord: budget.cloudKitRecord)
        
        if let budgetName = budget.value(forKey: Budget.titleKey) as? String {
            share[CKShare.SystemFieldKey.title] = "Sharing \(budgetName)" as CKRecordValue
        } else {
            share[CKShare.SystemFieldKey.title] = "" as CKRecordValue?
        }
        
        share.setValue(kCFBundleIdentifierKey, forKey: CKShare.SystemFieldKey.shareType)
        prepareToShare(share: share,
                       record: budget.cloudKitRecord,
                       cell: cell!)
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let indexPath = tableView.indexPathForSelectedRow else { return }
        let vc = segue.destination as? DetailTableViewController
        vc?.user = self.user
        vc?.budget = budgetController.budgets[indexPath.row]
    }
}
