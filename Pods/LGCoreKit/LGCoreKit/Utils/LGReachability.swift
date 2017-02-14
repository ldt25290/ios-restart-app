//
//  LGReachability.swift
//  LGCoreKit
//
//  Created by Nestor on 03/02/2017.
//  Copyright © 2017 Ambatana Inc. All rights reserved.
//

import Foundation
import ReachabilitySwift

protocol LGReachabilityProtocol: class {
    var reachableBlock: (() -> Void)? { get set }
    var unreachableBlock: (() -> Void)? { get set }
    var isReachable: Bool? { get }
    func start()
    func stop()
}

class LGReachability: LGReachabilityProtocol {
    
    private let reachability: Reachability?
    
    var reachableBlock: (() -> Void)? {
        didSet {
            if let block = reachableBlock {
                reachability?.whenReachable = { _ in
                    block()
                }
            } else {
                reachability?.whenReachable = nil
            }
        }
    }
    
    var unreachableBlock: (() -> Void)? {
        didSet {
            if let block = reachableBlock {
                reachability?.whenUnreachable = { _ in
                    block()
                }
            } else {
                reachability?.whenUnreachable = nil
            }
        }
    }
    
    var isReachable: Bool? {
        get {
            return reachability?.isReachable
        }
    }
    
    
    // MARK: - Lifecycle
    
    init() {
        reachability = Reachability()
    }
    
    func start() {
        do {
            try reachability?.startNotifier()
        } catch {
            logMessage(.error, type: .networking, message: "Could not start Reachability")
        }
    }
    
    func stop() {
        reachableBlock = nil
        unreachableBlock = nil
        reachability?.stopNotifier()
    }
    
    deinit {
        stop()
    }
}
