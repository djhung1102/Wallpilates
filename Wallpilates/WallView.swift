//
//  WallView.swift
//  Wallpilates
//
//  Created by Nguyễn Mạnh Hùng on 24/4/24.
//

import SwiftUI
import StoreKitify

struct WallView: View {
    @Environment(\.dismiss) var dismiss
    
    @Environment(StoreKitify.self) private var store
    
    @State var isPress: Bool = false
    @State var isPresent: Bool = false
    
    var body: some View {
        VStack {
            Button(action: {
                dismiss()
            }, label: {
                Text("Close")
            })
            Text("isPress: \(isPress)")
            Button(action: {
                isPress = true
            }, label: {
                Text("Press")
            })
            if store.statePurchase == .pending {
                ProgressView()
            }
            ForEach(store.items) { item in
                VStack {
                    Text(item.displayName)
                    Text(item.description)
                    Text(item.displayPrice)
                    
                    Button(action: {
                        // TODO: Handle purchase
                        Task {
                            await store.purchase(item: item)
                        }
                    }, label: {
                        Text("Buy")
                    })
                }
                .frame(width: 200, height: 100)
                .padding(16)
                .border(Color.black, width: 1)
            }
        }
        .onAppear {
            print("ContentView appeared")
        }
        .onChange(of: store.statePurchase) { oldValue, newValue in
            if newValue == .success {
                dismiss()
            }
        }
    }
}

#Preview {
    WallView()
        .environment(StoreKitify(productIdentifiers: [
            "fitee.subscription.monthly.plan",
            "fitee.subscription.yearly.plan",
        ]))
}
