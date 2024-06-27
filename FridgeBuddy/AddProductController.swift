//
//  AddProductController.swift
//  FridgeBuddy
//
//  Created by Priyansh Parekh on 6/18/24.
//

import UIKit
import os

class AddProductController: UIViewController {
    
    @IBOutlet weak var productNameTF: UITextField!
    @IBOutlet weak var productQuantityTF: UITextField!
    @IBOutlet weak var lastDatePicker: UIDatePicker!
    
    let context = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer.viewContext
   
    var logger: Logger!
    
    override func viewDidLoad() {
        logger = Logger()
        
        lastDatePicker.minimumDate = Date()
    }
    
    @IBAction func saveBtnTapped(_ sender: UIBarButtonItem) {
        navigationController?.popViewController(animated: true)
        
        guard let productName = productNameTF.text else {
            logger.debug("Product Name is empty")
            return
        }
        
        guard let productQuantity = productQuantityTF.text else {
            logger.debug("Product Quantity is empty")
            return
        }
        
        logger.debug("Name: \(productName)")
        logger.debug("Quantity: \(productQuantity)")
        logger.debug("Last date: \(self.lastDatePicker.date.formatted(date: .numeric, time: .omitted))")
        
        let product = Product(context: context!)
        product.name = productName
        product.quantity = productQuantity
        product.lastDate = lastDatePicker.date
        
        do {
            try context?.save()
            Singleton.shared.dataChanged = true
        } catch {
            logger.error("Error saving product")
        }
    }
    
}
