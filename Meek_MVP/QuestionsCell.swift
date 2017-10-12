//
//  QuestionsCell.swift
//  Meek_MVP
//
//  Created by Sara Du  on 7/26/17.
//  Copyright © 2017 Duvelop. All rights reserved.
//

import Foundation
import UIKit
class QuestionsCell: UITableViewCell{
    
    @IBOutlet weak var background: UIImageView!
    
    @IBOutlet weak var contentLabel: UILabel!
    
    @IBOutlet weak var votesCountLabel: UILabel!
    
    @IBOutlet weak var timeLeftLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
}
