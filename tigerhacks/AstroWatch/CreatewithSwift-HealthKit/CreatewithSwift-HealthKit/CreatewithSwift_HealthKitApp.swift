



import SwiftUI
import UserNotifications


@main
struct CreatewithSwift_HealthKitApp: App {
    init() {
        UNUserNotificationCenter.current().delegate = NotificationDelegate.shared
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

final class NotificationDelegate: NSObject, UNUserNotificationCenterDelegate {
    @MainActor
    static let shared = NotificationDelegate()
    
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        // Show banner + sound even while app is active
        completionHandler([.banner, .sound])
    }
}
