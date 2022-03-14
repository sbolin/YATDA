//
//  NotificationManager.swift
//  YATDA
//
//  Created by Scott Bolin on 13-Mar-22.
//

import Foundation
import UserNotifications

final class NotificationManager: ObservableObject {
    @Published private(set) var notifications: [UNNotificationRequest] = []
    @Published private(set) var authorizationStatus: UNAuthorizationStatus?

    func requestAuthorization() {
        print(#function)
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { isGranted, error in
            DispatchQueue.main.async {
                self.authorizationStatus = isGranted ? .authorized : .denied
            }
        }
    }

    func reloadAuthorizationStatus() {
        print(#function)
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            DispatchQueue.main.async {
                self.authorizationStatus = settings.authorizationStatus
            }
        }
    }


    func reloadLocalNotifications() {
        print(#function)
        UNUserNotificationCenter.current().getPendingNotificationRequests { notification in
            DispatchQueue.main.async {
                self.notifications = notification
            }
        }
    }

    func createLocalNotification(title: String, subtitle: String, body: String, notificationID: String, hour: Int, minute: Int, completion: @escaping (Error?) -> Void) {
        // Current implementation: the focused request will present 1 notification per day at user input time. More notifications can be implemented using this function (as the notificationID will be based on the requestID), but seems excessive for the use case.

        let calendar = Calendar.current
        //       calendar.dateComponents([.year, .month, .day], from: Date())
        let dateComponents = DateComponents(calendar: calendar, hour: hour, minute: minute)
        //        dateComponents.weekday = 1 // 1 = Sunday

        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        let notificationContent = UNMutableNotificationContent()
        notificationContent.title = title
        notificationContent.subtitle = subtitle
        notificationContent.body = body
        notificationContent.sound = .default

        // future use case, when user can mark todo as complete
        notificationContent.categoryIdentifier = "DAILY_NOTIFICATION"
        notificationContent.userInfo = ["requestID": notificationID]

        let request = UNNotificationRequest(identifier: notificationID, content: notificationContent, trigger: trigger)

        UNUserNotificationCenter.current().add(request, withCompletionHandler: completion)

    }

    func deleteLocalNotifications(identifiers: [String]) {
        UNUserNotificationCenter.current().removeAllDeliveredNotifications()
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: identifiers)
    }

    func deleteLocalNotifications() {
        // can't just delete pending notifications, delete all
        UNUserNotificationCenter.current().removeAllDeliveredNotifications()
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }

    /// Future use case, where user will be able to mark a request as answered from the notification
    ///
    func classifyNotifications() {
        print(#function)
        // define actions
        let okAction = UNNotificationAction(identifier: "OK_ACTION",
                                            title: "OKAY!",
                                            options: [])
        let completeAction = UNNotificationAction(identifier: "COMPLETE_ACTION",
                                                  title: "Mark Complete",
                                                  options: [.foreground])

        // define notification type
        let category = UNNotificationCategory(identifier: "DAILY_NOTIFICATION",
                                              actions: [okAction, completeAction],
                                              intentIdentifiers: [],
                                              hiddenPreviewsBodyPlaceholder: "Notifications are Hidden",
                                              categorySummaryFormat: "",
                                              options: .customDismissAction)
        // Register the notification type
        UNUserNotificationCenter.current().setNotificationCategories([category])

    }
}


