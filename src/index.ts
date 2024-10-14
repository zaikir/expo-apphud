import ApphudModule from "./ApphudModule";

/**
 * Starts the in-app purchases module with the provided API key and with the optional user ID.
 * @param apiKey The Apphud API key.
 * @param userId The optional user ID.
 * @returns A promise that resolves when the module has started.
 * @throws An error if the module fails to start.
 */
function start(apiKey: string, userId?: string): Promise<void> {
  return ApphudModule.start(apiKey, userId);
}

/**
 * Fetches the available products from the App Store.
 * @returns A promise that resolves with the available products.
 * @throws An error if the products could not be fetched.
 */
function fetchProducts(): Promise<IapProduct[]> {
  return ApphudModule.fetchProducts();
}

/**
 * Fetches a product by its ID.
 * @param id The product ID.
 * @returns A promise that resolves with the product.
 * @throws An error if the product could not be fetched.
 */
function getProductById(id: string): Promise<IapProduct> {
  return ApphudModule.getProductById(id);
}

/**
 * Checks if the user has an active premium subscription.
 * @returns A promise that resolves with a boolean indicating if the user has an active subscription.
 * @throws An error if the subscription status could not be checked.
 */
function hasActiveSubscription(): Promise<boolean> {
  return ApphudModule.hasActiveSubscription();
}

/**
 * Fetches the non-renewing purchases (consumables, non-consumables, or non-renewing subscriptions) made by the user.
 * @returns A promise that resolves with the non-renewing purchases.
 * @throws An error if the non-renewing purchases could not be fetched.
 */
function fetchUsersNonRenewingPurchases(): Promise<IapNonRenewingPurchase[]> {
  return ApphudModule.fetchNonRenewingPurchases();
}

/**
 * Purchases a product with the provided ID. Resolves with the purchase result.
 * @param id The product ID.
 * @returns A promise that resolves with the purchase result.
 * @throws An error if the product could not be purchased.
 */
function purchaseProduct(id: string): Promise<IapPurchaseResult> {
  return ApphudModule.purchaseProduct(id);
}

/**
 * Checks if the user is eligible for a trial for the provided product ID.
 * @param productId The product ID.
 * @returns A promise that resolves with a boolean indicating if the user is eligible for a trial.
 * @throws An error if the trial eligibility could not be checked.
 */
function isEligibleForTrial(productId: string): Promise<boolean> {
  return ApphudModule.isEligibleForTrial(productId);
}

/**
 * Checks if the user is eligible for a promo for the provided product ID.
 * @param productId The product ID.
 * @returns A promise that resolves with a boolean indicating if the user is eligible for a promo.
 * @throws An error if the promo eligibility could not be checked.
 */
function isEligibleForPromo(productId: string): Promise<boolean> {
  return ApphudModule.isEligibleForPromo(productId);
}

/**
 * Restores the user's purchases.
 * @returns A promise that resolves when the purchases have been restored.
 * @throws An error if the purchases could not be restored.
 */
function restorePurchases(): Promise<void> {
  return ApphudModule.restorePurchases();
}

/**
 * Get the app store receipt.
 * @returns A promise that resolves with the app store receipt.
 * @throws An error if the app store receipt could not be fetched or parsed.
 */
async function getAppStoreReceipt() {
  const json = await ApphudModule.getReciept();
  try {
    const receipt = JSON.parse(json) as AppStoreReceipt;
    return receipt;
  } catch {
    throw new Error("Failed to parse the app store receipt JSON.");
  }
}

/**
 * Get the raw app store receipt.
 * @returns A promise that resolves with the app store receipt.
 * @throws An error if the app store receipt could not be fetched or parsed.
 */
async function getRawAppStoreReceipt() {
  const result: AppStoreReceipt = await ApphudModule.getRawReciept();
  return result;
}

/**
 * Get Apphud user ID.
 * @returns A promise that resolves with the Apphud user ID.
 * @throws An error if the user ID could not be fetched.
 */
function getUserId(): Promise<string> {
  return ApphudModule.getUserId();
}

