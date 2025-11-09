import Foundation
import HealthKit
import Observation
import UserNotifications

@MainActor
@Observable class HealthDataViewModel {
    /// Latest step count value
    var stepCount: Double = 0

    /// Latest heart rate value
    var heartRate: Double = 0

    /// Latest active energy burned
    var activeEnergy: Double = 0

    /// Authorization status for HealthKit
    var isAuthorized: Bool = false

    /// Error message if authorization or fetch fails
    var errorMessage: String?

    /// Initializes the ViewModel and begins authorization
    init() {
        Task {
            let alreadyAuthorized = HealthKitManager.shared.checkAuthorizationStatus()
            if alreadyAuthorized {
                self.isAuthorized = true
                await fetchAllHealthData()
            } else {
                await requestAuthorization()
            }
        }
    }

    /// Requests HealthKit authorization and updates state accordingly
    func requestAuthorization() async {
        do {
            let success = try await HealthKitManager.shared.requestAuthorization()
                self.isAuthorized = success
            if success {
                await fetchAllHealthData()
            }
        } catch {
            self.errorMessage = error.localizedDescription 
        }
    }

    /// Fetches all health data samples concurrently
    func fetchAllHealthData() async {
        async let steps: () = fetchStepCount()
        async let rate: ()  = fetchHeartRate()
        async let energy: () = fetchActiveEnergy()
        _ = await (steps, rate, energy)
    }

    /// Fetches the most recent step count and updates stepCount
    func fetchStepCount() async {
        if let sample = try? await HealthKitManager.shared.fetchMostRecentSample(for: .stepCount) {
            let value = sample.quantity.doubleValue(for: HKUnit.count())
            self.stepCount = value
        }
    }

    /// Fetches the most recent heart rate and updates heartRate
    func fetchHeartRate() async {
        if let sample = try? await HealthKitManager.shared.fetchMostRecentSample(for: .heartRate) {
            let value = sample.quantity
                .doubleValue(for: HKUnit.count().unitDivided(by: HKUnit.minute()))
            self.heartRate = value
        }
    }

    /// Fetches the most recent active energy burned and updates activeEnergy
    func fetchActiveEnergy() async {
        if let sample = try? await HealthKitManager.shared.fetchMostRecentSample(for: .activeEnergyBurned) {
            let value = sample.quantity.doubleValue(for: HKUnit.kilocalorie())
            self.activeEnergy = value
        }
    }
}

extension HealthDataViewModel {
    /// Ask the user for permission once.
    func requestNotificationPermission() async {
        let center = UNUserNotificationCenter.current()
        do {
            let granted = try await center.requestAuthorization(options: [.alert, .sound, .badge])
            print(granted ? "✅ Notifications authorized" : "⚠️ Notifications not authorized")
        } catch {
            print("❌ Failed to request notification permission: \(error.localizedDescription)")
        }
    }

    /// Schedule a simple local notification
    func sendNotification(title: String, body: String) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 2, repeats: false)
                let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
                UNUserNotificationCenter.current().add(request)
    }
}
