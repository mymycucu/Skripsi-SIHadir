//
//  BeaconFinder.swift
//  SIHadir
//
//  Created by Hilmy Noerfatih on 15/11/23.
//

import Foundation
import CoreLocation
import CoreML
import UserNotifications
import LocalAuthentication
import Supabase

class BeaconFinder: NSObject, ObservableObject, CLLocationManagerDelegate {
    @Published var combinedProximityList: [Int] = Array(repeating: 99, count: 20)
    @Published var behavior: String = "Unknown"
    @Published var hasScheduledCheck = false
//    @Published var firstInTimestamp: Date?
//    @Published var lastOutTimestamp: Date?
//    @Published var outTimestamp: Date?
    @Published var checkWindowTimestamp: Date?
    @Published var lastCheckSuccessTimestamp: Date?
    @Published var isCheckWindow = false
    @Published var isInside = false
    @Published var db_data: AttendanceActionModel = AttendanceActionModel()

    private var UUID_beacon1 = "96B4164C-4EEB-55A7-DC43-BC177AEF8239-10-1"
    private var UUID_beacon2 = "163C6000-3605-028B-5F49-AACA39B6C76D-10-1"
    private var firstInPosted = false
    private var lastOutPosted = false
    private let device_id = "3CEDD3DD-8274-4E45-8414-DAFE2A1138AA"
    private let class_id = 1
    private let student_id = 1

    static let shared = BeaconFinder(beacons: [
        (uuid: UUID(uuidString: "96B4164C-4EEB-55A7-DC43-BC177AEF8239")!, major: 10, minor: 1),
        (uuid: UUID(uuidString: "163C6000-3605-028B-5F49-AACA39B6C76D")!, major: 10, minor: 1)
    ])
    
    var locationManager: CLLocationManager?
    
    private let beacons: [(uuid: UUID, major: UInt16, minor: UInt16)]
    private var beaconConstraints: [CLBeaconIdentityConstraint] = []
    
    private let proximityMapping: [CLProximity: Int] = [
        .immediate: 0,
        .near: 1,
        .far: 2,
        .unknown: 99
    ]
    
    private var lastProximityBeacon1: CLProximity = .unknown
    private var lastProximityBeacon2: CLProximity = .unknown
    
    private var model: BehaviorClassification?
    
    private var behaviorHistory: [String] = Array(repeating: "Other", count: 10)
    
    init(beacons: [(uuid: UUID, major: UInt16, minor: UInt16)]) {
        self.beacons = beacons
        super.init()
        
        locationManager = CLLocationManager()
        locationManager?.delegate = self
        locationManager?.allowsBackgroundLocationUpdates = true
        locationManager?.pausesLocationUpdatesAutomatically = false
        
        for beacon in beacons {
            let constraint = CLBeaconIdentityConstraint(uuid: beacon.uuid, major: beacon.major, minor: beacon.minor)
            beaconConstraints.append(constraint)
        }
        
        // Load the Core ML model
        do {
            model = try BehaviorClassification(configuration: MLModelConfiguration())
        } catch {
            print("Error loading model: \(error)")
        }
        
        // Request notification permission
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { granted, error in
            if let error = error {
                print("Notification authorization error: \(error)")
            }
        }
    }
    
    deinit {
        if let monitoredRegions = locationManager?.monitoredRegions {
            for region in monitoredRegions {
                locationManager?.stopMonitoring(for: region)
            }
        }

        for constraint in beaconConstraints {
            locationManager?.stopRangingBeacons(satisfying: constraint)
        }
    }
    
