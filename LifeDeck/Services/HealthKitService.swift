import Foundation
import HealthKit

class HealthKitService {
    private let healthStore = HKHealthStore()

    // Health data types we want to read
    private let readTypes: Set<HKObjectType> = [
        HKObjectType.quantityType(forIdentifier: .stepCount)!,
        HKObjectType.quantityType(forIdentifier: .activeEnergyBurned)!,
        HKObjectType.quantityType(forIdentifier: .distanceWalkingRunning)!,
        HKObjectType.quantityType(forIdentifier: .heartRate)!,
        HKObjectType.quantityType(forIdentifier: .sleepAnalysis)!,
        HKObjectType.categoryType(forIdentifier: .sleepAnalysis)!,
        HKObjectType.quantityType(forIdentifier: .bodyMass)!,
        HKObjectType.quantityType(forIdentifier: .height)!,
    ]

    // Health data types we want to write (for workout logging)
    private let writeTypes: Set<HKSampleType> = [
        HKObjectType.quantityType(forIdentifier: .stepCount)!,
        HKObjectType.workoutType(),
    ]

    func requestAuthorization(completion: @escaping (Bool, Error?) -> Void) {
        guard HKHealthStore.isHealthDataAvailable() else {
            completion(false, NSError(domain: "HealthKit", code: 1, userInfo: [NSLocalizedDescriptionKey: "Health data not available"]))
            return
        }

        healthStore.requestAuthorization(toShare: writeTypes, read: readTypes) { success, error in
            completion(success, error)
        }
    }

    func isAuthorized() -> Bool {
        for type in readTypes {
            let status = healthStore.authorizationStatus(for: type)
            if status != .sharingAuthorized {
                return false
            }
        }
        return true
    }

    // MARK: - Step Count

    func getStepCount(for date: Date, completion: @escaping (Double?, Error?) -> Void) {
        let calendar = Calendar.current
        let startDate = calendar.startOfDay(for: date)
        let endDate = calendar.date(byAdding: .day, value: 1, to: startDate)!

        getQuantitySum(for: .stepCount, startDate: startDate, endDate: endDate, completion: completion)
    }

    func getWeeklyStepCount(completion: @escaping ([Double]?, Error?) -> Void) {
        let calendar = Calendar.current
        var stepCounts: [Double] = []
        let dispatchGroup = DispatchGroup()

        for i in 0..<7 {
            dispatchGroup.enter()
            let date = calendar.date(byAdding: .day, value: -i, to: Date())!
            getStepCount(for: date) { count, error in
                if let count = count {
                    stepCounts.insert(count, at: 0) // Insert at beginning to maintain chronological order
                }
                dispatchGroup.leave()
            }
        }

        dispatchGroup.notify(queue: .main) {
            completion(stepCounts, nil)
        }
    }

    // MARK: - Active Energy

    func getActiveEnergy(for date: Date, completion: @escaping (Double?, Error?) -> Void) {
        let calendar = Calendar.current
        let startDate = calendar.startOfDay(for: date)
        let endDate = calendar.date(byAdding: .day, value: 1, to: startDate)!

        getQuantitySum(for: .activeEnergyBurned, startDate: startDate, endDate: endDate, completion: completion)
    }

    // MARK: - Sleep Analysis

