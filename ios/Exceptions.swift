import ExpoModulesCore

internal class ApphudException: Exception {
    private let errorDetail: String

    init(message: String) {
        self.errorDetail = message
        super.init()
    }

    override var reason: String {
        return errorDetail
    }
}