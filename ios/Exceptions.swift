import ExpoModulesCore

internal class CustomException: Exception {
    private let errorDetail: String

    init(info: String) {
        self.errorDetail = info
        super.init()
    }

    override var reason: String {
        return errorDetail
    }
}