    func getSleepDuration(for date: Date, completion: @escaping (TimeInterval?, Error?) -> Void) {
        let calendar = Calendar.current
        let startDate = calendar.startOfDay(for: date)
        let endDate = calendar.date(byAdding: .day, value: 1, to: startDate)!

        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate)
        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierEndDate, ascending: false)

        let query = HKSampleQuery(sampleType: HKObjectType.categoryType(forIdentifier: .sleepAnalysis)!,
                                predicate: predicate,
                                limit: HKObjectQueryNoLimit,
                                sortDescriptors: [sortDescriptor]) { _, samples, error in

            guard let samples = samples as? [HKCategorySample], error == nil else {
                completion(nil, error)
                return
            }

            let sleepSamples = samples.filter { $0.value == HKCategoryValueSleepAnalysis.asleep.rawValue }
            let totalSleep = sleepSamples.reduce(0) { $0 + $1.endDate.timeIntervalSince($1.startDate) }

            completion(totalSleep, nil)
        }

        healthStore.execute(query)
    }

    // MARK: - Heart Rate

    func getRestingHeartRate(for date: Date, completion: @escaping (Double?, Error?) -> Void) {
        let calendar = Calendar.current
        let startDate = calendar.startOfDay(for: date)
        let endDate = calendar.date(byAdding: .day, value: 1, to: startDate)!

        getQuantityAverage(for: .heartRate, startDate: startDate, endDate: endDate, completion: completion)
    }

    // MARK: - Weight and Height

    func getLatestWeight(completion: @escaping (Double?, Error?) -> Void) {
        getLatestQuantity(for: .bodyMass, completion: completion)
    }

    func getLatestHeight(completion: @escaping (Double?, Error?) -> Void) {
        getLatestQuantity(for: .height, completion: completion)
    }

    // MARK: - Helper Methods

    private func getQuantitySum(for identifier: HKQuantityTypeIdentifier, startDate: Date, endDate: Date, completion: @escaping (Double?, Error?) -> Void) {
        guard let quantityType = HKObjectType.quantityType(forIdentifier: identifier) else {
            completion(nil, NSError(domain: "HealthKit", code: 2, userInfo: [NSLocalizedDescriptionKey: "Invalid quantity type"]))
            return
        }

        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate)
        let query = HKStatisticsQuery(quantityType: quantityType, quantitySamplePredicate: predicate, options: .cumulativeSum) { _, result, error in
            guard let result = result, error == nil else {
                completion(nil, error)
                return
            }

            let sum = result.sumQuantity()?.doubleValue(for: HKUnit.count())
            completion(sum, nil)
        }

        healthStore.execute(query)
    }

    private func getQuantityAverage(for identifier: HKQuantityTypeIdentifier, startDate: Date, endDate: Date, completion: @escaping (Double?, Error?) -> Void) {
        guard let quantityType = HKObjectType.quantityType(forIdentifier: identifier) else {
            completion(nil, NSError(domain: "HealthKit", code: 2, userInfo: [NSLocalizedDescriptionKey: "Invalid quantity type"]))
            return
        }

        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate)
        let query = HKStatisticsQuery(quantityType: quantityType, quantitySamplePredicate: predicate, options: .discreteAverage) { _, result, error in
            guard let result = result, error == nil else {
                completion(nil, error)
                return
            }

            let average = result.averageQuantity()?.doubleValue(for: HKUnit.count().unitDivided(by: HKUnit.minute()))
            completion(average, nil)
        }

        healthStore.execute(query)
    }

    private func getLatestQuantity(for identifier: HKQuantityTypeIdentifier, completion: @escaping (Double?, Error?) -> Void) {
        guard let quantityType = HKObjectType.quantityType(forIdentifier: identifier) else {
            completion(nil, NSError(domain: "HealthKit", code: 2, userInfo: [NSLocalizedDescriptionKey: "Invalid quantity type"]))
            return
        }

        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierEndDate, ascending: false)
        let query = HKSampleQuery(sampleType: quantityType, predicate: nil, limit: 1, sortDescriptors: [sortDescriptor]) { _, samples, error in
            guard let samples = samples as? [HKQuantitySample], let latest = samples.first, error == nil else {
                completion(nil, error)
                return
            }

            let value = latest.quantity.doubleValue(for: HKUnit.gramUnit(with: .kilo))
            completion(value, nil)
        }

        healthStore.execute(query)
    }

    // MARK: - Workout Logging

    func logWorkout(type: HKWorkoutActivityType, startDate: Date, endDate: Date, energyBurned: Double?, distance: Double?, completion: @escaping (Bool, Error?) -> Void) {
        let workout = HKWorkout(activityType: type, start: startDate, end: endDate)

        var metadata: [String: Any] = [:]

        if let energy = energyBurned {
            let energyQuantity = HKQuantity(unit: HKUnit.kilocalorie(), doubleValue: energy)
            metadata[HKMetadataKeyAverageEnergyBurned] = energyQuantity
        }

        if let distance = distance {
            let distanceQuantity = HKQuantity(unit: HKUnit.meter(), doubleValue: distance)
            metadata[HKMetadataKeyDistance] = distanceQuantity
        }

        healthStore.save(workout) { success, error in
            completion(success, error)
        }
    }
}