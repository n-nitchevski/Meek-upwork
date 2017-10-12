//
//  ResponsesCell.swift
//  Meek_MVP
//
//  Created by Sara Du  on 7/26/17.
//  Copyright © 2017 Duvelop. All rights reserved.
//

import Foundation
import UIKit
import GTProgressBar
class ResponsesCell: UITableViewCell{
    
    @IBOutlet weak var contentLabel: UILabel!
    @IBOutlet weak var decisionImage: UIImageView!
   
    @IBOutlet weak var progressBar1: GTProgressBar!
    @IBOutlet weak var progressBar2: GTProgressBar!
    @IBOutlet weak var progressBar3: GTProgressBar!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
    }
    
    
}
