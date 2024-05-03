//
//  WallStore.swift
//  Wallpilates
//
//  Created by Nguyễn Mạnh Hùng on 24/4/24.
//

import Foundation
import StoreKit

enum WallError: LocalizedError {
    case failedVerification
    case system(Error)
    
    var errorDescription: String? {
        switch self {
            case .failedVerification:
                return "User transaction verification failed"
            case .system(let error):
                return error.localizedDescription
        }
    }
}

enum WallAction: Equatable {
    static func == (lhs: WallAction, rhs: WallAction) -> Bool {
        switch (lhs, rhs) {
            case (.successful, .successful):
                return true
            case (let .failed(lhsErr), let .failed(rhsErr)):
                return lhsErr.localizedDescription == rhsErr.localizedDescription
            default:
                return false
        }
    }
    
    case successful
    case failed(WallError)
}

@Observable final class WallStore {
     var items = [Product]()
     var purchasedCourses : [Product] = []
     var isPremium: Bool = false
    
    private(set) var action: WallAction? {
        didSet {
            switch action {
                case .successful:
                    hasError = false
                case .failed(let wallError):
                    hasError = true
                case nil:
                    hasError = false
            }
        }
    }
    
    var hasError = false
    
    var error: WallError? {
        switch action {
            case .successful:
                return nil
            case .failed(let wallError):
                return wallError
            case nil:
                return nil
        }
    }
    
    private var transactionListener: Task<Void, Error>?
    
    init() {
        // Start a transaction listener as close to the app launch as possible so you don't miss any transaction
        transactionListener = configureTransactionListener()
        
        Task {
            await retrieveProducts()
            
            // deliver the products that the customer purchased
            await updateCustomerProductStatus()
        }
    }
    
    // denit transaction listener on exit or app close
    deinit {
        transactionListener?.cancel()
    }
    
    func purchase(item: Product) async {
        do {
            let result = try await item.purchase()
            
            try await handlePurchase(from: result)
        } catch {
            action = .failed(.system(error))
            print(error)
        }
    }
}

extension WallStore {
    
    // listen for transactions - start this early in the app
    func configureTransactionListener() -> Task<Void, Error> {
        Task.detached(priority: .background) { @MainActor [weak self] in
            do {
                for await result in Transaction.updates {
                    let transaction = try self?.checkVerified(result)
                    
                    await self?.updateCustomerProductStatus()
                    
                    self?.action = .successful
                    
                    await transaction?.finish()
                }
            } catch {
                self?.action = .failed(.system(error))
                print(error)
            }
        }
    }
    
    // request the products in the background
    func retrieveProducts() async {
        do {
            let products = try await Product.products(for: myWallProductIdentifiers)
            items = products
        } catch {
            action = .failed(.system(error))
            print(error)
        }
    }
    
    func handlePurchase(from result: Product.PurchaseResult) async throws {
        switch result {
            case .success(let verificationResult):
                let transaction = try checkVerified(verificationResult)

                await updateCustomerProductStatus()
                
                action = .successful
                await transaction.finish()
            case .userCancelled:
                print("The user hit cancel before their transaction started")
            case .pending:
                print("The user needs to complete some action on their account before they can complete purchase")
            default:
                print("Unknown error")
        }
    }
    
    // check the verificationResults
    func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
        switch result {
            case .unverified:
                print("The verification of the user failed")
                throw WallError.failedVerification
            case .verified(let signedType):
                return signedType
        }
    }
    
    // update the customers products
    @MainActor
    func updateCustomerProductStatus() async {
        var purchasedCourses: [Product] = []
        
        for await result in Transaction.currentEntitlements {
            do {
                //again check if transaction is verified
                let transaction = try checkVerified(result)
                
                if transaction.productID.isEmpty == false {
                    isPremium = true
                }
                
                if let course = items.first(where: { $0.id == transaction.productID}) {
                    purchasedCourses.append(course)
                    self.purchasedCourses = purchasedCourses
                }
            } catch {
                // storekit has a transaction that fails verification, don't delvier content to the user
                print("Transaction failed verification")
            }
            
        }
    }
    
}