/**
 * Submits Device Identifiers (IDFA and IDFV) to Apphud. These identifiers may be required for marketing and attribution platforms such as AppsFlyer, Facebook, Singular, etc.
 * Best practice is to call this method right after SDK’s start(...) method and once again after getting IDFA.
 * @param idfa The IDFA (Identifier for Advertisers) identifier.
 * @param idfv The IDFV (Identifier for Vendors) identifier.
 * @returns A promise that resolves when the device identifiers have been submitted.
 * @throws An error if the device identifiers could not be submitted.
 */
function setDeviceIdentifiers({
  idfa,
  idfv,
}: {
  idfa?: string | null;
  idfv?: string | null;
}): Promise<void> {
  return ApphudModule.setDeviceIdentifiers(idfa, idfv);
}

type ApphudAttributionProvider =
  | "AppsFlyer"
  | "Adjust"
  | "Facebook"
  | "Apple Ads Attribution"
  | "Firebase"
  | "Custom";

/**
 * Submits attribution data to Apphud from your chosen attribution network provider.
 * @param data Required. The attribution data dictionary.
 * @param provider Required. The name of the attribution provider.
 * @param identifier Optional. An identifier that matches between Apphud and the Attribution provider. This is required for AppsFlyer.
 * @returns A promise that resolves when the attribution data has been submitted.
 * @throws An error if the attribution data could not be submitted.
 */
function addAttribution(
  data: Record<string, any>,
  provider: ApphudAttributionProvider,
  identifier?: string,
): Promise<void> {
  return ApphudModule.addAttribution(data, provider, identifier);
}

export const InAppPurchases = {
  start,
  fetchProducts,
  getProductById,
  hasActiveSubscription,
  fetchUsersNonRenewingPurchases,
  purchaseProduct,
  isEligibleForTrial,
  isEligibleForPromo,
  restorePurchases,
  getAppStoreReceipt,
  getRawAppStoreReceipt,
  getUserId,
  setDeviceIdentifiers,
  addAttribution,
};

type LocaleMap = {
  currencySymbol: string;
  currencyCode: string;
  countryCode: string;
};

type SubscriptionPeriodMap = {
  numberOfUnits: number;
  unit: number; // Assuming `unit.rawValue` is an integer. Adjust if necessary.
};

type DiscountMap = {
  price: number;
  numberOfPeriods: number;
  subscriptionPeriod: SubscriptionPeriodMap;
  paymentMode: number; // Assuming `paymentMode.rawValue` is an integer. Adjust if necessary.
};

export type IapProduct = {
  localizedTitle: string;
  priceLocale: LocaleMap;
  price: number;
  subscriptionPeriod?: SubscriptionPeriodMap;
  introductoryPrice?: DiscountMap;
  id: string;
  store: string;
};

export type IapNonRenewingPurchase = {
  productId: string;
  purchasedAt: number;
  canceledAt?: number;
  isActive: boolean;
};

interface IapPurchaseResult {
  transaction_id: string;
  product_id: string;
  subscription_status: string | null;
  non_renewing_purchase_status: string | null;
  error: string | null;
  success: boolean;
}

export type AppStoreReceipt = {
  receipt_type: string;
  adam_id: number;
  app_item_id: number;
  bundle_id: string;
  application_version: string;
  download_id: number;
  version_external_identifier: number;
  receipt_creation_date: string;
  receipt_creation_date_ms: string;
  receipt_creation_date_pst: string;
  request_date: string;
  request_date_ms: string;
  request_date_pst: string;
  original_purchase_date: string;
  original_purchase_date_ms: string;
  original_purchase_date_pst: string;
  original_application_version: string;
  in_app: InAppPurchaseReceipt[];
};

type InAppPurchaseReceipt = {
  quantity: string;
  product_id: string;
  transaction_id: string;
  original_transaction_id: string;
  purchase_date: string;
  purchase_date_ms: string;
  purchase_date_pst: string;
  original_purchase_date: string;
  original_purchase_date_ms: string;
  original_purchase_date_pst: string;
  expires_date?: string;
  expires_date_ms?: string;
  expires_date_pst?: string;
  web_order_line_item_id?: string;
  is_trial_period: string;
  is_in_intro_offer_period: string;
  promotional_offer_id?: string;
};
