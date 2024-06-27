//
//  ShoppingListController.swift
//  FridgeBuddy
//
//  Created by Priyansh Parekh on 6/14/24.
//

import UIKit

class ShoppingListController: UIViewController, UITableViewDelegate, UITableViewDataSource, ShoppingCellDelegate {
    
    @IBOutlet weak var shoppingList: UITableView!
    @IBOutlet weak var addBtn: UIButton!
    
    var shoppingItemsArray = [ShoppingItem]()
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    override func viewDidLoad() {
        addBtn.layer.cornerRadius = 30
        addBtn.layer.masksToBounds = true
        
        shoppingList.dataSource = self
        shoppingList.delegate = self
        
        shoppingList.register(ShoppingTableCell.nib(), forCellReuseIdentifier: ShoppingTableCell.identifier)
        
        do {
            try shoppingItemsArray = context.fetch(ShoppingItem.fetchRequest())
        } catch {
            print("Error fetching shopping list")
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return shoppingItemsArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        let tableCell = tableView.dequeueReusableCell(withIdentifier: "shoppingItemCell", for: indexPath)
        let tableCell = tableView.dequeueReusableCell(withIdentifier: ShoppingTableCell.identifier, for: indexPath) as! ShoppingTableCell
        
        let shoppingItem = shoppingItemsArray[indexPath.row]
        
        tableCell.configure(title: shoppingItem.name!, qty: shoppingItem.quantity!, bought: shoppingItem.bought)
        tableCell.delegate = self
        
//        if let itemNameLabel = tableCell.viewWithTag(4) as? UILabel {
//            itemNameLabel.text = self.shoppingItemsArray[indexPath.row].name
//        }
        
//        if let itemPurchasedBtn = tableCell.viewWithTag(3) as? UIButton {
//            if self.shoppingItemsArray[indexPath.row].bought {
//                itemPurchasedBtn.setImage(UIImage(resource: .selected), for: .normal)
//            } else {
//                itemPurchasedBtn.setImage(UIImage(resource: .unselected), for: .normal)
//            }
            
//            let gesture = UITapGestureRecognizer(target: self, action: #selector(boughtBtnTapped(_ :)))
//        }
        
        return tableCell
    }
    
    func boughtTapped(tableViewCell: UITableViewCell) {
        let index = self.shoppingList.indexPath(for: tableViewCell)?.row
        
        let shoppingItem = shoppingItemsArray[index!]
        shoppingItem.bought = !shoppingItem.bought
        
        do {
            try self.context.save()
            
            if shoppingItem.bought {
                (tableViewCell as! ShoppingTableCell).button.setImage(UIImage.selected, for: .normal)
            } else {
                (tableViewCell as! ShoppingTableCell).button.setImage(UIImage.unselected, for: .normal)
            }
        } catch {
            print("Cannot updated shopping cell")
        }
        
    }
    
    @objc func boughtBtnTapped(_ button: UIButton) {
        
        if button.currentImage == UIImage(resource: .unselected) {
            button.setImage(UIImage(resource: .selected), for: .normal)
            
        } else {
            button.setImage(UIImage(resource: .unselected), for: .normal)
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("Row at \(indexPath.row) pressed")
        
        let shoppingItem = shoppingItemsArray[indexPath.row]
        
        let itemAlert = UIAlertController(title: shoppingItem.name, message: "Quantity: \(shoppingItem.quantity ?? "")", preferredStyle: .alert)
        
        itemAlert.addAction(UIAlertAction(title: "OK", style: .cancel))
        
        present(itemAlert, animated: true)
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete", handler: {
            (action, sourceView, completionHandler) in
            
            let index = indexPath.row
            let shoppingItem = self.shoppingItemsArray[index]
            
            self.context.delete(shoppingItem)
            
            do {
                try self.context.save()
                self.shoppingItemsArray.remove(at: index)
                self.shoppingList.deleteRows(at: [indexPath], with: .automatic)
            } catch {
                print("Error deleting shopping item")
            }
        })
        
        return UISwipeActionsConfiguration(actions: [deleteAction])
    }
    
    @IBAction func addBtnTapped(_ sender: UIButton) {
        let addItemAlert = UIAlertController(title: "Add Item", message: "", preferredStyle: .alert)
        addItemAlert.addTextField() {
            (textField) in
            
            textField.placeholder = "Item Name"
        }
        
        addItemAlert.addTextField() { (textField) in
            textField.placeholder = "Item Quantity"
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        
        let okAction = UIAlertAction(title: "OK", style: .default, handler: { (uiHandler) in
            let itemName = addItemAlert.textFields?[0].text
            let itemQuantity = addItemAlert.textFields?[1].text
            
            let shoppingItem = ShoppingItem(context: self.context)
            shoppingItem.name = itemName
            shoppingItem.quantity = itemQuantity
            shoppingItem.bought = false
            
            do {
                try self.context.save()
                addItemAlert.dismiss(animated: true)
                self.shoppingItemsArray.append(shoppingItem)
                self.shoppingList.reloadData()
            } catch {
                print("Error saving shopping item")
            }
        })
        
        addItemAlert.addAction(cancelAction)
        addItemAlert.addAction(okAction)
        
        present(addItemAlert, animated: true)
    }
    
    @IBAction func addToFridgeTapped(_ sender: UIBarButtonItem) {
        for shoppingItem in shoppingItemsArray {
            if shoppingItem.bought {
                
            }
        }
    }
}
