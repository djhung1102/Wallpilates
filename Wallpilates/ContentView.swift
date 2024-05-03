//
//  ContentView.swift
//  Wallpilates
//
//  Created by Nguyễn Mạnh Hùng on 24/4/24.
//

import SwiftUI
import StoreKit
import StoreKitify

struct ContentView: View {
    @Environment(StoreKitify.self) private var store
    
    var body: some View {
        TabView {
            Screen1()
                .environment(store)
                .tabItem {
                    Label("Screen1", systemImage: "film")
                }
            Screen2()
                .environment(store)
                .tabItem {
                    Label("Screen2", systemImage: "tv")
                }
            Screen3()
                .environment(store)
                .tabItem {
                    Label("Screen3", systemImage: "globe")
                }
        }
    }
}

#Preview {
    ContentView()
        .environment(StoreKitify(productIdentifiers: [
            "fitee.subscription.monthly.plan",
            "fitee.subscription.yearly.plan",
        ]))
}
