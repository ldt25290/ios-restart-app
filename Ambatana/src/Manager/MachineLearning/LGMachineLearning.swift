import Foundation
import RxSwift
import CameraManager
import LGCoreKit
import CoreMedia
import LGComponents

typealias MachineLearningStatsPredictionCompletion = ([MachineLearningStats]?) -> Void

/**
 MachineLearning can predict stats in two ways:
 - Live: by capturing via delegate VideoCaptureDelegate. Results are publish into `liveStats`
 - One time: by calling predict(pixelBuffer:completion:). Result is provided in the completion
 */
protocol MachineLearning: VideoOutputDelegate, VideoCaptureDelegate {
    var isLiveStatsEnabled: Bool { get set }
    var liveStats: Variable<[MachineLearningStats]?> { get }
    var pixelsBuffersToForwardPerSecond: Int { get }
    func predict(pixelBuffer: CVPixelBuffer, completion: MachineLearningStatsPredictionCompletion?)
}

final class LGMachineLearning: MachineLearning {
    private let machineLearningRepository: MachineLearningRepository
    private var stats: [MachineLearningStats] {
        return machineLearningRepository.stats
    }
    private var machineLearningVision: MachineLearningVision?
    private let operationQueue: OperationQueue = {
        let queue = OperationQueue()
        queue.maxConcurrentOperationCount = 1
        return queue
    }()

    private var canPredict: Bool {
        if #available(iOS 11, *) {
            return machineLearningVision != nil
        }
        return false
    }

    var isLiveStatsEnabled: Bool = true
    let pixelsBuffersToForwardPerSecond: Int = 15
    let liveStats = Variable<[MachineLearningStats]?>(nil)

    convenience init() {
        self.init(machineLearningRepository: Core.machineLearningRepository)
    }

    init(machineLearningRepository: MachineLearningRepository) {
        self.machineLearningRepository = machineLearningRepository
        if #available(iOS 11, *) {
            machineLearningVision = LGVision.shared
        } else {
            machineLearningVision = nil
        }
        machineLearningRepository.fetchStats(jsonFileName: "MobileNetLetgov7final", completion: nil)
    }

    func predict(pixelBuffer: CVPixelBuffer, completion: MachineLearningStatsPredictionCompletion?) {
        guard canPredict else {
            completion?(nil)
            return
        }

        operationQueue.addOperation { [weak self] in
            let group = DispatchGroup()
            group.enter()
            self?.machineLearningVision?.predict(pixelBuffer: pixelBuffer) { [weak self] observations in
                group.leave()
                guard let observationsValue = observations else {
                    completion?(nil)
                    return
                }
                let statsResult: [MachineLearningStats] =
                    observationsValue.flatMap { [weak self] observation -> MachineLearningStats? in
                        return self?.machineLearningRepository.stats(forKeyword: observation.identifier,
                                                                     confidence: observation.confidence)
                }
                completion?(statsResult)
            }
            group.wait()
        }
    }

    // MARK: - VideoOutputDelegate & VideoCaptureDelegate

    func didCaptureVideoFrame(pixelBuffer: CVPixelBuffer?, timestamp: CMTime) {
        guard canPredict, isLiveStatsEnabled, let pixelBuffer = pixelBuffer else { return }
        // Drop the frame if already are processing frames
        guard operationQueue.operationCount < operationQueue.maxConcurrentOperationCount else { return }
        predict(pixelBuffer: pixelBuffer, completion: { stats in
            DispatchQueue.main.async {
                self.liveStats.value = stats
            }
        })
    }
}
