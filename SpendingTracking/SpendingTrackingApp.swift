//
//  SpendingTrackingApp.swift
//  SpendingTracking
//
//  Created by carl on 12/14/24.
//

import SwiftUI

@main
struct SpendingTrackingApp: App {
    var body: some Scene {
        WindowGroup {
//            ContentView()
            ContentView(spendings: MockData.spendings)
        }
    }
}
