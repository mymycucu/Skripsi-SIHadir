//
//  SIHadirApp.swift
//  SIHadir
//
//  Created by Hilmy Noerfatih on 28/05/24.
//

import SwiftUI

@main
struct SIHadirApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        WindowGroup {
            ContentView()
                .preferredColorScheme(.light)
        }
    }
}
