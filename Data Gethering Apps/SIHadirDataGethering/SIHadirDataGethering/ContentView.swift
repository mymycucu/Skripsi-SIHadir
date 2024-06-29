//
//  ContentView.swift
//  SIHadirDataGethering
//
//  Created by Hilmy Noerfatih on 13/02/24.
//

import SwiftUI

struct ContentView: View {
    @StateObject var beaconFinder: BeaconFinder
    @StateObject var beaconFinder1: BeaconFinder
    
    @State private var isLoading = false
    @State private var tab = 1
    
    init() {
        _beaconFinder = StateObject.init(wrappedValue: BeaconFinder(
            beaconUUID: UUID(uuidString: "96B4164C-4EEB-55A7-DC43-BC177AEF8239")!,
            beaconMajor: UInt16(10),
            beaconMinor: UInt16(1)
        ))
        
        _beaconFinder1 = StateObject.init(wrappedValue: BeaconFinder(
            beaconUUID: UUID(uuidString: "163C6000-3605-028B-5F49-AACA39B6C76D")!,
            beaconMajor: UInt16(10),
            beaconMinor: UInt16(1)
        ))
    }
    
    var body: some View {
        ZStack{
            TabView(selection: $tab){
                BeaconView(beaconFinder: beaconFinder, beaconFinder1: beaconFinder1, isLoading: $isLoading)
                    .tabItem {
                        Label("beacon", systemImage: "dot.radiowaves.left.and.right")
                    }.tag(0)
                ActionDataGetheringView(beaconFinder: beaconFinder, beaconFinder1: beaconFinder1, isLoading: $isLoading)
                    .tabItem {
                        Label("action", systemImage: "dot.radiowaves.left.and.right")
                    }.tag(1)
                BeaconDataListView(isLoading: $isLoading)
                    .tabItem {
                        Label("data1", systemImage: "book" )
                    }.tag(2)
            }
            
            if isLoading{
                ZStack{
                    Color(.systemBackground)
                        .ignoresSafeArea()
                        .opacity(0.8)
                    
                    ProgressView()
                        .scaleEffect(3)
                }
            }
        }
    }
}

#Preview {
    ContentView()
}
