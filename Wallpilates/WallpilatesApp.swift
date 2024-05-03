//
//  WallpilatesApp.swift
//  Wallpilates
//
//  Created by Nguyễn Mạnh Hùng on 24/4/24.
//

import SwiftUI
import StoreKitify

@main
struct WallpilatesApp: App {
    @State private var store = StoreKitify(productIdentifiers: [
        "fitee.subscription.monthly.plan",
        "fitee.subscription.yearly.plan",
    ])
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(store)
        }
    }
}
