import SwiftUI
import Didomi

class DidomiViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        Didomi.shared.setupUI(containerController: self)
    }
}

struct DidomiWrapper: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> UIViewController {
        DidomiViewController()
    }
    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {}
}
