//
//  WatchDataManager.swift
//  LifeDeckWatch Watch App
//
//  Created on 2024
//

import Foundation
import WatchConnectivity

class WatchDataManager: NSObject, WCSessionDelegate {
    static let shared = WatchDataManager()

    private var session: WCSession?

    override init() {
        super.init()
        if WCSession.isSupported() {
            session = WCSession.default
            session?.delegate = self
            session?.activate()
        }
    }

    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        if let error = error {
            print("Watch session activation failed: \(error.localizedDescription)")
        }
    }

    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        // Handle incoming messages from iOS app
        DispatchQueue.main.async {
            NotificationCenter.default.post(name: .watchDataReceived, object: message)
        }
    }

    func sendMessageToPhone(_ message: [String: Any], replyHandler: (([String: Any]) -> Void)? = nil) {
        guard let session = session, session.isReachable else {
            print("Phone not reachable")
            return
        }

        session.sendMessage(message, replyHandler: replyHandler) { error in
            print("Failed to send message to phone: \(error.localizedDescription)")
        }
    }

    func updateComplicationData(lifeScore: Int, streak: Int, nextCardTitle: String) {
        // Store data for complications
        UserDefaults.standard.set(lifeScore, forKey: "lifeScore")
        UserDefaults.standard.set(streak, forKey: "currentStreak")
        UserDefaults.standard.set(nextCardTitle, forKey: "nextCardTitle")

        // Update active complications
        let server = CLKComplicationServer.sharedInstance()
        server.activeComplications?.forEach { complication in
            server.reloadTimeline(for: complication)
        }
    }
}

extension Notification.Name {
    static let watchDataReceived = Notification.Name("watchDataReceived")
}