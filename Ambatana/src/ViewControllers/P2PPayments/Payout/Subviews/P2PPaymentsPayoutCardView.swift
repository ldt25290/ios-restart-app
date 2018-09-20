import UIKit
import LGComponents
import RxSwift
import RxCocoa
import Stripe

// TODO: @juolgon Localize all texts

final class P2PPaymentsPayoutCardView: UIView {
    var cardPayoutParams: P2PPaymentsPayoutViewModel.CardPayoutParams {
        return P2PPaymentsPayoutViewModel.CardPayoutParams(name: nameTextField.text ?? "",
                                                           cardNumber: cardTextField.cardNumber ?? "",
                                                           cardExpirationMonth: Int(cardTextField.expirationMonth),
                                                           cardExpirationYear: Int(cardTextField.expirationYear),
                                                           cvc: cardTextField.cvc ?? "",
                                                           isInstant: instantPaymentSelector.isSelected)
    }

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(size: 14)
        label.textColor = .lgBlack
        label.text = "Input your debit card so that we can pay out to your account"
        label.numberOfLines = 0
        label.setContentHuggingPriority(.defaultHigh, for: .vertical)
        return label
    }()

    private let nameTextField: P2PPaymentsTextField = {
        let textField = P2PPaymentsTextField()
        textField.setPlaceholderText("Name on card")
        textField.returnKeyType = .next
        return textField
    }()

    private let cardTextField = P2PPaymentsCardTextField()

    private let paymentTypeTitleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(size: 14)
        label.textColor = .lgBlack
        label.text = "Choose one of these options:"
        label.numberOfLines = 0
        label.setContentHuggingPriority(.defaultHigh, for: .vertical)
        return label
    }()

    fileprivate let standardPaymentSelector: P2PPaymentsPayoutPaymentSelectorView = {
        let selector = P2PPaymentsPayoutPaymentSelectorView()
        selector.state = P2PPaymentsPayoutPaymentSelectorState(kind: .standard,
                                                               feeText: nil,
                                                               fundsAvailableText: nil)
        selector.isSelected = true
        return selector
    }()

    fileprivate let instantPaymentSelector: P2PPaymentsPayoutPaymentSelectorView = {
        let selector = P2PPaymentsPayoutPaymentSelectorView()
        selector.state = P2PPaymentsPayoutPaymentSelectorState(kind: .instant,
                                                               feeText: nil,
                                                               fundsAvailableText: nil)
        return selector
    }()

    fileprivate let actionButton: UIButton = {
        let button = LetgoButton(withStyle: .primary(fontSize: .big))
        button.setTitle("Payout", for: .normal)
        return button
    }()

    private let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.alignment = .fill
        stackView.distribution = .equalSpacing
        stackView.spacing = 12
        return stackView
    }()

    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.showsVerticalScrollIndicator = false
        scrollView.alwaysBounceVertical = true
        scrollView.keyboardDismissMode = .interactive
        return scrollView
    }()

    private var bottomContraint: NSLayoutConstraint?
    private let disposeBag = DisposeBag()

    init() {
        super.init(frame: .zero)
        setup()
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    private func setup() {
        configureTextFields()
        configureStackView()
        configureScrollView()
        configurePaymentSelectors()
        addSubviewsForAutoLayout([scrollView, actionButton])
        setupConstraints()
        setupRx()
    }

    private func configureStackView() {
        stackView.addArrangedSubviews([
            nameTextField,
            cardTextField,
        ])
    }

    private func configureTextFields() {
        nameTextField.nextResponderTextField = cardTextField
        [nameTextField, cardTextField].forEach { textfield in
            textfield.addTarget(self,
                                action: #selector(textFieldDidBeginEditing(textField:)),
                                for: UIControlEvents.editingDidBegin)
        }
    }

    private func configureScrollView() {
        scrollView.contentInset.bottom = 55 + 12
        scrollView.addSubviewsForAutoLayout([titleLabel,
                                             stackView,
                                             paymentTypeTitleLabel,
                                             standardPaymentSelector,
                                             instantPaymentSelector])
    }

    private func configurePaymentSelectors() {
        let standardTap = UITapGestureRecognizer(target: self, action: #selector(standardPaymentSelected))
        let instantTap = UITapGestureRecognizer(target: self, action: #selector(instantPaymentSelected))
        standardPaymentSelector.addGestureRecognizer(standardTap)
        instantPaymentSelector.addGestureRecognizer(instantTap)
    }

    private func setupConstraints() {
        bottomContraint = scrollView.bottomAnchor.constraint(equalTo: safeBottomAnchor)
        bottomContraint?.isActive = true
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: safeTopAnchor, constant: 12),
            scrollView.leadingAnchor.constraint(equalTo: leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: trailingAnchor),

            titleLabel.topAnchor.constraint(equalTo: scrollView.topAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: stackView.leadingAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: stackView.trailingAnchor),

            stackView.widthAnchor.constraint(equalTo: widthAnchor, constant: -24),
            stackView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            stackView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 12),
            stackView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -12),

            paymentTypeTitleLabel.topAnchor.constraint(equalTo: stackView.bottomAnchor, constant: 32),
            paymentTypeTitleLabel.leadingAnchor.constraint(equalTo: stackView.leadingAnchor),
            paymentTypeTitleLabel.trailingAnchor.constraint(equalTo: stackView.trailingAnchor),

            standardPaymentSelector.topAnchor.constraint(equalTo: paymentTypeTitleLabel.bottomAnchor, constant: 12),
            standardPaymentSelector.leadingAnchor.constraint(equalTo: stackView.leadingAnchor),
            standardPaymentSelector.trailingAnchor.constraint(equalTo: stackView.trailingAnchor),

            instantPaymentSelector.topAnchor.constraint(equalTo: standardPaymentSelector.bottomAnchor, constant: 24),
            instantPaymentSelector.leadingAnchor.constraint(equalTo: stackView.leadingAnchor),
            instantPaymentSelector.trailingAnchor.constraint(equalTo: stackView.trailingAnchor),
            instantPaymentSelector.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),

            actionButton.heightAnchor.constraint(equalToConstant: 55),
            actionButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 24),
            actionButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -24),
            actionButton.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: -12),
        ])
    }

    private func setupRx() {
        Driver
            .combineLatest([
                nameTextField.rx.isEmpty,
                cardTextField.rx.isValid.map { !$0 },
            ])
            .map { !$0.contains(true) }
            .drive(actionButton.rx.isEnabled).disposed(by: disposeBag)
    }

    @objc private func textFieldDidBeginEditing(textField: UITextField) {
        let adjustedFrame = textField.frame.insetBy(dx: 0, dy: -50)
        scrollView.scrollRectToVisible(adjustedFrame, animated: true)
    }

    @objc private func standardPaymentSelected() {
        standardPaymentSelector.isSelected = true
        instantPaymentSelector.isSelected = false
    }

    @objc private func instantPaymentSelected() {
        standardPaymentSelector.isSelected = false
        instantPaymentSelector.isSelected = true
    }
}

// MARK: - Rx

extension Reactive where Base: P2PPaymentsPayoutCardView {
    var payoutButtonTap: ControlEvent<Void> {
        return base.actionButton.rx.tap
    }

    var instantPaymentFeeText: Binder<String?> {
        return base.instantPaymentSelector.rx.feeText
    }

    var instantFundsAvailableText: Binder<String?> {
        return base.instantPaymentSelector.rx.fundsAvailableText
    }

    var standardFundsAvailableText: Binder<String?> {
        return base.standardPaymentSelector.rx.fundsAvailableText
    }
}
