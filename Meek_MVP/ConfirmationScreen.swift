//
//  ConfirmationScreen.swift
//  Meek_MVP
//
//  Created by Sara Du  on 7/29/17.
//  Copyright © 2017 Duvelop. All rights reserved.
//

import Foundation
import UIKit

extension UIView {
    
    
    func fadeIn(duration: TimeInterval = 0.75, delay: TimeInterval = 0.0, completion: @escaping ((Bool) -> Void) = {(finished: Bool) -> Void in}) {
        UIView.animate(withDuration: duration, delay: delay, options: UIViewAnimationOptions.curveEaseIn, animations: {
            self.alpha = 1.0
        }, completion: completion)  }
    
    func fadeOut(duration: TimeInterval = 0.75, delay: TimeInterval = 3.0, completion: @escaping (Bool) -> Void = {(finished: Bool) -> Void in}) {
        UIView.animate(withDuration: duration, delay: delay, options: UIViewAnimationOptions.curveEaseIn, animations: {
            self.alpha = 0.0
        }, completion: completion)
    }
    
}
class ConfirmationScreen: UIView{
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
}
