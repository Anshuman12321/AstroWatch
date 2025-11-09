import Foundation
import HealthKit

@MainActor
class HealthKitManager {
    static let shared = HealthKitManager()
    private let healthStore = HKHealthStore()

    private init() {}

    /// Requests authorization to read HealthKit data. Returns true on success.
    func requestAuthorization() async throws -> Bool {
        // Ensure HealthKit is available on this device
        guard HKHealthStore.isHealthDataAvailable() else { return false }

        // Define the types we want to read
        let readTypes: Set<HKObjectType> = [
            HKObjectType.quantityType(forIdentifier: .stepCount)!,
            HKObjectType.quantityType(forIdentifier: .heartRate)!,
            HKObjectType.quantityType(forIdentifier: .activeEnergyBurned)!
        ]

        // Bridge the HealthKit async API using a continuation
        return try await withCheckedThrowingContinuation { continuation in
            healthStore.requestAuthorization(toShare: [], read: readTypes) { success, error in
                if let error = error {
                    continuation.resume(throwing: error)
                } else {
                    continuation.resume(returning: success)
                }
            }
        }
    }
    
    func checkAuthorizationStatus() -> Bool {
        guard HKHealthStore.isHealthDataAvailable() else { return false }

        let typesToCheck: [HKQuantityTypeIdentifier] = [.stepCount, .heartRate, .activeEnergyBurned]

        for typeID in typesToCheck {
            if let type = HKObjectType.quantityType(forIdentifier: typeID) {
                let status = healthStore.authorizationStatus(for: type)
                if status != .sharingAuthorized {
                    return false
                }
            }
        }
        return true
    }

    /// Fetches the most recent HKQuantitySample for a given identifier.
    /// - Parameter identifier: The HealthKit quantity type identifier (e.g., .stepCount).
    /// - Returns: The latest HKQuantitySample or nil if none available.
    func fetchMostRecentSample(for identifier: HKQuantityTypeIdentifier) async throws -> HKQuantitySample? {
        // Get the quantity type for the identifier
        guard let quantityType = HKObjectType.quantityType(forIdentifier: identifier) else {
            return nil
        }

        // Query for samples from start of today until now, sorted by end date descending
        let predicate = HKQuery.predicateForSamples(
            withStart: Calendar.current.startOfDay(for: Date()),
            end: Date(),
            options: .strictStartDate
        )
        let sortDescriptor = NSSortDescriptor(
            key: HKSampleSortIdentifierEndDate,
            ascending: false
        )

        // Execute the sample query with a continuation
        return try await withCheckedThrowingContinuation { continuation in
            let query = HKSampleQuery(
                sampleType: quantityType,
                predicate: predicate,
                limit: 1,
                sortDescriptors: [sortDescriptor]
            ) { _, samples, error in
                if let error = error {
                    continuation.resume(throwing: error)
                } else {
                    continuation.resume(returning: samples?.first as? HKQuantitySample)
                }
            }
            healthStore.execute(query)
        }
    }
}
