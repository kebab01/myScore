//
//  SavedGamesTableViewCell.swift
//  FootballStats2
//
//  Created by Thomas Karbowiak on 7/9/20.
//  Copyright © 2020 Thomas Karbowiak. All rights reserved.
//

import UIKit

class SavedGamesTableViewCell: UITableViewCell {

    @IBOutlet weak var lblHomeTeam: UILabel!
    @IBOutlet weak var lblAwayTeam: UILabel!
    @IBOutlet weak var lblHomeScore: UILabel!
    @IBOutlet weak var lblAwayScore: UILabel!
    @IBOutlet weak var lblDate: UILabel!
    @IBOutlet weak var lblTime: UILabel!
    
    @IBOutlet weak var lblV: UILabel!
    @IBOutlet weak var lblDash: UILabel!
    
    @IBOutlet weak var lblPremium: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
}