    func requestLocationPermission() {
        let status = CLLocationManager.authorizationStatus()
        if status == .notDetermined {
            locationManager?.requestWhenInUseAuthorization()
        } else if status == .authorizedWhenInUse {
            locationManager?.requestAlwaysAuthorization()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .notDetermined:
            locationManager?.requestWhenInUseAuthorization()
        case .authorizedWhenInUse:
            locationManager?.requestAlwaysAuthorization()
        case .authorizedAlways:
            if CLLocationManager.isMonitoringAvailable(for: CLBeaconRegion.self) {
                if CLLocationManager.isRangingAvailable() {
                    startScanning()
                }
            } else {
                print("Monitoring is not available")
            }
        case .denied, .restricted:
            print("Location services are not authorized.")
        default:
            break
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didRange beacons: [CLBeacon], satisfying beaconConstraint: CLBeaconIdentityConstraint) {
        for beacon in beacons {
            let key = "\(beacon.uuid.uuidString)-\(beacon.major)-\(beacon.minor)"
            let newProximity = beacon.proximity
            
            if key == UUID_beacon1 {
                lastProximityBeacon1 = newProximity
            } else if key == UUID_beacon2 {
                lastProximityBeacon2 = newProximity
            }
        }
        
        updateProximityList()
    }

    func updateProximityList() {
        let proximityValue1 = proximityMapping[lastProximityBeacon1] ?? 99
        let proximityValue2 = proximityMapping[lastProximityBeacon2] ?? 99
        
        combinedProximityList.append(proximityValue1)
        combinedProximityList.append(proximityValue2)
        
        if combinedProximityList.count > 20 {
            combinedProximityList.removeFirst(combinedProximityList.count - 20)
        }
        
        classifyBehavior()
    }

    func classifyBehavior() {
        guard let model = model else {
            print("Model not loaded")
            return
        }
        
        // Ensure we have exactly 20 values
        guard combinedProximityList.count == 20 else {
            print("Proximity list does not have 20 values")
            return
        }

        let input = BehaviorClassificationInput(
            door_1: Int64(combinedProximityList[0]),
            inside_1: Int64(combinedProximityList[1]),
            door_2: Int64(combinedProximityList[2]),
            inside_2: Int64(combinedProximityList[3]),
            door_3: Int64(combinedProximityList[4]),
            inside_3: Int64(combinedProximityList[5]),
            door_4: Int64(combinedProximityList[6]),
            inside_4: Int64(combinedProximityList[7]),
            door_5: Int64(combinedProximityList[8]),
            inside_5: Int64(combinedProximityList[9]),
            door_6: Int64(combinedProximityList[10]),
            inside_6: Int64(combinedProximityList[11]),
            door_7: Int64(combinedProximityList[12]),
            inside_7: Int64(combinedProximityList[13]),
            door_8: Int64(combinedProximityList[14]),
            inside_8: Int64(combinedProximityList[15]),
            door_9: Int64(combinedProximityList[16]),
            inside_9: Int64(combinedProximityList[17]),
            door_10: Int64(combinedProximityList[18]),
            inside_10: Int64(combinedProximityList[19])
        )
        
        do {
            let prediction = try model.prediction(input: input)
            behaviorHistory.append(prediction.behavior)
            
            if behaviorHistory.count > 10 { // Maintain a history of the last 10 classifications
                behaviorHistory.removeFirst()
            }
            
            let newBehavior = mostFrequentBehavior(in: behaviorHistory)
            if newBehavior != behavior {
                behavior = newBehavior
//                updateBehaviorTimestamps(behavior: newBehavior)
                updateIsInsideFlag(behavior: newBehavior)
                postDataIfNeeded(behavior: newBehavior) // Ensure this is called after updating behavior and flags
                if newBehavior == "In" || newBehavior == "Out" {
                    sendBehaviorNotification(behavior: newBehavior)
                    if newBehavior == "In" && !hasScheduledCheck {
                        scheduleRandomCheck()
                        hasScheduledCheck = true
                    }
                }
            }
//            postDataIfNeeded(behavior: newBehavior)
            updateIsCheckWindow()
            
            print("proximity list: \(combinedProximityList)")
            print("model prediction list: \(behaviorHistory)")
            print("pred : \(behavior)")
            print("isInside : \(isInside)")
            print("db_data: \(String(describing: db_data.created_at))")
        } catch {
            print("Error during prediction: \(error)")
        }
    }
    
    func checkcheck(){
        self.isInside = true
        self.isCheckWindow = true
    }
    
    private func updateIsCheckWindow() {
        if checkWindowTimestamp != nil && lastCheckSuccessTimestamp == nil{
            if checkWindowTimestamp ?? Date().addingTimeInterval(TimeInterval(10)) < Date(){
                self.isCheckWindow = true
            }else if checkWindowTimestamp ?? Date() > Date().addingTimeInterval(TimeInterval(-20)){
                self.isCheckWindow = false
            }
        }
    }
    
    private func mostFrequentBehavior(in list: [String]) -> String {
        let counts = list.reduce(into: [:]) { counts, behavior in counts[behavior, default: 0] += 1 }
        return counts.max { $0.value < $1.value }?.key ?? "Unknown"
    }
    
    private func sendBehaviorNotification(behavior: String) {
        let content = UNMutableNotificationContent()
        
        // Customize notification title and body based on behavior
        switch behavior {
        case "In":
            content.title = "Entry Detected"
            content.body = "You have entered the monitored area."
        case "Out":
            content.title = "Exit Detected"
            content.body = "You have exited the monitored area."
        default:
            content.title = "Behavior Change Detected"
            content.body = "New behavior: \(behavior)"
        }
        
        content.sound = UNNotificationSound.default
        
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: nil)
        UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
    }
    
    private func scheduleRandomCheck() {
        let randomInterval = TimeInterval.random(in: 240...250) // 10-30 minutes
        
        self.checkWindowTimestamp = Date().addingTimeInterval(randomInterval)
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: randomInterval, repeats: false)
        
