//
//  BaseViewModel.swift
//  LetGo
//
//  Created by Albert Hernández López on 12/05/15.
//  Copyright (c) 2015 Ambatana. All rights reserved.
//


public class BaseViewModel {
    
    public var active: Bool = false {
        didSet {
            if oldValue != active {
                didSetActive(active)
                if active {
                    didBecomeActive()
                } else {
                    didBecomeInactive()
                }
            }
        }
    }
    
    // MARK: - Internal methods
    
    func didSetActive(active: Bool) {
        
    }

    func didBecomeActive() {

    }

    func didBecomeInactive() {

    }
}
