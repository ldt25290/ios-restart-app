import Foundation
import LGCoreKit
import LGComponents

final class P2PPaymentsOnboardingViewModel: BaseViewModel {
    var navigator: P2PPaymentsNavigator?

    // MARK: - Public methods

    func closeButtonPressed() {
        navigator?.closeOnboarding()
    }

    func makeAnOfferButtonPressed() {
        // TODO: Link with make an offer screen (@juolgon)
    }
}
