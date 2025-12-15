import WatchKit
import WatchConnectivity

class ExtensionDelegate: NSObject, WKExtensionDelegate, WCSessionDelegate {
    private let session = WCSession.default

    func applicationDidFinishLaunching() {
        setupWatchConnectivity()
    }

    func applicationDidBecomeActive() {
        // Restart any tasks that were paused
    }

    func applicationWillResignActive() {
        // Pause ongoing tasks
    }

    func handle(_ backgroundTasks: Set<WKRefreshBackgroundTask>) {
        for task in backgroundTasks {
            switch task {
            case let backgroundTask as WKApplicationRefreshBackgroundTask:
                // Handle background refresh
                backgroundTask.setTaskCompletedWithSnapshot(false)
            case let snapshotTask as WKSnapshotRefreshBackgroundTask:
                // Handle snapshot refresh
                snapshotTask.setTaskCompleted(restoredDefaultState: true, estimatedSnapshotExpiration: Date.distantFuture, userInfo: nil)
            case let connectivityTask as WKWatchConnectivityRefreshBackgroundTask:
                // Handle connectivity refresh
                connectivityTask.setTaskCompletedWithSnapshot(false)
            case let urlSessionTask as WKURLSessionRefreshBackgroundTask:
                // Handle URL session
                urlSessionTask.setTaskCompletedWithSnapshot(false)
            default:
                task.setTaskCompletedWithSnapshot(false)
            }
        }
    }

    private func setupWatchConnectivity() {
        if WCSession.isSupported() {
            session.delegate = self
            session.activate()
        }
    }

    // MARK: - WCSessionDelegate

    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        if let error = error {
            print("WCSession activation failed: \(error.localizedDescription)")
        } else {
            print("WCSession activated with state: \(activationState.rawValue)")
        }
    }

    func session(_ session: WCSession, didReceiveApplicationContext applicationContext: [String: Any]) {
        // Handle data received from iOS app
        DispatchQueue.main.async {
            // Update complication data
            let complicationServer = CLKComplicationServer.sharedInstance()
            complicationServer.activeComplications?.forEach { complication in
                complicationServer.reloadTimeline(for: complication)
            }
        }
    }
}