//
//  ViewController.swift
//  FridgeBuddy
//
//  Created by Priyansh Parekh on 6/13/24.
//

import UIKit

class HomeController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    
    @IBOutlet weak var productsList: UITableView!
    
    @IBOutlet weak var addBtn: UIButton!
    var productsArray = [Product]()
    
    var context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    
        productsList.delegate = self
        productsList.dataSource = self
        
        addBtn.layer.cornerRadius = 30
        addBtn.layer.masksToBounds = true
        
        do {
            try productsArray = context.fetch(Product.fetchRequest())
        } catch {
            print("Error getting products")
        }
        
//        for x in 1...5 {
//            let product = Product(context: context)
//            product.name = "Product_\(x)"
//            product.lastDate = Date(timeIntervalSinceNow: TimeInterval(x))
//            product.quantity = "3"
//            
//            productsArray.append(product)
//        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        productsArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let tableCell = tableView.dequeueReusableCell(withIdentifier: "tableCell", for: indexPath)
        
        if let productNameLabel = tableCell.viewWithTag(1) as? UILabel {
            productNameLabel.text = productsArray[indexPath.row].name
        }
        
//        let formatter = DateFormatter()
//        formatter.dateStyle = .short
        
        if let productDateLabel = tableCell.viewWithTag(2) as? UILabel {
//            productDateLabel.text = formatter.string(from: productsArray[indexPath.row].lastDate!)
            productDateLabel.text = productsArray[indexPath.row].lastDate!.formatted(date: .numeric, time: .omitted)
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
        tableView.deselectRow(at: indexPath, animated: false)
    }
}

