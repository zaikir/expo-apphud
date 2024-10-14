import ExpoModulesCore

internal class ApphudException: Exception {
  private let errorMessage: String

  init(message: String) {
    self.errorMessage = message
    super.init()
  }

  override var reason: String {
    return errorMessage
  }
}
