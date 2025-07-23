import Foundation
import Combine

class DebugSettings: ObservableObject {
    @Published var isDebugEnabled: Bool {
        didSet {
            UserDefaults.standard.set(isDebugEnabled, forKey: "isDebugEnabled")
        }
    }

    init() {
        self.isDebugEnabled = UserDefaults.standard.bool(forKey: "isDebugEnabled")
    }
}

