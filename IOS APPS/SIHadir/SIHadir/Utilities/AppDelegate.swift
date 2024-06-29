//
//  AppDelegate.swift
//  SIHadir
//
//  Created by Hilmy Noerfatih on 28/05/24.
//

import SwiftUI
import CoreLocation
import UserNotifications
import BackgroundTasks

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Request notification permission
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if let error = error {
                print("Notification permission error: \(error)")
            }
        }

        // Request location permission
        let locationManager = CLLocationManager()
        locationManager.requestAlwaysAuthorization()
        
        // Register background tasks
        BGTaskScheduler.shared.register(forTaskWithIdentifier: "com.yourapp.refresh", using: nil) { task in
            self.handleAppRefresh(task: task as! BGAppRefreshTask)
        }
        
        BGTaskScheduler.shared.register(forTaskWithIdentifier: "com.yourapp.processing", using: nil) { task in
            self.handleAppProcessing(task: task as! BGProcessingTask)
        }

        scheduleBackgroundTasks()
        
        return true
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        scheduleBackgroundTasks()
    }

    private func scheduleBackgroundTasks() {
        // Schedule an app refresh task
        let refreshTaskRequest = BGAppRefreshTaskRequest(identifier: "com.yourapp.refresh")
        refreshTaskRequest.earliestBeginDate = Date(timeIntervalSinceNow: 15 * 60) // Fetch no earlier than 15 minutes from now
        do {
            try BGTaskScheduler.shared.submit(refreshTaskRequest)
        } catch {
            print("Could not schedule app refresh: \(error)")
        }
        
        // Schedule a processing task
        let processingTaskRequest = BGProcessingTaskRequest(identifier: "com.yourapp.processing")
        processingTaskRequest.requiresNetworkConnectivity = true // Require network connectivity
        do {
            try BGTaskScheduler.shared.submit(processingTaskRequest)
        } catch {
            print("Could not schedule app processing: \(error)")
        }
    }

    private func handleAppRefresh(task: BGAppRefreshTask) {
        // Schedule the next refresh
        scheduleBackgroundTasks()

        // Perform the task
        BeaconFinder.shared.updateProximityList()
        BeaconFinder.shared.classifyBehavior()

        task.setTaskCompleted(success: true)
    }
    
    private func handleAppProcessing(task: BGProcessingTask) {
        // Schedule the next processing task
        scheduleBackgroundTasks()

        // Perform the task
        BeaconFinder.shared.updateProximityList()
        BeaconFinder.shared.classifyBehavior()

        task.setTaskCompleted(success: true)
    }
}
