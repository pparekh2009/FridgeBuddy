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
    
    let userSettings = UserSettings.shared
    
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
            
            if self.userSettings.notificationStatus! {
                scheduleNotification(product: product)
            }
            
        } catch {
            logger.error("Error saving product")
        }
    }
    
    func scheduleNotification(product: Product) {
        let identifier = "com.priyanshparekh.FridgeBuddy"
        
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .none
        
        let title = "\(product.name ?? "") is about to expire"
        let body = "\(formatter.string(from: product.lastDate!)) is the last date to consume"
        
        let time = userSettings.notifyAt!
        let notifyBefore = userSettings.notifyBefore!
        print("Notify Before: \(notifyBefore)")
        
        let day = product.lastDate!.get(.day) - notifyBefore
        var month = product.lastDate!.get(.month)
        if day < 1 {
            month = month - 1
        }
        let hour = time.get(.hour)
        let minute = time.get(.minute)
        let isDaily = false
        
        let notificationCenter = UNUserNotificationCenter.current()
        
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default
        
        let calendar = Calendar.current
        var dateComponents = DateComponents(calendar: calendar, timeZone: TimeZone.current)
        dateComponents.day = product.lastDate!.get(.day) - notifyBefore
        dateComponents.month = product.lastDate!.get(.month)
        dateComponents.hour = hour
        dateComponents.minute = minute
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: isDaily)
        
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        
        notificationCenter.removePendingNotificationRequests(withIdentifiers: [identifier])
        notificationCenter.add(request)
    }
}

extension Date {
    func get(_ components: Calendar.Component..., calendar: Calendar = Calendar.current) -> DateComponents {
        return calendar.dateComponents(Set(components), from: self)
    }

    func get(_ component: Calendar.Component, calendar: Calendar = Calendar.current) -> Int {
        return calendar.component(component, from: self)
    }
}
