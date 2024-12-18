//
//  FlamoreApp.swift
//  Flamore
//
//  Created by Hoffer Andras on 2024. 12. 17..
//

import SwiftUI

@main
struct FlamoreApp: App {
    @StateObject private var userData = UserData()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(userData)
        }
    }
}
