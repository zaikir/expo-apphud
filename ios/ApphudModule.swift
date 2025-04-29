import ApphudSDK
import ExpoModulesCore
import Foundation
import StoreKit

public class ApphudModule: Module {
  public func definition() -> ModuleDefinition {
    Name("Apphud")

    AsyncFunction("start") { (apiKey: String, userID: String?, promise: Promise) in
      DispatchQueue.main.async {
        Apphud.start(apiKey: apiKey, userID: userID)
        promise.resolve(nil)
      }
    }

    AsyncFunction("fetchProducts") { (promise: Promise) in
      Apphud.fetchProducts { products, error in
        if let error = error {
          promise.reject(ApphudException(message: error.localizedDescription))
        } else {
          if products.count > 0 {
            promise.resolve(products.map { DataTransformer.skProduct(product: $0) })
          } else {
            promise.resolve([])
          }
        }
      }

    }

    AsyncFunction("getProductById") { (productId: String, promise: Promise) in

      Apphud.fetchProducts { products, error in
        if let error = error {
          promise.reject(ApphudException(message: error.localizedDescription))
        } else {
          if let product = products.first(where: { $0.productIdentifier == productId }) {
            promise.resolve(DataTransformer.skProduct(product: product))
          } else {
            promise.reject(ApphudException(message: "Product with id \(productId) not found"))
          }
        }
      }

    }

    AsyncFunction("hasActiveSubscription") { (promise: Promise) in
      promise.resolve(Apphud.hasActiveSubscription())
    }

    AsyncFunction("fetchNonRenewingPurchases") { (promise: Promise) in
      DispatchQueue.main.async {
        guard let purchases = Apphud.nonRenewingPurchases() else {
          promise.reject(ApphudException(message: "Apphud not initialized"))
          return
        }
        let transformedPurchases = purchases.map {
          DataTransformer.nonRenewingPurchase(nonRenewingPurchase: $0)
        }
        promise.resolve(transformedPurchases)

      }
    }

    AsyncFunction("purchaseProduct") { (productId: String, promise: Promise) in
      DispatchQueue.main.async {
        Apphud.purchase(productId) { purchaseResult in
          promise.resolve(DataTransformer.apphudPurchaseResult(purchaseResult: purchaseResult))
        }
      }
    }

    AsyncFunction("isEligibleForTrial") { (productId: String, promise: Promise) in
      let product = Apphud.product(productIdentifier: productId)
      if let product = product {
        Apphud.checkEligibilityForIntroductoryOffer(product: product) { isEligible in
          promise.resolve(isEligible)
        }
      } else {
        promise.reject(ApphudException(message: "Product with id \(productId) not found"))
      }
    }

    AsyncFunction("isEligibleForPromo") { (productId: String, promise: Promise) in
      let product = Apphud.product(productIdentifier: productId)
      if let product = product {
        Apphud.checkEligibilityForPromotionalOffer(product: product) { isEligible in
          promise.resolve(isEligible)
        }
      } else {
        promise.reject(ApphudException(message: "Product with id \(productId) not found"))
      }
    }

    AsyncFunction("restorePurchases") { (promise: Promise) in
      DispatchQueue.main.async {
        Apphud.restorePurchases { _, _, error in
          if let error = error {
            promise.reject(ApphudException(message: error.localizedDescription))
          } else {
            promise.resolve(nil)
          }
        }
      }
    }

    AsyncFunction("getReciept") { (promise: Promise) in
      Apphud.fetchRawReceiptInfo { receipt in
        promise.resolve(receipt?.rawJSON)
      }
    }

    AsyncFunction("getRawReciept") { (promise: Promise) in
      guard let receiptURL = Bundle.main.appStoreReceiptURL else {
        print("No receipt URL found.")
        promise.resolve(nil)
        return
      }

      do {
        let receiptData = try Data(contentsOf: receiptURL)
        let base64EncodedReceipt = receiptData.base64EncodedString(options: [])
        promise.resolve(base64EncodedReceipt)
        return
      } catch {
        print("Failed to read receipt data: \(error)")
        promise.resolve(nil)
        return
      }
    }

    AsyncFunction("getUserId") { (promise: Promise) in
      DispatchQueue.main.async {
        promise.resolve(Apphud.userID())
      }
    }

    AsyncFunction("setDeviceIdentifiers") { (idfa: String?, idfv: String?, promise: Promise) in
      Apphud.setDeviceIdentifiers(idfa: idfa, idfv: idfv)
      promise.resolve(nil)
    }

    AsyncFunction("addAttribution") {
      (data: [String: Any], provider: String, identifier: String?, promise: Promise) in
      var apphudProvider: ApphudAttributionProvider?

      switch provider {
      case "AppsFlyer":
        apphudProvider = .appsFlyer
      case "Adjust":
        apphudProvider = .adjust
      case "Facebook":
        apphudProvider = .facebook
      case "Apple Ads Attribution":
        apphudProvider = .appleAdsAttribution
      case "Firebase":
        apphudProvider = .firebase
      case "Custom":
        apphudProvider = .custom
      default:
        promise.reject(ApphudException(message: "Invalid provider"))
        return
      }

      if let apphudProvider = apphudProvider {
        Apphud.addAttribution(data: data, from: apphudProvider, identifer: identifier) { success in
          promise.resolve(success)
        }
      } else {
        promise.reject(ApphudException(message: "Invalid provider"))
      }
    }

    AsyncFunction("fetchPlacements") { () async throws -> [[String: Any]] in
      return try await withCheckedThrowingContinuation { continuation in
        Task { @MainActor in
          Apphud.fetchPlacements { placements, error in
            if let error = error {
              continuation.resume(throwing: ApphudException(message: error.localizedDescription))
            } else {
              let dict = placements.map { placement in
                var paywallDict: [String: Any] = [:]
                if let paywall = placement.paywall {
                  paywallDict = [
                    "experimentName": paywall.experimentName,
                    "identifier": paywall.identifier,
                    "isDefault": paywall.isDefault,
                    "json": paywall.json,
                    "parentPaywallIdentifier": paywall.parentPaywallIdentifier,
                    "placementIdentifier": paywall.placementIdentifier,
                    "variationName": paywall.variationName,
                    "products": paywall.products.compactMap { product in
                      product.skProduct != nil
                        ? DataTransformer.skProduct(product: product.skProduct!) : nil
                    },
                  ]

                }
                return [
                  "experimentName": placement.experimentName,
                  "identifier": placement.identifier,
                  "paywall": paywallDict,
                ]
              }
              continuation.resume(returning: dict)
            }
          }
        }
      }
    }

  }
}
