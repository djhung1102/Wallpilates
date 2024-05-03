//
//  Screen2.swift
//  Wallpilates
//
//  Created by Nguyễn Mạnh Hùng on 3/5/24.
//

import SwiftUI
import StoreKit
import StoreKitify

struct Screen2: View {
    @State var showBottomSheet = false
//    @State var isPremium: Bool = false
    
    @State private var product: Product?
    @Environment(StoreKitify.self) private var store
    
    var body: some View {
        let _ = print("Screen 2")
        VStack {
            if !store.isPremium {
                Button("Buy Wall 2") {
                    showBottomSheet.toggle()
                }
            }
            
            Button("Restore Purchases", action: {
                Task {
                    try? await AppStore.sync()
                }
            })
            
            if store.isPremium {
                Text("Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry's standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book. It has survived not only five centuries, but also the leap into electronic typesetting, remaining essentially unchanged. It was popularised in the 1960s with the release of Letraset sheets containing Lorem Ipsum passages, and more recently with desktop publishing software like Aldus PageMaker including versions of Lorem Ipsum.")
                    .padding(10)
            }
        }
        .fullScreenCover(isPresented: $showBottomSheet, content: {
            WallView()
                .environment(store)
        })
//        .onChange(of: store.isPremium) { oldValue, newValue in
//            isPremium = newValue
//        }
    }
}

#Preview {
    Screen2()
        .environment(StoreKitify(productIdentifiers: [
            "fitee.subscription.monthly.plan",
            "fitee.subscription.yearly.plan",
        ]))
}
