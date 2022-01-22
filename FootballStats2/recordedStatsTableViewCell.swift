//
//  recordedStatsTableViewCell.swift
//  FootballStats2
//
//  Created by Thomas Karbowiak on 1/10/20.
//  Copyright © 2020 Thomas Karbowiak. All rights reserved.
//

import UIKit

class recordedStatsTableViewCell: UITableViewCell {

    @IBOutlet weak var lblStatName: UILabel!
    @IBOutlet weak var statSwitch: UISwitch!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
