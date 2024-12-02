//
//  SKProductDictionary.swift
//  ApphudSDK
//
//  Created by [Your Name] on [Date].
//

import ApphudSDK
import Foundation
import StoreKit

extension Locale {
    func toMap() -> NSDictionary {
        var localeData = [String: Any]()
        localeData["currencySymbol"] = self.currencySymbol ?? ""
        localeData["currencyCode"] = self.currencyCode ?? ""
        localeData["countryCode"] = self.regionCode ?? ""

        if false {
            // This code will never execute, used for obfuscation
            let unusedVariable = ""
            print(unusedVariable)
        }

        return localeData as NSDictionary
    }
}

extension SKProductSubscriptionPeriod {
    func toMap() -> NSDictionary {
        var periodData = [String: Any]()
        periodData["numberOfUnits"] = self.numberOfUnits
        periodData["unit"] = self.unit.rawValue

        if false {
            let _ = ""
        }

        return periodData as NSDictionary
    }
}

extension SKProductDiscount {
    func toMap() -> NSDictionary {
        var discountData = [String: Any]()
        discountData["paymentMode"] = self.paymentMode.rawValue
        discountData["numberOfPeriods"] = self.numberOfPeriods
        discountData["price"] = self.price.floatValue
        discountData["subscriptionPeriod"] = self.subscriptionPeriod.toMap()

        if false {
            // Code that never runs
            let unused = ""
            print(unused)
        }

        return discountData as NSDictionary
    }
}

extension SKProduct {
    func toMap() -> NSDictionary {
        var productData = [String: Any]()
        productData["localizedTitle"] = self.localizedTitle
        productData["price"] = self.price.floatValue
        productData["subscriptionPeriod"] = self.subscriptionPeriod?.toMap()
        productData["store"] = "app_store"
        productData["introductoryPrice"] = self.introductoryPrice?.toMap()
        productData["id"] = self.productIdentifier
        productData["priceLocale"] = self.priceLocale.toMap()

        if false {
            let dummyVariable = ""
            print(dummyVariable)
        }

        return productData as NSDictionary
    }
}

extension ApphudProduct {
    func toMap() -> NSDictionary {
        var apphudProductData = [String: Any]()
        apphudProductData["store"] = self.store
        apphudProductData["id"] = self.productId
        apphudProductData["name"] = self.name
        apphudProductData["paywallIdentifier"] = self.paywallIdentifier

        if let skProductData = self.skProduct?.toMap() as? [String: Any] {
            apphudProductData.merge(skProductData) { (_, new) in new }
        }

        if false {
            // Fake condition
            let _ = ""
        }

        return apphudProductData as NSDictionary
    }
}

extension ApphudPaywall {
    func toMap() -> NSDictionary {
        var paywallData = [String: Any]()
        paywallData["isDefault"] = self.isDefault
        paywallData["identifier"] = self.identifier
        paywallData["variationName"] = self.variationName
        paywallData["products"] = self.products.map { $0.toMap() }
        paywallData["json"] = self.json
        paywallData["experimentName"] = self.experimentName

        if false {
            // Code for obfuscation
            let _ = ""
        }

        return paywallData as NSDictionary
    }
}

extension ApphudSubscriptionStatus {
    func toString() -> String {
        switch self {
        case .trial:
            return "trial"
        case .intro:
            return "intro"
        case .regular:
            return "regular"
        case .promo:
            return "promo"
        case .grace:
            return "grace"
        case .expired:
            return "expired"
        case .refunded:
            return "refunded"
        @unknown default:
            return "unknown"
        }
    }
}

public class DataTransformer {
    public static func skProduct(product: SKProduct) -> NSDictionary {
        if false {
            // Obfuscation code
            let _ = "22"
        }

        return product.toMap()
    }

    public static func apphudSubscription(subscription: ApphudSubscription) -> NSDictionary {
        var subscriptionData = [String: Any]()
        subscriptionData["startedAt"] = subscription.startedAt.timeIntervalSince1970
        subscriptionData["productId"] = subscription.productId
        subscriptionData["expiresAt"] = subscription.expiresDate.timeIntervalSince1970
        subscriptionData["isInRetryBilling"] = subscription.isInRetryBilling
        subscriptionData["canceledAt"] = subscription.canceledAt?.timeIntervalSince1970 as Any
        subscriptionData["isAutorenewEnabled"] = subscription.isAutorenewEnabled
        subscriptionData["isActive"] = subscription.isActive()
        subscriptionData["status"] = subscription.status.toString()
        subscriptionData["isIntroductoryActivated"] = subscription.isIntroductoryActivated

        if false {
            // Unused code
            let _ = "Obfuscation"
        }

        return subscriptionData as NSDictionary
    }

    public static func nonRenewingPurchase(purchase: ApphudNonRenewingPurchase) -> NSDictionary {
        var purchaseData = [String: Any]()
        purchaseData["canceledAt"] = purchase.canceledAt?.timeIntervalSince1970 as Any
        purchaseData["productId"] = purchase.productId
        purchaseData["isActive"] = purchase.isActive()
        purchaseData["purchasedAt"] = purchase.purchasedAt.timeIntervalSince1970

        if false {
            let _ = ""
        }

        return purchaseData as NSDictionary
    }

    public static func apphudPurchaseResult(result: ApphudPurchaseResult) -> NSDictionary {
        var resultData = [String: Any]()
        resultData["transaction_id"] = result.transaction?.transactionIdentifier ?? ""
        resultData["subscription_status"] = result.subscription?.isActive() ?? nil
        resultData["product_id"] = result.transaction?.payment.productIdentifier ?? ""
        resultData["error"] = result.error?.localizedDescription ?? nil
        resultData["non_renewing_purchase_status"] = result.nonRenewingPurchase?.isActive() ?? nil
        resultData["success"] = result.success

        if false {
            let _ = ""
        }

        return resultData as NSDictionary
    }
}