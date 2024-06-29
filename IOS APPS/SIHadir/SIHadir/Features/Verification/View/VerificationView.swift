//
//  VerficationView.swift
//  SIHadir
//
//  Created by Hilmy Noerfatih on 29/05/24.
//

import SwiftUI
import LocalAuthentication

struct VerificationView: View {
    @Binding var isPresented: Bool
    @State private var isAuthenticated = false
    @State private var authenticationError: String?
    @State private var showSuccessMessage = false
    @State private var showFailureMessage = false
    @State private var notInsideMessage = false
    @State private var showAlert = false

    var body: some View {
        VStack {
            Text("Random Check")
                .font(.largeTitle)
                .padding()
            
            if showSuccessMessage {
                Text("Verification Successful")
                    .foregroundColor(.green)
                    .padding()
            }
            
            if showFailureMessage {
                Text("Verification Failed")
                    .foregroundColor(.red)
                    .padding()
            }
            
            if let error = authenticationError {
                Text(error)
                    .foregroundColor(.red)
                    .padding()
            }
            
            Button(action: authenticate) {
                Text("Verify")
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
            .padding()
            
            if showSuccessMessage {
                Button(action: {
                    // Redirect to AttendanceView
                    self.isPresented = false
                }) {
                    Text("Go to Attendance")
                        .padding()
                        .background(Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
                .padding()
            }
        }
        .onAppear {
            // Trigger authentication when the view appears
            authenticate()
        }
        .alert(isPresented: $showAlert) {
            Alert(title: Text("Verification Failed"), message: Text("You are not inside the room."), dismissButton: .default(Text("OK")))
        }
    }
    
    private func authenticate() {
        let context = LAContext()
        var error: NSError?
        
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            let reason = "Please authenticate to verify your identity."
            
            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) { success, authenticationError in
                DispatchQueue.main.async {
                    if success {
                        // Only store the timestamp if the user is inside
                        if BeaconFinder.shared.isInside {
                            BeaconFinder.shared.lastCheckSuccessTimestamp = Date()
                            BeaconFinder.shared.postAttendanceData(behavior: "Checked")
                            self.isAuthenticated = true
                            self.authenticationError = nil
                            self.showSuccessMessage = true
                            self.showFailureMessage = false
                            self.notInsideMessage = false
                            // Reschedule next random check
                            //BeaconFinder.shared.scheduleRandomCheck()
                        } else {
                            self.isAuthenticated = false
                            self.showSuccessMessage = false
                            self.showFailureMessage = false
                            self.notInsideMessage = true
                            self.showAlert = true // Show the alert
                        }
                    } else {
                        self.authenticationError = authenticationError?.localizedDescription
                        self.showSuccessMessage = false
                        self.showFailureMessage = true
                        self.notInsideMessage = false
                    }
                }
            }
        } else {
            self.authenticationError = error?.localizedDescription
        }
    }
}



#Preview {
    VerificationView(isPresented: .constant(true))
}
