import SwiftUI

@main
struct KidsStoryQuizApp: App {
    @StateObject private var appModel = AppModel()
    @StateObject private var narration = NarrationManager()
    @StateObject private var navigation = AppNavigationModel()

    var body: some Scene {
        WindowGroup {
            AppRootView()
                .environmentObject(appModel)
                .environmentObject(narration)
                .environmentObject(navigation)
        }
    }
}
