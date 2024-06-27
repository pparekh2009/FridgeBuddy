//
//  SettingsController.swift
//  FridgeBuddy
//
//  Created by Priyansh Parekh on 6/23/24.
//

import UIKit

class SettingsController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    
    @IBOutlet weak var notificationSwitch: UISwitch!
    @IBOutlet weak var notifyBeforeTF: UITextField!
    var datePickerView: UIPickerView!
    
    let duration = ["1 Day", "2 Days", "5 Days", "1 Week"]
    
    override func viewDidLoad() {
        
        let safeArea =  self.view.layoutMarginsGuide
        
        datePickerView = UIPickerView()
    
        notifyBeforeTF.inputView = datePickerView
        
        datePickerView.delegate = self
        datePickerView.dataSource = self
        
        let toolBar = UIToolbar(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 40))
        toolBar.barStyle = .black
        toolBar.isTranslucent = true
        toolBar.tintColor = .systemBlue
        
        let doneButton = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(doneTapped))
        
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
        
        toolBar.setItems([flexibleSpace, doneButton], animated: true)
        
        notifyBeforeTF.inputAccessoryView = toolBar
    }
    
    @objc func doneTapped() {
        notifyBeforeTF.resignFirstResponder()
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return duration.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return duration[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        let days = duration[row]
        print("Notify before: \(days)")
        notifyBeforeTF.text = days
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
}
