//
//  PostProductCameraViewModel.swift
//  LetGo
//
//  Created by Eli Kohen on 10/03/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import Foundation
import RxSwift
import Photos

enum CameraState {
    case PendingAskPermissions, MissingPermissions(String), Capture, TakingPhoto, Preview
}

enum CameraFlashMode {
    case Auto, On, Off
}

enum CameraSourceMode {
    case Front, Rear
}

class PostProductCameraViewModel: BaseViewModel {

    weak var cameraDelegate: PostProductCameraViewDelegate?

    let visible = Variable<Bool>(false)

    let cameraState = Variable<CameraState>(.PendingAskPermissions)
    let cameraFlashMode = Variable<CameraFlashMode>(.Auto)
    let cameraSourceMode = Variable<CameraSourceMode>(.Rear)
    let imageSelected = Variable<UIImage?>(nil)
    let sourcePosting = Variable<PostingSource>(.SellButton)

    let infoShown = Variable<Bool>(false)
    let infoTitle = Variable<String>("")
    let infoSubtitle = Variable<String>("")
    let firstTimeTitle = Variable<String>("")
    let firstTimeSubtitle = Variable<String>("")
    let infoButton = Variable<String>("")
    let shouldShowFirstTimeAlert = Variable<Bool>(false)

    private let disposeBag = DisposeBag()
    private let keyValueStorage: KeyValueStorage   //cameraAlreadyShown
    private var firstTimeAlertTimer: NSTimer?
    // MARK: - Lifecycle


    init(keyValueStorage: KeyValueStorage) {
        self.keyValueStorage = keyValueStorage
        super.init()
        setupRX()
    }

    override convenience init() {
        let keyValueStorage = KeyValueStorage.sharedInstance
        self.init(keyValueStorage: keyValueStorage)
    }

    override func didBecomeActive(firstTime: Bool) {
        switch cameraState.value {
        case .PendingAskPermissions, .MissingPermissions:
            checkCameraState()
        case .TakingPhoto, .Preview, .Capture:
            break
        }
    }


    // MARK: - Public methods

    func closeButtonPressed() {
        switch cameraState.value {
        case .TakingPhoto, .Preview:
            retryPhotoButtonPressed()
        case .MissingPermissions, .PendingAskPermissions, .Capture:
            cameraDelegate?.productCameraCloseButton()
        }
    }

    func flashButtonPressed() {
        cameraFlashMode.value = cameraFlashMode.value.next
    }

    func cameraButtonPressed() {
        cameraSourceMode.value = cameraSourceMode.value.toggle
    }

    func takePhotoButtonPressed() {
        cameraState.value = .TakingPhoto
    }

    func photoTaken(photo: UIImage) {
        imageSelected.value = photo
        cameraState.value = .Preview
    }

    func retryPhotoButtonPressed() {
        imageSelected.value = nil
        cameraState.value = .Capture
    }

    func usePhotoButtonPressed() {
        guard let image = imageSelected.value else { return }
        cameraDelegate?.productCameraDidTakeImage(image)
    }

    func infoButtonPressed() {
        switch cameraState.value {
        case .MissingPermissions:
            UIApplication.sharedApplication().openURL(NSURL(string: UIApplicationOpenSettingsURLString)!)
        case .PendingAskPermissions:
            askForPermissions()
        case .TakingPhoto, .Capture, .Preview:
            break
        }
    }

    func hideFirstTimeAlert() {
        firstTimeAlertTimer?.invalidate()
        shouldShowFirstTimeAlert.value = false
    }


    // MARK: - Private methods

