//
//  PhotoViewerViewControllerBinder.swift
//  LetGo
//
//  Created by Facundo Menzella on 29/11/2017.
//  Copyright © 2017 Ambatana. All rights reserved.
//

import Foundation
import RxSwift

protocol PhotoViewerVCType: class {
    func showChat()
    func closeView()
    func updatePage(fromContentOffset offset: CGFloat)
}

protocol PhotoViewerBinderViewType: class {
    var rx_closeButton: Reactive<UIControl>? { get }
    var rx_chatButton: Reactive<UIControl>? { get }
    var rx_collectionView: Reactive<UICollectionView> { get }
}

final class PhotoViewerViewControllerBinder {

    weak var viewController: PhotoViewerVCType?
    private var disposeBag: DisposeBag?

    func bind(toView: PhotoViewerBinderViewType) {
        disposeBag = DisposeBag()

        guard let bag = disposeBag else { return }
        guard let vc = viewController else { return }

        bindChatButton(toViewController: vc, view: toView, withDisposeBag: bag)
        bindCloseButton(toViewController: vc, view: toView, withDisposeBag: bag)
        bindContentOffset(toViewController: vc, view: toView, withDisposeBag: bag)
    }

    private func bindChatButton(toViewController viewController: PhotoViewerVCType,
                        view: PhotoViewerBinderViewType, withDisposeBag disposeBag: DisposeBag) {
        view.rx_chatButton?.controlEvent(.touchUpInside)
            .debounce(0.3, scheduler: MainScheduler.instance)
            .bindNext { [weak viewController] in
            viewController?.showChat()
        }.addDisposableTo(disposeBag)
    }

    private func bindCloseButton(toViewController viewController: PhotoViewerVCType?,
                        view: PhotoViewerBinderViewType, withDisposeBag disposeBag: DisposeBag) {
        view.rx_closeButton?.controlEvent(.touchUpInside)
            .debounce(0.3, scheduler: MainScheduler.instance)
            .bindNext { [weak viewController] in
            viewController?.closeView()
        }.addDisposableTo(disposeBag)
    }

    private func bindContentOffset(toViewController viewController: PhotoViewerVCType?,
                                   view: PhotoViewerBinderViewType, withDisposeBag disposeBag: DisposeBag) {
        view.rx_collectionView.contentOffset.asObservable().bindNext { [weak viewController] offset in
            viewController?.updatePage(fromContentOffset: offset.x)
        }.addDisposableTo(disposeBag)
    }
}
