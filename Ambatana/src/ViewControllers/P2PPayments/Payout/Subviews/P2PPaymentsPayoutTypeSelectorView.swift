import UIKit
import LGComponents
import RxSwift
import RxCocoa

final class P2PPaymentsPayoutTypeSelectorView: UIView {
    enum OptionSelected {
        case bankAccount
        case debitCard
    }

    private let bankAccountOption = OptionView(text: "Bank Account")
    private let debitCardOption = OptionView(text: "Debit Card")
    fileprivate let optionSelectedRelay = BehaviorRelay<OptionSelected>(value: .bankAccount)

    init() {
        super.init(frame: .zero)
        setup()
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    private func setup() {
        addSubviewsForAutoLayout([bankAccountOption, debitCardOption])
        setupConstraints()
        bankAccountOption.isSelected = true
        let bankTap = UITapGestureRecognizer(target: self, action: #selector(bankOptionSelected))
        let debitCardTap = UITapGestureRecognizer(target: self, action: #selector(debitCardOptionSelected))
        bankAccountOption.addGestureRecognizer(bankTap)
        debitCardOption.addGestureRecognizer(debitCardTap)
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            bankAccountOption.leadingAnchor.constraint(equalTo: leadingAnchor),
            bankAccountOption.topAnchor.constraint(equalTo: topAnchor),
            bankAccountOption.bottomAnchor.constraint(equalTo: bottomAnchor),

            debitCardOption.leadingAnchor.constraint(equalTo: bankAccountOption.trailingAnchor),
            debitCardOption.trailingAnchor.constraint(equalTo: trailingAnchor),
            debitCardOption.topAnchor.constraint(equalTo: topAnchor),
            debitCardOption.bottomAnchor.constraint(equalTo: bottomAnchor),

            bankAccountOption.widthAnchor.constraint(equalTo: debitCardOption.widthAnchor)
        ])
    }

    @objc private func bankOptionSelected() {
        bankAccountOption.isSelected = true
        debitCardOption.isSelected = false
    }

    @objc private func debitCardOptionSelected() {
        bankAccountOption.isSelected = false
        debitCardOption.isSelected = true
    }

    override var intrinsicContentSize: CGSize {
        return CGSize(width: UIViewNoIntrinsicMetric, height: 48)
    }
}

extension Reactive where Base: P2PPaymentsPayoutTypeSelectorView {
    var optionSelected: Driver<P2PPaymentsPayoutTypeSelectorView.OptionSelected> {
        return base.optionSelectedRelay.asDriver()
    }
}

private extension P2PPaymentsPayoutTypeSelectorView {
    final class OptionView: UIView {
        var isSelected: Bool = false {
            didSet { configureForCurrentState() }
        }

        private let titleLabel: UILabel = {
            let label = UILabel()
            label.textAlignment = .center
            return label
        }()

        private let lineView: UIView = {
            let view = UIView()
            view.backgroundColor = .primaryColor
            return view
        }()

        init(text: String) {
            super.init(frame: .zero)
            setup(text: text)
        }

        @available(*, unavailable)
        required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }

        private func setup(text: String) {
            titleLabel.text = text
            addSubviewsForAutoLayout([titleLabel, lineView])
            setupConstraints()
            configureForCurrentState()
        }

        private func setupConstraints() {
            NSLayoutConstraint.activate([
                titleLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
                titleLabel.centerYAnchor.constraint(equalTo: centerYAnchor),

                lineView.centerXAnchor.constraint(equalTo: titleLabel.centerXAnchor),
                lineView.widthAnchor.constraint(equalTo: titleLabel.widthAnchor, constant: 24),
                lineView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 2),
                lineView.heightAnchor.constraint(equalToConstant: 3)
            ])
        }

        private func configureForCurrentState() {
            lineView.isHidden = !isSelected
            titleLabel.font = isSelected ? .systemSemiBoldFont(size: 18) : .systemFont(size: 18)
            titleLabel.textColor = isSelected ? .primaryColor : .lgBlack
        }
    }
}
