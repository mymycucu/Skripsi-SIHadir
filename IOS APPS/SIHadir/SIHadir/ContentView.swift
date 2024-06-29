//
//  ContentView.swift
//  SIHadir
//
//  Created by Hilmy Noerfatih on 28/05/24.
//

import SwiftUI

struct ContentView: View {
    
    var body: some View {
        AttendanceView()
            .onAppear {
                BeaconFinder.shared.requestLocationPermission()
                BeaconFinder.shared.startScanning()
            }
    }
}

// Preview
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

