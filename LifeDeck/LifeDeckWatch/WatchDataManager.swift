import Foundation
import WatchConnectivity
import HealthKit

class WatchDataManager: NSObject, ObservableObject, WCSessionDelegate {
    @Published var lifeScore: Double = 0
    @Published var currentStreak: Int = 0
    @Published var todaysCards: Int = 0
    @Published var stepCount: Int = 0
    @Published var isConnected: Bool = false

    private let session = WCSession.default
    private let healthStore = HKHealthStore()

    override init() {
        super.init()
        setupWatchConnectivity()
        requestHealthAuthorization()
    }

    private func setupWatchConnectivity() {
        if WCSession.isSupported() {
            session.delegate = self
            session.activate()
        }
    }

    private func requestHealthAuthorization() {
        guard HKHealthStore.isHealthDataAvailable() else { return }

        let readTypes: Set<HKObjectType> = [
            HKObjectType.quantityType(forIdentifier: .stepCount)!,
            HKObjectType.quantityType(forIdentifier: .activeEnergyBurned)!,
        ]

        healthStore.requestAuthorization(toShare: nil, read: readTypes) { success, error in
            if success {
                self.fetchTodaySteps()
            }
        }
    }

    func fetchTodaySteps() {
        let calendar = Calendar.current
        let startDate = calendar.startOfDay(for: Date())
        let endDate = Date()

        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate)
        let query = HKStatisticsQuery(quantityType: HKObjectType.quantityType(forIdentifier: .stepCount)!,
                                    quantitySamplePredicate: predicate,
                                    options: .cumulativeSum) { _, result, error in

            guard let result = result, error == nil else { return }

            let steps = result.sumQuantity()?.doubleValue(for: HKUnit.count()) ?? 0
            DispatchQueue.main.async {
                self.stepCount = Int(steps)
            }
        }

        healthStore.execute(query)
    }

    // MARK: - WCSessionDelegate

    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        DispatchQueue.main.async {
            self.isConnected = activationState == .activated
        }
    }

    func session(_ session: WCSession, didReceiveApplicationContext applicationContext: [String: Any]) {
        DispatchQueue.main.async {
            self.lifeScore = applicationContext["lifeScore"] as? Double ?? 0
            self.currentStreak = applicationContext["currentStreak"] as? Int ?? 0
            self.todaysCards = applicationContext["todaysCards"] as? Int ?? 0
        }
    }

    func sessionDidBecomeInactive(_ session: WCSession) {
        // Handle session becoming inactive
    }

    func sessionDidDeactivate(_ session: WCSession) {
        // Handle session deactivation
        session.activate()
    }

    // MARK: - Complications Data

    func getComplicationData() -> [String: Any] {
        return [
            "lifeScore": lifeScore,
            "currentStreak": currentStreak,
            "stepCount": stepCount,
            "lastUpdated": Date().timeIntervalSince1970
        ]
    }

    func updateFromPhone(lifeScore: Double, currentStreak: Int, todaysCards: Int) {
        DispatchQueue.main.async {
            self.lifeScore = lifeScore
            self.currentStreak = currentStreak
            self.todaysCards = todaysCards
        }
    }
}