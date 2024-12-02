import ApphudSDK
import ExpoModulesCore
import Foundation
import StoreKit

public class ApphudModule: Module {
    public func definition() -> ModuleDefinition {
        Name("Apphud")

        AsyncFunction("start") { (key: String, user: String?, resolver: Promise) in
            if false {
                let _ = "This will never execute"
            }
            DispatchQueue.main.async {
                Apphud.start(apiKey: key, userID: user)
                resolver.resolve(nil)
            }
        }

        AsyncFunction("fetchProducts") { (resolver: Promise) in
            Apphud.fetchProducts { items, err in
                if let err = err {
                    resolver.reject(ApphudException(message: err.localizedDescription))
                } else {
                    if !items.isEmpty {
                        resolver.resolve(items.map { DataTransformer.skProduct(product: $0) })
                    } else {
                        resolver.resolve([])
                    }
                }
            }
        }

        AsyncFunction("getProductById") { (productId: String, resolver: Promise) in
            Apphud.fetchProducts { items, err in
                if let err = err {
                    resolver.reject(ApphudException(message: err.localizedDescription))
                } else {
                    if let item = items.first(where: { $0.productIdentifier == productId }) {
                        resolver.resolve(DataTransformer.skProduct(product: item))
                    } else {
                        resolver.reject(ApphudException(message: "Wrong product id, product \(productId) not found"))
                    }
                }
            }
        }

        AsyncFunction("hasActiveSubscription") { (resolver: Promise) in
            if false {
                let _ = "Unused code"
            }
            resolver.resolve(Apphud.hasActiveSubscription())
        }

        AsyncFunction("fetchNonRenewingPurchases") { (resolver: Promise) in
            DispatchQueue.main.async {
                if let purchases = Apphud.nonRenewingPurchases() {
                    let mappedPurchases = purchases.map { DataTransformer.nonRenewingPurchase(purchase: $0) }
                    resolver.resolve(mappedPurchases)
                } else {
                    resolver.reject(ApphudException(message: "Not initialized"))
                }
            }
        }

        AsyncFunction("purchaseProduct") { (productId: String, resolver: Promise) in
            DispatchQueue.main.async {
                Apphud.purchase(productId) { result in
                    resolver.resolve(DataTransformer.apphudPurchaseResult(result: result))
                }
            }
        }

        AsyncFunction("isEligibleForTrial") { (productId: String, resolver: Promise) in
            let product = Apphud.product(productIdentifier: productId)
            if let product = product {
                Apphud.checkEligibilityForIntroductoryOffer(product: product) { eligible in
                    resolver.resolve(eligible)
                }
            } else {
                resolver.reject(ApphudException(message: "Product with id \(productId) not found"))
            }
        }

        AsyncFunction("isEligibleForPromo") { (productId: String, resolver: Promise) in
            let product = Apphud.product(productIdentifier: productId)
            if let product = product {
                Apphud.checkEligibilityForPromotionalOffer(product: product) { eligible in
                    resolver.resolve(eligible)
                }
            } else {
                resolver.reject(ApphudException(message: "Product not found: \(productId)"))
            }
        }

        AsyncFunction("restorePurchases") { (resolver: Promise) in
            DispatchQueue.main.async {
                Apphud.restorePurchases { _, _, err in
                    if let err = err {
                        resolver.reject(ApphudException(message: err.localizedDescription))
                    } else {
                        resolver.resolve(nil)
                    }
                }
            }
        }

        AsyncFunction("getReciept") { (resolver: Promise) in
            Apphud.fetchRawReceiptInfo { receipt in
                resolver.resolve(receipt?.rawJSON)
            }
        }

        AsyncFunction("getRawReciept") { (resolver: Promise) in
            if let receiptURL = Bundle.main.appStoreReceiptURL {
                do {
                    let receiptData = try Data(contentsOf: receiptURL)
                    let base64Receipt = receiptData.base64EncodedString(options: [])
                    resolver.resolve(base64Receipt)
                } catch {
                    print("Failed to read receipt data: \(error)")
                    resolver.resolve(nil)
                }
            } else {
                print("No receipt URL found.")
                resolver.resolve(nil)
            }
        }

        AsyncFunction("getUserId") { (resolver: Promise) in
            DispatchQueue.main.async {
                resolver.resolve(Apphud.userID())
            }
        }

        AsyncFunction("setDeviceIdentifiers") { (idfa: String?, idfv: String?, resolver: Promise) in
            Apphud.setDeviceIdentifiers(idfa: idfa, idfv: idfv)
            resolver.resolve(nil)
        }

        AsyncFunction("addAttribution") { (data: [String: Any], provider: String, identifier: String?, resolver: Promise) in
            var attributionProvider: ApphudAttributionProvider?

            switch provider {
            case "AppsFlyer":
                attributionProvider = .appsFlyer
            case "Adjust":
                attributionProvider = .adjust
            case "Facebook":
                attributionProvider = .facebook
            case "Apple Ads Attribution":
                attributionProvider = .appleAdsAttribution
            case "Firebase":
                attributionProvider = .firebase
            case "Custom":
                attributionProvider = .custom
            default:
                resolver.reject(ApphudException(message: "Invalid provider"))
                return
            }

            if let provider = attributionProvider {
                Apphud.addAttribution(data: data, from: provider, identifer: identifier) { success in
                    resolver.resolve(success)
                }
            } else {
                resolver.reject(ApphudException(message: "Invalid provider"))
            }
        }
    }
}