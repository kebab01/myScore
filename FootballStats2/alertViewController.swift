//
//  alertViewController.swift
//  FootballStats2
//
//  Created by Thomas Karbowiak on 25/10/20.
//  Copyright © 2020 Thomas Karbowiak. All rights reserved.
//

import UIKit

class alertViewController: UIViewController {
    
    @IBOutlet weak var txtNotes: UILabel!
    @IBOutlet weak var myView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        myView.layer.cornerRadius = 10
        txtNotes.text = selectedGameNotes
    }
}
