//
//  BaseRealEstateViewController.swift
//  LetGo
//
//  Created by Juan Iglesias on 04/10/2017.
//  Copyright © 2017 Ambatana. All rights reserved.
//

import Foundation
import LGCoreKit
import RxSwift

class BasePostingDetailsViewController : BaseViewController, TaxonomiesViewModelDelegate {
    
    private let titleLabel: UILabel = UILabel()
    private let contentView: UIView = UIView()
    private let buttonNext: UIButton = UIButton()
    
    private let viewModel: BasePostingDetailsViewModel
    
    let disposeBag = DisposeBag()
    
    
    // MARK: - LifeCycle
    
    init(viewModel: BasePostingDetailsViewModel) {
        self.viewModel = viewModel
        super.init(viewModel: viewModel, nibName: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.delegate = self
        navigationController?.setNavigationBarHidden(false, animated: false)

        setupConstraints()
        setupUI()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setStatusBarHidden(true)
        setupNavigationBar()
    }
    
    
    // MARK: - UI
    
    private func setupUI() {
        view.clipsToBounds = true
        
        titleLabel.text = viewModel.title
        buttonNext.setTitle("Next", for: .normal)
        
        view.backgroundColor = UIColor.clear
        contentView.backgroundColor = UIColor.clear
        
        titleLabel.font = UIFont.headline
        titleLabel.textColor = UIColor.white
        
        buttonNext.setStyle(.postingFlow)
        buttonNext.addTarget(self, action: #selector(nextButtonPressed), for: .touchUpInside)
    }
    
    private func setupNavigationBar() {
        setNavBarBackgroundStyle(.transparent(substyle: .dark))
        let closeButton = UIBarButtonItem(image: UIImage(named: "ic_post_close") , style: UIBarButtonItemStyle.plain,
                                          target: self, action: #selector(BasePostingDetailsViewController.closeButtonPressed))
        self.navigationItem.leftBarButtonItem = closeButton
    }
    
    private func setupConstraints() {
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.translatesAutoresizingMaskIntoConstraints = false
        buttonNext.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(titleLabel)
        titleLabel.layout(with: view).fillHorizontal(by: Metrics.bigMargin)
        titleLabel.layout(with: view).top(by: 60)
        
        view.addSubview(contentView)
        contentView.layout(with: titleLabel).below(by: Metrics.bigMargin)
        contentView.layout(with: view).fillHorizontal(by: Metrics.bigMargin)
        
        
        let tableView = viewModel.makeContentView
        tableView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(tableView)
        
        tableView.layout(with: contentView).fill()
        
        view.addSubview(buttonNext)
        buttonNext.layout(with: contentView).below(by: Metrics.bigMargin)
        buttonNext.layout().height(44)
        buttonNext.layout().width(100, relatedBy: .greaterThanOrEqual)
        buttonNext.layout(with: view).right(by: -Metrics.bigMargin).bottom(by: -Metrics.bigMargin)
    }
    
    
    // MARK: - UIActions
    
    func closeButtonPressed() {
        viewModel.closeButtonPressed()
    }
    
    func nextButtonPressed() {
        viewModel.nextbuttonPressed()
    }
}

extension BasePostingDetailsViewController: UINavigationControllerDelegate {
    
    func navigationController(_ navigationController: UINavigationController, animationControllerFor operation: UINavigationControllerOperation, from fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return CustomAnimator()
    }
}

class CustomAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.5
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard let fromViewController = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.from)
            else { return }
        guard let toViewController = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to)
            else { return }
        let containerView = transitionContext.containerView
        
        containerView.addSubview(toViewController.view)
        containerView.addSubview(fromViewController.view)
        
        let finalFrame = transitionContext.finalFrame(for: toViewController)
        
        fromViewController.view.alpha = 1.0
        toViewController.view.alpha = 0.0
        toViewController.view.frame = CGRect(x: finalFrame.width*2, y: 0, width: finalFrame.width, height: finalFrame.height)
        
        UIView.animate(withDuration: 0.5, animations: {
            fromViewController.view.alpha = 0.0
            toViewController.view.alpha = 1.0
            fromViewController.view.frame = CGRect(x: -fromViewController.view.frame.width, y: 0, width: fromViewController.view.frame.width, height: fromViewController.view.frame.height)
            toViewController.view.frame = finalFrame
        }, completion: { finished in
            let cancelled = transitionContext.transitionWasCancelled
            fromViewController.view.alpha = 1.0
            transitionContext.completeTransition(!cancelled)
        })
    }
}
