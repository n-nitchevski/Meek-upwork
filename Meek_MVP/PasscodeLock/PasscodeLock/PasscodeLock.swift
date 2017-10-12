//
//  PasscodeLock.swift
//  PasscodeLock
//
//  Created by Yanko Dimitrov on 8/28/15.
//  Copyright © 2015 Yanko Dimitrov. All rights reserved.
//

import Foundation
import LocalAuthentication

open class PasscodeLock: PasscodeLockType {
    
    public var thePass: [String]

    open weak var delegate: PasscodeLockTypeDelegate?
    open let configuration: PasscodeLockConfigurationType
    
    open var repository: PasscodeRepositoryType {
        return configuration.repository
    }
    
    open var state: PasscodeLockStateType {
        return lockState
    }
    
    fileprivate var lockState: PasscodeLockStateType
    fileprivate lazy var passcode = [String]()
    
    public init(state: PasscodeLockStateType, configuration: PasscodeLockConfigurationType) {
        
        precondition(configuration.passcodeLength > 0, "Passcode length sould be greather than zero.")
        
        self.lockState = state
        self.configuration = configuration
        self.thePass = [""]
    }
    
    open func addSign(_ sign: String) {
        passcode.append(sign)
        thePass = passcode
        //print(sign)
        
        if passcode.count >= 4 {
            print("printing passcode \(passcode)")
            delegate?.passcodeLock(self, addedSignAtIndex: passcode.count - 1)
            lockState.acceptPasscode(passcode, fromLock: self)
            passcode.removeAll(keepingCapacity: true)
        }

        delegate?.passcodeLock(self, addedSignAtIndex: passcode.count - 1)
    }
    
    open func removeSign() {
        
        guard passcode.count > 0 else { return }
        
        passcode.removeLast()
        delegate?.passcodeLock(self, removedSignAtIndex: passcode.count)
    }
    
    open func changeStateTo(_ state: PasscodeLockStateType) {
    
        lockState = state
        delegate?.passcodeLockDidChangeState(self)
    }
    
}
