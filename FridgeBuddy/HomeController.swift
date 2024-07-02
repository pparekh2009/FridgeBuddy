//
//  ViewController.swift
//  FridgeBuddy
//
//  Created by Priyansh Parekh on 6/13/24.
//

import UIKit

class HomeController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate, UITextFieldDelegate {
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var productsList: UITableView!
    
    @IBOutlet weak var addBtn: UIButton!
    var productsArray = [Product]()
    
    var filterData = [Product]()
    
    var context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    let userSettings = UserSettings.shared
    
    var alertDatePicker: UIDatePicker? = nil
    var alertTextField: UITextField? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        let sortButton = UIBarButtonItem(title: nil, image: UIImage(systemName: "line.3.horizontal.decrease.circle"), target: self, action: #selector(sortButtonTapped))
        
//        self.navigationItem.rightBarButtonItem = sortButton
        
        searchBar.delegate = self
        searchBar.searchTextField.delegate = self
        
        // MARK: - Initialize User Settings
        
        if userSettings.notificationStatus == nil {
            userSettings.notificationStatus = false
        }
        
        if userSettings.notifyAt == nil {
            userSettings.notifyAt = Date()
        }
        
        if userSettings.notifyBefore == 0 {
            userSettings.notifyBefore = 1
        }
        
        print("Home Controller")
        print("Notification Status: \(userSettings.notificationStatus!)")
        print("Notify At: \(userSettings.notifyAt!)")
        print("Notify Before: \(userSettings.notifyBefore!)")
    
        productsList.delegate = self
        productsList.dataSource = self
        
        addBtn.layer.cornerRadius = 30
        addBtn.layer.masksToBounds = true
        
        do {
            try productsArray = context.fetch(Product.fetchRequest())
        } catch {
            print("Error getting products")
        }
        
        filterData = productsArray
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    @IBAction func sortButtonTapped(_ sender: UIButton) {
        let defaultSort = UIAction(title: "Default", handler: { action in self.sortList(orderBy: "default", isAsc: true) })
        let alphaAsc = UIAction(title: "A-Z", handler: { action in self.sortList(orderBy: "name", isAsc: true) })
        let alphaDsc = UIAction(title: "Z-A", handler: { action in self.sortList(orderBy: "name", isAsc: false) })
        let dateAsc = UIAction(title: "Date ↑", handler: { action in self.sortList(orderBy: "date", isAsc: true) })
        let dateDsc = UIAction(title: "Date ↓", handler: { action in self.sortList(orderBy: "date", isAsc: false) })
        
        let sortMenu = UIMenu(title: "Sort According To", children: [defaultSort, alphaAsc, alphaDsc, dateAsc, dateDsc])
        
        sender.showsMenuAsPrimaryAction = true
        
        sender.menu = sortMenu
    }
    
    func sortList(orderBy: String, isAsc: Bool) {
        let sortedList = filterData.sorted(by: {
            product1, product2 in
            
            if orderBy == "name" {
                if isAsc {
                    return product1.name! < product2.name!
                } else {
                    return product1.name! > product2.name!
                }
            } else if orderBy == "date" {
                if isAsc {
                    return product1.lastDate! < product2.lastDate!
                } else {
                    return product1.lastDate! > product2.lastDate!
                }
            }
            
            return true
        })
        filterData = sortedList
        productsList.reloadData()
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        filterData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let tableCell = tableView.dequeueReusableCell(withIdentifier: "tableCell", for: indexPath)
        
        if let productNameLabel = tableCell.viewWithTag(1) as? UILabel {
            productNameLabel.text = filterData[indexPath.row].name
        }
        
//        let formatter = DateFormatter()
//        formatter.dateStyle = .short
        
        if let productDateLabel = tableCell.viewWithTag(2) as? UILabel {
//            productDateLabel.text = formatter.string(from: productsArray[indexPath.row].lastDate!)
            productDateLabel.text = filterData[indexPath.row].lastDate!.formatted(date: .numeric, time: .omitted)
        }
        
        return tableCell
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if Singleton.shared.dataChanged {
            do {
                self.productsArray = try self.context.fetch(Product.fetchRequest())
                self.productsList.reloadData()
                Singleton.shared.dataChanged = false
            } catch {
                print("Error reloading data")
            }
        }
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete", handler: {
            (action, sourceView, completionHandler) in
            
            let index = indexPath.row
            let product = self.productsArray[index]
            
            self.context.delete(product)
            
            do {
                try self.context.save()
                self.productsArray.remove(at: index)
                self.productsList.deleteRows(at: [indexPath], with: .automatic)
            } catch {
                print("Error deleting product")
            }
        })
        
