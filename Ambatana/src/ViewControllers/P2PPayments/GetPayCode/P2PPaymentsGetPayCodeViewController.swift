import UIKit
import LGComponents
import RxSwift
import RxCocoa

// TODO: @juolgon Localize all texts

final class P2PPaymentsGetPayCodeViewController: BaseViewController {
    private let viewModel: P2PPaymentsGetPayCodeViewModel

    private let warningImageView: UIImageView = {
        let imageView = UIImageView(image: R.Asset.P2PPayments.icTrust.image)
        imageView.tintColor = .p2pPaymentsWarning
        return imageView
    }()

    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.text = "Sharing this code unlocks the payment, only do it after you receive the item. Never share this code via chat or text message."
        label.textAlignment = .center
        label.numberOfLines = 0
        label.setContentHuggingPriority(.defaultHigh, for: .vertical)
        return label
    }()

    private let payCodeBackground: UIView = {
        let view = UIView()
        view.backgroundColor = .veryLightGray
        view.cornerRadius = 16
        return view
    }()

    private let payCodeTitleLabel: UILabel = {
        let label = UILabel()
        label.text =  "Your payment code"
        label.font = .systemBoldFont(size: 28)
        label.textColor = .lgBlack
        return label
    }()

    private let payCodeLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemBoldFont(size: 50)
        label.textColor = UIColor.primaryColor
        return label
    }()

    private let activityIndicator: UIActivityIndicatorView = {
        let view = UIActivityIndicatorView()
        view.hidesWhenStopped = true
        view.startAnimating()
        return view
    }()

    private let disclaimerLabel: UILabel = {
        let label = UILabel()
        label.text = "This code expires in 14 days, so make sure to meet the seller soon"
        label.numberOfLines = 0
        label.setContentHuggingPriority(.defaultHigh, for: .vertical)
        label.textColor = .lgBlack
        label.font = UIFont.systemFont(size: 16)
        return label
    }()

    init(viewModel: P2PPaymentsGetPayCodeViewModel) {
        self.viewModel = viewModel
        super.init(viewModel: viewModel, nibName: nil)
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }

    private func setup() {
        view.backgroundColor = UIColor.white
        view.addSubviewsForAutoLayout([warningImageView,
                                       descriptionLabel,
                                       payCodeBackground,
                                       payCodeTitleLabel,
                                       payCodeLabel,
                                       activityIndicator,
                                       disclaimerLabel])
        setupConstraints()
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            warningImageView.topAnchor.constraint(equalTo: view.safeTopAnchor, constant: 12),
            warningImageView.widthAnchor.constraint(equalToConstant: 34),
            warningImageView.heightAnchor.constraint(equalToConstant: 34),

            descriptionLabel.topAnchor.constraint(equalTo: warningImageView.bottomAnchor, constant: 16),
            descriptionLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            descriptionLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),

            payCodeBackground.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: 24),
            payCodeBackground.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            payCodeBackground.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            payCodeBackground.heightAnchor.constraint(equalToConstant: 220),

            payCodeTitleLabel.centerXAnchor.constraint(equalTo: payCodeBackground.centerXAnchor),
            payCodeTitleLabel.topAnchor.constraint(equalTo: payCodeBackground.topAnchor, constant: 53),

            payCodeLabel.topAnchor.constraint(equalTo: payCodeTitleLabel.bottomAnchor, constant: 20),
            payCodeLabel.centerXAnchor.constraint(equalTo: payCodeBackground.centerXAnchor),

            activityIndicator.centerXAnchor.constraint(equalTo: payCodeLabel.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: payCodeLabel.centerYAnchor),

            disclaimerLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 32),
            disclaimerLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -32),
            disclaimerLabel.bottomAnchor.constraint(equalTo: view.safeBottomAnchor, constant: -32),
        ])
    }
}
