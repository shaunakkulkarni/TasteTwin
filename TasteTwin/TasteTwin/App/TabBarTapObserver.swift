import SwiftUI
import UIKit

struct TabBarTapObserver: UIViewControllerRepresentable {
    let onTap: (Int) -> Void

    func makeUIViewController(context: Context) -> ObserverViewController {
        let controller = ObserverViewController()
        controller.onDidMoveToWindow = {
            controller.attachDelegateIfNeeded(context.coordinator)
        }
        return controller
    }

    func updateUIViewController(_ uiViewController: ObserverViewController, context: Context) {
        context.coordinator.onTap = onTap
        uiViewController.attachDelegateIfNeeded(context.coordinator)
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(onTap: onTap)
    }
}

final class ObserverViewController: UIViewController {
    var onDidMoveToWindow: (() -> Void)?

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        onDidMoveToWindow?()
    }

    func attachDelegateIfNeeded(_ coordinator: TabBarTapObserver.Coordinator) {
        guard let tabBarController = nearestTabBarController() else { return }
        coordinator.attach(to: tabBarController)
    }

    private func nearestTabBarController() -> UITabBarController? {
        var current: UIViewController? = self
        while let controller = current {
            if let tab = controller as? UITabBarController {
                return tab
            }
            current = controller.parent
        }
        return tabBarController
    }
}

extension TabBarTapObserver {
    final class Coordinator: NSObject, UITabBarControllerDelegate {
        var onTap: (Int) -> Void
        weak var tabBarController: UITabBarController?

        init(onTap: @escaping (Int) -> Void) {
            self.onTap = onTap
        }

        func attach(to tabBarController: UITabBarController) {
            if self.tabBarController !== tabBarController {
                self.tabBarController = tabBarController
            }
            tabBarController.delegate = self
        }

        func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
            guard let viewControllers = tabBarController.viewControllers,
                  let tappedIndex = viewControllers.firstIndex(of: viewController) else {
                return true
            }
            onTap(tappedIndex)
            return true
        }
    }
}
