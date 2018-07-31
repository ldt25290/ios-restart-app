import Foundation

final class BumpUpsModalRouter: BumpUpNavigator {
    private weak var root: UIViewController?

    init(root: UIViewController) {
        self.root = root
    }

    func bumpUpDidCancel() {
        root?.dismiss(animated: true, completion: nil)
    }
    func bumpUpDidFinish(completion: (() -> Void)?) {
        root?.dismiss(animated: true, completion: nil)
    }
}

final class BumpUpsNavigationRouter: BumpUpNavigator {
    private weak var navigationController: UIViewController?

    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    func bumpUpDidCancel() {
        navigationController?.popViewController(animated: true)
    }
    func bumpUpDidFinish(completion: (() -> Void)?) {
        navigationController?.popViewController(animated: true)
    }
}
