//
//  detailedStatsTableViewCell.swift
//  FootballStats2
//
//  Created by Thomas Karbowiak on 9/10/20.
//  Copyright © 2020 Thomas Karbowiak. All rights reserved.
//

import UIKit

class detailedStatsTableViewCell: UITableViewCell {

    @IBOutlet weak var lblStat: UILabel!
    @IBOutlet weak var lblTotal: UILabel!
    @IBOutlet weak var lblFirstPercent: UILabel!
    @IBOutlet weak var lblSecondPercent: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
