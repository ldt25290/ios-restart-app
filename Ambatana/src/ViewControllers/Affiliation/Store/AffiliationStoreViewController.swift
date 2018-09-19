import LGComponents
import RxSwift
import RxCocoa

final class AffiliationStoreViewController: BaseViewController {
    private let storeView = AffiliationStoreView()
    private let errorView = AffiliationStoreErrorView()

    private let viewModel: AffiliationStoreViewModel
    private let pointsView = AffiliationStorePointsView()

    private let disposeBag = DisposeBag()

    init(viewModel: AffiliationStoreViewModel) {
        self.viewModel = viewModel
        super.init(viewModel: viewModel, nibName: nil)
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) { fatalError("Die xibs, die") }

    override func loadView() {
        super.loadView()
        view.addSubviewForAutoLayout(storeView)
        constraintViewToSafeRootView(storeView)
    }

    override func viewWillAppearFromBackground(_ fromBackground: Bool) {
        super.viewWillAppearFromBackground(fromBackground)
        setupNavigationBar()
    }

    override func viewDidLoad() {
        view.backgroundColor = storeView.backgroundColor
        storeView.collectionView.dataSource = self
        automaticallyAdjustsScrollViewInsets = false
        
        setupRx()
        storeView.setHistory(enabled: true)
    }

    private func setupNavigationBar() {
        setNavBarBackgroundStyle(.transparent(substyle: .light))
        setNavBarTitle(R.Strings.affiliationStoreTitle)
        navigationController?.navigationBar.isTranslucent = true
        navigationController?.navigationBar.backgroundColor = .clear


        let button = UIBarButtonItem(image: R.Asset.Affiliation.icnThreeDots.image,
                                     style: .plain,
                                     target: self,
                                     action: #selector(didTapMoreActions))
        button.tintColor = .grayLight

        let pointsItem = UIBarButtonItem(customView: pointsView)
        navigationItem.rightBarButtonItems = [button, pointsItem]
    }

    private func setupRx() {
        let bindings = [
            viewModel.rx.state.throttle(RxTimeInterval(1)).drive(rx.state),
            storeView.viewHistoryButton.rx.tap.bind { [weak self] in self?.viewModel.openHistory() }
        ]
        bindings.forEach { $0.disposed(by: disposeBag) }
    }

    fileprivate func update(with state: ViewState) {
        switch state {
        case .loading:
            showLoading()
        case .data:
            updateWithData()
        case .error(let errorModel), .empty(let errorModel):
            update(with: errorModel)
        }
    }

    private func showLoading() {
        errorView.removeFromSuperview()
        showLoadingMessageAlert()
        pointsView.alpha = 0
    }

    private func updateWithData() {
        dismissLoadingMessageAlert()
        errorView.removeFromSuperview()

        pointsView.alpha = 1
        pointsView.populate(with: viewModel.points)
        storeView.collectionView.reloadData()
    }

    private func update(with error: LGEmptyViewModel) {
        dismissLoadingMessageAlert()

        let action = UIAction(interface: .button(R.Strings.commonErrorListRetryButton,
                                                 .primary(fontSize: .medium)),
                              action: error.action ?? {} )
        errorView.populate(message: error.title ?? R.Strings.affiliationStoreUnknownErrorMessage,
                           image: error.icon ?? R.Asset.Affiliation.Error.errorOops.image,
                           action: action)
        view.addSubviewForAutoLayout(errorView)
        constraintViewToSafeRootView(errorView)

        pointsView.alpha = 0
    }

    fileprivate func updateRedeem(with state: ViewState) {
        switch state {
        case .loading:
            showLoading()
        case .data:
            pointsView.alpha = 1
            dismissLoadingMessageAlert({ [weak self] in
                self?.showRedeemSuccess()
            })
        case .empty(_), .error(_):
            pointsView.alpha = 1
            viewModel.showFailBubble(withMessage: "Gimme the money bro", duration: TimeInterval(3))
        }
    }

    fileprivate func showRedeemSuccess() {
        let action = UIAction(interface: .button(R.Strings.commonOk, .primary(fontSize: .medium)),
                              action: { [weak self] in
            self?.dismiss(animated: true, completion: nil)
        })
        let data = AffiliationModalData(
            icon: R.Asset.Affiliation.icnModalSuccess.image,
            headline: R.Strings.affiliationStoreRedeemGiftSuccessHeadline,
            subheadline: R.Strings.affiliationStoreRedeemGiftSuccessSubheadlineWithEmail,
            primary: action,
            secondary: nil
        )
        let vm = AffiliationModalViewModel(data: data)
        let vc = AffiliationModalViewController(viewModel: vm)

        vm.active = true
        vc.modalTransitionStyle = .crossDissolve
        vc.modalPresentationStyle = .overCurrentContext
        
        present(vc, animated: true, completion: nil)
    }

      fileprivate func setHistory(enabled: Bool) {
        storeView.setHistory(enabled: enabled)
    }
}

extension AffiliationStoreViewController {
    @objc func didTapMoreActions() {
        showActionSheet(R.Strings.commonCancel, actions: viewModel.moreActions, barButtonItem: nil)
    }
}

extension Reactive where Base: AffiliationStoreViewController {
    var state: Binder<ViewState> {
        return Binder(self.base) { controller, state in
            controller.update(with: state)
        }
    }

    var historyEnabled: Binder<Bool> {
        return Binder(self.base) { controller, enabled in
            controller.setHistory(enabled: enabled)
        }
    }
}

extension AffiliationStoreViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.purchases.count
    }

    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeue(type: AffiliationStoreCell.self, for: indexPath),
            let data = viewModel.purchases[safeAt: indexPath.row] else { return UICollectionViewCell() }
        cell.populate(with: data)
        cell.tag = indexPath.row
        cell.redeemButton.removeTarget(self, action: nil, for: .allEvents)
        cell.redeemButton.addTarget(self, action: #selector(redeem(sender:)), for: .touchUpInside)
        return cell
    }

    @objc private func redeem(sender: UIView) {
        viewModel
            .redeem(at: sender.tag)
            .drive(onNext: { [weak self] (state) in
                self?.updateRedeem(with: state)
            }).disposed(by: disposeBag)
    }
}
