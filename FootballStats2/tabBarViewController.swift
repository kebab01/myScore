//
//  tabBarViewController.swift
//  FootballStats2
//
//  Created by Thomas Karbowiak on 3/10/20.
//  Copyright © 2020 Thomas Karbowiak. All rights reserved.
//

import UIKit

class tabBarViewController: UITabBarController, UITabBarControllerDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        self.tabBarController?.delegate = self
        self.tabBarItem.isEnabled = false
        
    }/*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
