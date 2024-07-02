//
//  SettingsController.swift
//  FridgeBuddy
//
//  Created by Priyansh Parekh on 6/23/24.
//

import UIKit
import UserNotifications

class SettingsController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    
    @IBOutlet weak var notificationSwitch: UISwitch!
    @IBOutlet weak var notifyBeforeTF: UITextField!
    @IBOutlet weak var notifyAtTF: UITextField!
        
    let notificationCenter: UNUserNotificationCenter = UNUserNotificationCenter.current()
    
    let duration = [
        1: "1 Day",
        2: "2 Days",
        5: "5 Days",
        7: "7 Days"
    ]
    
    let userSettings = UserSettings.shared
    
    var timePicker: UIDatePicker!
    var daysPickerView: UIPickerView!
    
    var notifyBeforeDays = 1
    
    override func viewDidLoad() {
        
        // MARK: - Setup days pickerview and its toolbar
        daysPickerView = UIPickerView()
    
        notifyBeforeTF.inputView = daysPickerView
        
        daysPickerView.delegate = self
        daysPickerView.dataSource = self
        
        let daysToolBar = UIToolbar(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 40))
        daysToolBar.barStyle = .default
        daysToolBar.isTranslucent = true
        daysToolBar.tintColor = .systemBlue
        
        let daysDoneButton = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(daysDoneTapped))
        
        let daysFlexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
        
        daysToolBar.setItems([daysFlexibleSpace, daysDoneButton], animated: true)
        
        notifyBeforeTF.inputAccessoryView = daysToolBar
        
        
        
        // MARK: - Setup time picker and its toolbar
        timePicker = UIDatePicker()
        timePicker.datePickerMode = .time
        timePicker.preferredDatePickerStyle = .wheels
        
        notifyAtTF.inputView = timePicker
        
        let timeToolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 40))
        timeToolbar.barStyle = .default
        timeToolbar.isTranslucent = true
        timeToolbar.tintColor = .systemBlue
        
        let timeDoneButton = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(timeDoneTapped))
        
        let timeFlexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
        
        timeToolbar.setItems([timeFlexibleSpace, timeDoneButton], animated: true)
        
        notifyAtTF.inputAccessoryView = timeToolbar
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        print("Keys: \(Array(duration.keys).sorted())")
        
        
        // MARK: - Set switch according to notification permission
        let center = UNUserNotificationCenter.current()
        
        center.getNotificationSettings { settings in
            switch settings.authorizationStatus {
            case .authorized:
                DispatchQueue.main.async {
                    self.notificationSwitch.isOn = true
                }
                self.userSettings.notificationStatus = true
                break
            case .denied:
                DispatchQueue.main.async {
                    self.notificationSwitch.isOn = false
                }
                self.userSettings.notificationStatus = false
                break
            default:
                DispatchQueue.main.async {
                    self.notificationSwitch.isOn = false
                }
                self.userSettings.notificationStatus = false
            }
        }
        
        // MARK: - Set notify before according to NotifyBefore
        notifyBeforeTF.text = duration[userSettings.notifyBefore!]
        
        // MARK: - Set notify at according to NotifyAt
        let formatter = DateFormatter()
        formatter.dateStyle = .none
        formatter.timeStyle = .short
        
        notifyAtTF.text = formatter.string(from: userSettings.notifyAt!)
    }
    
    
    
    // MARK: - Notify Before Days Pickerview Code
    
    @objc func daysDoneTapped() {
        notifyBeforeTF.resignFirstResponder()
        
        userSettings.notifyBefore = notifyBeforeDays
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return duration.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return Array(duration.values).sorted()[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        let days = Array(duration.keys).sorted()[row]
        print("didSelectRow Notify before: \(duration[days] ?? "")")
        notifyBeforeTF.text = duration[days]
        
        notifyBeforeDays = days
    }
    
    
    
    // MARK: - Notification Time Picker and TF Code
    
    @objc func timeDoneTapped() {
        
        let formatter = DateFormatter()
        formatter.dateStyle = .none
        formatter.timeStyle = .short
        
        let date = formatter.string(from: self.timePicker.date)
        
        print("Date: \(date)")
        
        notifyAtTF.resignFirstResponder()
        
        notifyAtTF.text = date
        
        userSettings.notifyAt = timePicker.date
    }
    
    
    
    // MARK: - Notification Permission
    
    @IBAction func notificationSwitchPressed(_ sender: UISwitch) {
        print("Switch status \(sender.isOn)")
        
        if sender.isOn {
            checkNotificationPermission(sender)
        } else {
            self.userSettings.notificationStatus = false
        }
    }
    
    func checkNotificationPermission(_ sender: UISwitch) {
        
        let center = UNUserNotificationCenter.current()
        center.getNotificationSettings { settings in
            switch settings.authorizationStatus {
            case .authorized:
                print("Notifications are allowed.")
                self.userSettings.notificationStatus = true
                
            case .denied:
                print("Notifications are not allowed.")
                self.promptToEnableNotifications()
                DispatchQueue.main.async {
                    sender.setOn(false, animated: true)
                }
                self.userSettings.notificationStatus = false
            case .notDetermined:
                print("Notification permission not determined.")
                self.requestNotificationPermission(sender)
            default:
                break
            }
        }
    }
    
    func requestNotificationPermission(_ sender: UISwitch) {
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            DispatchQueue.main.async {
                if granted {
                    print("Notification permission granted.")
                    self.userSettings.notificationStatus = true
                } else if let error = error {
                    sender.setOn(false, animated: true)
                    self.userSettings.notificationStatus = false
                    print("Failed to request notification permission: \(error.localizedDescription)")
                } else {
                    sender.setOn(false, animated: true)
                    self.userSettings.notificationStatus = false
                    print("Notification permission not granted.")
                }
            }
        }
    }

    func promptToEnableNotifications() {
        DispatchQueue.main.async {
            let alert = UIAlertController(title: "Notifications Disabled",
                                          message: "Please enable notifications in Settings.",
                                          preferredStyle: .alert)
            let settingsAction = UIAlertAction(title: "Settings", style: .default) { _ in
                if let appSettings = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(appSettings, options: [:], completionHandler: nil)
                }
            }
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            alert.addAction(settingsAction)
            alert.addAction(cancelAction)
            self.present(alert, animated: true, completion: nil)
        }
    }
}
