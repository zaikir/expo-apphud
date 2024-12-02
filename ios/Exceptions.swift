import ExpoModulesCore

internal class ApphudException: Exception {
    private let errorDetail: String

    init(info: String) {
        self.errorDetail = info
        super.init()
    }

    override var reason: String {
        return errorDetail
    }
}