        return UISwipeActionsConfiguration(actions: [deleteAction])
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let product = filterData[indexPath.row]
        
        let alert = UIAlertController(title: "Update Item", message: nil, preferredStyle: .alert)
        
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .none
        
        alert.addTextField() {
            textField in
            
            textField.text = product.name
        }
        
        alert.addTextField() {
            textField in
            
            textField.text = product.quantity
        }
        
        alert.addTextField() {
            textField in
            
            self.alertDatePicker = UIDatePicker()
            self.alertDatePicker!.timeZone = .autoupdatingCurrent
            self.alertDatePicker!.preferredDatePickerStyle = .inline
            self.alertDatePicker!.showsLargeContentViewer = true
            self.alertDatePicker!.datePickerMode = .date
            self.alertDatePicker!.date = product.lastDate!
            
            textField.inputView = self.alertDatePicker!
            textField.text = formatter.string(from: product.lastDate!)
            
            let toolBar = UIToolbar(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 40))
            toolBar.barStyle = .default
            toolBar.isTranslucent = true
                        
            let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
            let doneButton = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(self.doneTapped))
            
            toolBar.setItems([flexibleSpace, doneButton], animated: true)
            
            textField.inputAccessoryView = toolBar
            
            self.alertTextField = textField
        }
        
        let updateButton = UIAlertAction(title: "Update", style: .default, handler: {
            action in
            
            print("Updated Info:")
            print("Name: \(alert.textFields?[0].text ?? "")")
            print("Quantity: \(alert.textFields?[1].text ?? "")")
            print("Date: \(alert.textFields?[2].text ?? "")")
            
            // TODO: - Validate empty textfields
            let name = alert.textFields?[0].text!
            let quantity = alert.textFields?[1].text!
            let lastDate = alert.textFields?[2].text!
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "MM/dd/yyyy"
            
            let product = self.productsArray[indexPath.row]
            product.name = name
            product.quantity = quantity
            product.lastDate = dateFormatter.date(from: lastDate!)
            
            do {
                try self.context.save()
                self.productsList.reloadData()
            } catch {
                print("Cannot update product")
            }
            
            alert.dismiss(animated: true)
        })
        
        let cancelButton = UIAlertAction(title: "Cancel", style: .cancel)
        
        alert.addAction(updateButton)
        alert.addAction(cancelButton)
        
        present(alert, animated: true)
        
        tableView.deselectRow(at: indexPath, animated: false)
    }
    
    @objc func doneTapped() {
        
        print("Textfield: \(alertTextField!)")
        print("Date Picker: \(alertDatePicker!)")
        alertTextField!.text = alertDatePicker!.date.formatted(date: .numeric, time: .omitted)
        
        alertTextField!.resignFirstResponder()
        
        alertTextField = nil
        alertDatePicker = nil
    }
    
    // MARK: - Search Bar code
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        filterData = []
        
        if searchText == "" {
            filterData = productsArray
        }
        
        for product in productsArray {
            if product.name!.uppercased().contains(searchText.uppercased()) {
                filterData.append(product)
            }
        }
        
        self.productsList.reloadData()
    }
}