    private func setupRX() {
        cameraState.asObservable().subscribeNext{ [weak self] state in
            switch state {
            case .MissingPermissions(let msg):
                self?.infoTitle.value = LGLocalizedString.productPostCameraPermissionsTitle
                self?.infoSubtitle.value = msg
                self?.infoButton.value = LGLocalizedString.productPostCameraPermissionsButton
                self?.infoShown.value = true
            case .PendingAskPermissions:
                self?.infoTitle.value = LGLocalizedString.productPostCameraPermissionsTitle
                self?.infoSubtitle.value = LGLocalizedString.productPostCameraPermissionsSubtitle
                self?.infoButton.value = LGLocalizedString.productPostCameraPermissionsButton
                self?.infoShown.value = true
            case .TakingPhoto, .Capture, .Preview:
                self?.infoShown.value = false
            }
        }.addDisposableTo(disposeBag)
        
        sourcePosting.asObservable().subscribeNext{ [weak self] source in
            switch source {
            case .SellButton, .DeepLink, .OnboardingButton, .OnboardingCamera:
                self?.firstTimeTitle.value = LGLocalizedString.productPostCameraFirstTimeAlertTitle
                self?.firstTimeSubtitle.value = LGLocalizedString.productPostCameraFirstTimeAlertSubtitle
            case .SellFreeButton:
                self?.firstTimeTitle.value = LGLocalizedString.productPostFreeCameraFirstTimeAlertTitle
                self?.firstTimeSubtitle.value = LGLocalizedString.productPostFreeCameraFirstTimeAlertSubtitle
            }
        }.addDisposableTo(disposeBag)
        
        cameraState.asObservable().map{ $0.previewMode }.subscribeNext{ [weak self] previewMode in
            self?.cameraDelegate?.productCameraRequestHideTabs(previewMode)
        }.addDisposableTo(disposeBag)

        cameraState.asObservable().map{ $0.cameraLock }.subscribeNext{ [weak self] cameraLock in
            self?.cameraDelegate?.productCameraRequestsScrollLock(cameraLock)
        }.addDisposableTo(disposeBag)

        visible.asObservable().distinctUntilChanged().filter{ $0 }
            .subscribeNext{ [weak self] _ in self?.didBecomeVisible() }
            .addDisposableTo(disposeBag)

        shouldShowFirstTimeAlert.asObservable().subscribeNext { [weak self] shouldShowAlert in
          if shouldShowAlert {
                self?.showFirstTimeAlert()
            }
        }.addDisposableTo(disposeBag)

    }

    private func checkCameraState() {
        guard UIImagePickerController.isSourceTypeAvailable(.Camera) else {
            cameraState.value = .MissingPermissions(LGLocalizedString.productSellCameraRestrictedError)
            return
        }
        let status = AVCaptureDevice.authorizationStatusForMediaType(AVMediaTypeVideo)
        switch (status) {
        case .Authorized:
            cameraState.value = .Capture
        case .Denied:
            cameraState.value = .MissingPermissions(LGLocalizedString.productPostCameraPermissionsSubtitle)
        case .NotDetermined:
            cameraState.value = .PendingAskPermissions
        case .Restricted:
            // this will never be called, this status is not visible for the user
            // https://developer.apple.com/library/ios/documentation/AVFoundation/Reference/AVCaptureDevice_Class/#//apple_ref/swift/enum/c:@E@AVAuthorizationStatus
            break
        }
    }

    private func askForPermissions() {
        AVCaptureDevice.requestAccessForMediaType(AVMediaTypeVideo) { granted in
            //This is required :(, callback is not on main thread so app would crash otherwise.
            dispatch_async(dispatch_get_main_queue()) { [weak self] in
                self?.cameraState.value = granted ?
                    .Capture : .MissingPermissions(LGLocalizedString.productPostCameraPermissionsSubtitle)
            }
        }
    }

    private func didBecomeVisible() {
        switch cameraState.value {
        case .PendingAskPermissions:
            askForPermissions()
        case .Capture:
            shouldShowFirstTimeAlert.value = !keyValueStorage[.cameraAlreadyShown]
        case .TakingPhoto, .Preview, .MissingPermissions:
            break
        }
    }

    private func showFirstTimeAlert() {
        keyValueStorage[.cameraAlreadyShown] = true
        firstTimeAlertTimer = NSTimer.scheduledTimerWithTimeInterval(5, target: self,
                                                                     selector: #selector(timerHideFirstTimeAlert),
                                                                     userInfo: nil, repeats: false)
    }

    dynamic func timerHideFirstTimeAlert() {
        hideFirstTimeAlert()
    }
}


// MARK: - Camera Enum extensions

extension CameraState {
    var captureMode: Bool {
        switch self {
        case .PendingAskPermissions, .MissingPermissions, .Preview:
            return false
        case .TakingPhoto, .Capture:
            return true
        }
    }

    var previewMode: Bool {
        switch self {
        case .PendingAskPermissions, .MissingPermissions, .Capture, .TakingPhoto:
            return false
        case .Preview:
            return true
        }
    }

    private var cameraLock: Bool {
        switch self {
        case .PendingAskPermissions, .MissingPermissions, .Capture:
            return false
        case .Preview, .TakingPhoto:
            return true
        }
    }
}

private extension CameraFlashMode {
    var next: CameraFlashMode {
        switch self {
        case .Auto:
            return .On
        case .On:
            return .Off
        case .Off:
            return .Auto
        }
    }
}

private extension CameraSourceMode {
    var toggle: CameraSourceMode {
        switch self {
        case .Front:
            return .Rear
        case .Rear:
            return .Front
        }
    }
}
