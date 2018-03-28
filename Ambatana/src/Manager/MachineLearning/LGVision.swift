//
//  LGVision.swift
//  LetGo
//
//  Created by Nestor on 06/03/2018.
//  Copyright © 2018 Ambatana. All rights reserved.
//

import CameraManager
import Vision
import CoreMedia
import LGCoreKit
import Result
import RxSwift

struct MachineLearningVisionObservation {
    let identifier: String
    let confidence: Double
}

typealias MachineLearningVisionCompletion = ([MachineLearningVisionObservation]?) -> Void

protocol MachineLearningVision {
    func predict(pixelBuffer: CVPixelBuffer, completion: MachineLearningVisionCompletion?)
}

@available(iOS 11.0, *)
final class LGVision: MachineLearningVision {
    var numberOfObservationsToReturn: Int = 3
    
    static let shared = LGVision()
    
    private var request: VNCoreMLRequest?
    private var requestCompletion: MachineLearningVisionCompletion?
    
    private let model = MobileNetLetgov7final()
    
    // MARK: - Lifecycle
    
    private init() {
        guard let visionModel = try? VNCoreMLModel(for: model.model) else {
            logMessage(.error, type: .parsing, message: "Could not create Vision model")
            return
        }
        request = VNCoreMLRequest(model: visionModel, completionHandler: requestDidComplete)
        request?.imageCropAndScaleOption = .centerCrop
    }
    
    // MARK: - Vision prediction
    
    func predict(pixelBuffer: CVPixelBuffer, completion: MachineLearningVisionCompletion?) {
        guard let request = request else { return }
        requestCompletion = completion
        let requestHandler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer)
        do {
            try requestHandler.perform([request])
        } catch {
            requestCompletion?(nil)
        }
    }
    
    func requestDidComplete(request: VNRequest, error: Error?) {
        if let observations = request.results as? [VNClassificationObservation] {
            // The observations appear to be sorted by confidence already, so we
            // take the top X and map them to an array of (String, Double) tuples.
            let topObservations = observations.prefix(through: numberOfObservationsToReturn-1)
                .map { MachineLearningVisionObservation(identifier: $0.identifier, confidence: Double($0.confidence)) }
            requestCompletion?(topObservations)
        } else {
            requestCompletion?(nil)
        }
    }
}