        let content = UNMutableNotificationContent()
        content.title = "Random Check"
        content.body = "Please verify your identity within 5 minutes."
        content.sound = UNNotificationSound.default
        
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling random check notification: \(error)")
            } else {
                DispatchQueue.main.async {
                }
            }
        }
    }
    
//    private func updateBehaviorTimestamps(behavior: String) {
//        let currentTimestamp = Date()
//        if behavior == "In" && firstInTimestamp == nil {
//            firstInTimestamp = currentTimestamp
//        } else if behavior == "Out" && isInside {
//            lastOutTimestamp = currentTimestamp
//        }
//    }
    
    private func updateIsInsideFlag(behavior: String) {
        if isInside && behavior == "Out" {
            isInside = false
        } else if behavior == "In" {
            isInside = true
        }
    }
    
    func postDataIfNeeded(behavior: String) {
        if behavior == "In" && db_data.time_in == nil {
            postAttendanceData(behavior: "In")
        } else if behavior == "Checked" {
            postAttendanceData(behavior: "Checked")
        } else if !isInside && db_data.time_in != nil {
            postAttendanceData(behavior: "Out")
        }
    }
    
    func postAttendanceData(behavior: String) {
        self.db_data.device_id = device_id
        self.db_data.class_id = class_id
        self.db_data.student_id = student_id
        
        if behavior == "In"{
            let time_now = Date()
            self.db_data.time_in = time_now
            self.db_data.created_at = time_now
            Task {
                do {
                    let client = SupabaseClient(supabaseURL: URL(string: "https://edhzzdfkezgmtlrljjlt.supabase.co")!, supabaseKey: Constant.Api.apiKey)
                    let data : AttendanceActionModel = try await client
                        .from("attendance")
                        .insert(self.db_data)
                        .select()
                        .single()
                        .execute()
                        .value
                    DispatchQueue.main.async{
                        self.db_data = data
                    }
                } catch {
                    print("Error posting \(behavior) data to Supabase: \(error)")
                }
            }
        }else{
            Task {
                do {
                    var update : [String: Date] = [:]
                    if behavior == "Out"{
                        let now = Date()
                        update = ["time_out": now]
                        
                    }else if behavior == "Checked"{
                        let now = Date()
                        update = ["time_check": now]
                    }
                    let client = SupabaseClient(supabaseURL: URL(string: "https://edhzzdfkezgmtlrljjlt.supabase.co")!, supabaseKey: Constant.Api.apiKey)
                    let data : AttendanceActionModel = try await client
                        .from("attendance")
                        .update(update)
                        .eq("id", value: self.db_data.id)
                        .select()
                        .single()
                        .execute()
                        .value
                    DispatchQueue.main.async{
                        self.db_data = data
                    }
                } catch {
                    print("Error posting \(behavior) data to Supabase: \(error)")
                }
            }
        }
        
        
    }
    
    func handleBiometricAuthentication() {
        let context = LAContext()
        var error: NSError?
        
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            let reason = "Please authenticate to verify your identity."
            
            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) { success, authenticationError in
                DispatchQueue.main.async {
                    if success {
                        // Only store the timestamp if the user is inside
                        if self.isInside {
                            self.lastCheckSuccessTimestamp = Date()
                            self.postAttendanceData(behavior: "Checked")
                            // Reschedule next random check
                            self.isCheckWindow = false
                            print("--------------------------")
                            print("")
                            print("Biometric - Status Success")
                            print("")
                            print("--------------------------")
                        }
                    } else {
                        // Handle failed authentication
                        print("Authentication failed: \(String(describing: authenticationError))")
                    }
                    self.isCheckWindow = false
                }
            }
        } else {
            // Handle no biometrics available
            print("Biometrics not available: \(String(describing: error))")
            self.isCheckWindow = false
        }
    }

    func startScanning() {
        for constraint in beaconConstraints {
            let beaconRegion = CLBeaconRegion(beaconIdentityConstraint: constraint, identifier: constraint.uuid.uuidString)
            locationManager?.startMonitoring(for: beaconRegion)
            locationManager?.startRangingBeacons(satisfying: constraint)
            print("Started monitoring and ranging for beacon: \(constraint.uuid.uuidString)")
        }
    }
    
    func resetRandomCheck() {
        behavior = "Unknown"
        db_data = AttendanceActionModel()
        hasScheduledCheck = false
//        firstInTimestamp = nil
//        lastOutTimestamp = nil
//        outTimestamp = nil
        lastCheckSuccessTimestamp = nil
        checkWindowTimestamp = nil
        isInside = false
        firstInPosted = false
        lastOutPosted = false
        isCheckWindow = false
        // Optionally cancel any pending random check notifications
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }
}
