import SwiftUI

@main
struct MeetNowApp: App {
    @State private var hasSelectedRole = UserDefaults.standard.bool(forKey: "hasSelectedRole")
    
    var body: some Scene {
        WindowGroup {
            NavigationStack {
                if hasSelectedRole {
                    MainView()
                } else {
                    LoginView()
                }
            }
        }
    }
}