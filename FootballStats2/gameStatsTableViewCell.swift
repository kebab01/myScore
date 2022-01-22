//
//  gameStatsTableViewCell.swift
//  FootballStats2
//
//  Created by Thomas Karbowiak on 1/10/20.
//  Copyright © 2020 Thomas Karbowiak. All rights reserved.
//

import UIKit

class gameStatsTableViewCell: UITableViewCell {

    @IBOutlet weak var lblHomeCount: UILabel!
    @IBOutlet weak var lblAwayCount: UILabel!
    
    @IBOutlet weak var lblStat: UILabel!
    @IBOutlet weak var statImage: UIImageView!
    
    @IBOutlet weak var progressBar: UIProgressView!
    @IBOutlet weak var homeStepper: UIStepper!
    @IBOutlet weak var awayStepper: UIStepper!
    
    var prgProgress = Progress(totalUnitCount: 0)
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
