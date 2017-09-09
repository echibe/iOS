//
//  MessagesViewController.swift
//  MessagesExtension
//
//  Created by Elliot Chibe on 9/8/17.
//  Copyright © 2017 Elliot Chibe. All rights reserved.
//

import UIKit
import Messages
import EventKit

class MessagesViewController: MSMessagesAppViewController {
    var eventStore = EKEventStore()
    var calendars:Array<EKCalendar> = []
    var usersNames: [String: String] = [:]
    

    @IBAction func tomorrow_button(_ sender: Any) {
        print("tomorrow")
        setReminderDate(dayOffset: 1, hourOffset: 0, minuteOffset: 0)
    }
    
    @IBAction func hour_button(_ sender: Any) {
        print("1 hour")
        setReminderDate(dayOffset: 0, hourOffset: 1, minuteOffset: 0)
    }
    
    @IBAction func minute_button(_ sender: Any) {
        print("15 minutes")
        setReminderDate(dayOffset: 0, hourOffset: 0, minuteOffset: 15)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        eventStore.requestAccess(to: EKEntityType.reminder, completion:
            {(granted, error) in
                if !granted {
                    print("Access to store not granted")
                }
        })
        
        // you need calender's permission for the reminders as they live there
        calendars = eventStore.calendars(for: EKEntityType.reminder)
        
        for calendar in calendars as [EKCalendar] {
            print("Calendar = \(calendar.title)")
        }

    }
    
    func setReminderDate(dayOffset: Int, hourOffset: Int, minuteOffset: Int){
        print("button pressed")
        let reminder = EKReminder(eventStore: self.eventStore)
        reminder.title = "Text back "
        
        reminder.calendar = eventStore.defaultCalendarForNewReminders()
        
        let calendar = Calendar.current
        let date = Date()
        
        let dateDue = DateComponents.init(calendar: calendar, year: calendar.component(.year, from:date), month: calendar.component(.month, from: date), day: calendar.component(.day, from: date)+dayOffset, hour: calendar.component(.hour, from: date)+hourOffset, minute: calendar.component(.minute, from: date)+minuteOffset, second: calendar.component(.second, from: date))
        
        reminder.dueDateComponents = dateDue
        reminder.addAlarm(EKAlarm(absoluteDate: dateDue.date!))
        getName(reminder: reminder)
    }
    
    func saveReminder(reminder: EKReminder, name: String){
        print("saveReminder")
        reminder.title = "Text back "+name
        do{
            try eventStore.save(reminder, commit: true)
            
        } catch let error {
            print(error)
        }
    }
    
    
    func getName(reminder: EKReminder){
        print("getName")
        let conversation = activeConversation
        let UUID = String(describing: conversation?.localParticipantIdentifier)
        
        if(usersNames[UUID] == nil){
            // create the alert
            let alert = UIAlertController(title: "Name not set", message: "Please enter this person's name.", preferredStyle: .alert)
            
            // add the actions (buttons)
            
            
            alert.addAction(UIAlertAction(title: "Submit", style: .default, handler: { [weak alert] (_) in
                let textField = alert?.textFields![0]
                self.usersNames[UUID] = textField?.text!
                self.saveReminder(reminder: reminder, name: (textField?.text!)!)
                print("Dict updated: ", self.usersNames)
            }))
            
            alert.addAction(UIAlertAction(title: "Cancel", style: .default))
            
            alert.addTextField { (textField) in
                textField.placeholder = "Enter Name"
            }
            
            // show the alert
            self.present(alert, animated: true, completion: nil)
        }
        else{
            print("username found")
            saveReminder(reminder: reminder, name: usersNames[UUID]!)
        }
        return
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Conversation Handling
    
    override func willBecomeActive(with conversation: MSConversation) {
        // Called when the extension is about to move from the inactive to active state.
        // This will happen when the extension is about to present UI.
        print("opened")
        // get permission
        eventStore.requestAccess(to: EKEntityType.reminder, completion:
            {(granted, error) in
                if !granted {
                    print("Access to store not granted")
                }
        })
        
        // you need calender's permission for the reminders as they live there
        calendars = eventStore.calendars(for: EKEntityType.reminder)
        
        for calendar in calendars as [EKCalendar] {
            print("Calendar = \(calendar.title)")
        }
        // Use this method to configure the extension and restore previously stored state.
    }
    
    override func didResignActive(with conversation: MSConversation) {
        // Called when the extension is about to move from the active to inactive state.
        // This will happen when the user dissmises the extension, changes to a different
        // conversation or quits Messages.
        
        // Use this method to release shared resources, save user data, invalidate timers,
        // and store enough state information to restore your extension to its current state
        // in case it is terminated later.
    }
   
    override func didReceive(_ message: MSMessage, conversation: MSConversation) {
        // Called when a message arrives that was generated by another instance of this
        // extension on a remote device.
        
        // Use this method to trigger UI updates in response to the message.
    }
    
    override func didStartSending(_ message: MSMessage, conversation: MSConversation) {
        // Called when the user taps the send button.
    }
    
    override func didCancelSending(_ message: MSMessage, conversation: MSConversation) {
        // Called when the user deletes the message without sending it.
    
        // Use this to clean up state related to the deleted message.
    }
    
    override func willTransition(to presentationStyle: MSMessagesAppPresentationStyle) {
        // Called before the extension transitions to a new presentation style.
    
        // Use this method to prepare for the change in presentation style.
    }
    
    override func didTransition(to presentationStyle: MSMessagesAppPresentationStyle) {
        // Called after the extension transitions to a new presentation style.
    
        // Use this method to finalize any behaviors associated with the change in presentation style.
    }

}
