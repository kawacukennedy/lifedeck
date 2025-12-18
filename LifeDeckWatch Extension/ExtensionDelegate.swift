//
//  ExtensionDelegate.swift
//  LifeDeckWatch Extension
//
//  Created on 2024
//

import WatchKit
import WatchConnectivity

class ExtensionDelegate: NSObject, WKApplicationDelegate, WCSessionDelegate {
    var session: WCSession?

    func applicationDidFinishLaunching() {
        // Initialize Watch Connectivity
        if WCSession.isSupported() {
            session = WCSession.default
            session?.delegate = self
            session?.activate()
        }
    }

    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        if let error = error {
            print("WCSession activation failed: \(error.localizedDescription)")
        } else {
            print("WCSession activated with state: \(activationState.rawValue)")
        }
    }

    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        // Handle messages from iOS app
        if let action = message["action"] as? String {
            switch action {
            case "updateDashboard":
                // Update watch dashboard with new data
                NotificationCenter.default.post(name: .dashboardDataUpdated, object: message["data"])
            case "showReminder":
                // Show reminder on watch
                if let title = message["title"] as? String {
                    showReminder(title: title)
                }
            default:
                break
            }
        }
    }

    private func showReminder(title: String) {
        let content = UNMutableNotificationContent()
        content.title = "LifeDeck Reminder"
        content.body = title
        content.sound = .default

        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: nil)
        UNUserNotificationCenter.current().add(request)
    }
}

extension Notification.Name {
    static let dashboardDataUpdated = Notification.Name("dashboardDataUpdated")
}