//
//  settingsViewController.swift
//  FootballStats2
//
//  Created by Thomas Karbowiak on 15/9/20.
//  Copyright © 2020 Thomas Karbowiak. All rights reserved.
//

import UIKit
import StoreKit
class settingsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var timerTypeSeg: UISegmentedControl!
    @IBOutlet weak var tableView: UITableView!
    
    let generator = UISelectionFeedbackGenerator()
    
    var positionDefualts = myDefaults.object(forKey: "statPositions") as? [String]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if stopwatchSelected == false{
            timerTypeSeg.selectedSegmentIndex = 0
            
        }else{
            timerTypeSeg.selectedSegmentIndex = 1
        }
        
        if premiumPurchase == false{
            timerTypeSeg.isUserInteractionEnabled = false
            
            let titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.systemGray2]
            timerTypeSeg.setTitleTextAttributes(titleTextAttributes, for: .normal)
        }else{
            timerTypeSeg.isUserInteractionEnabled = true
            
            var titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
            timerTypeSeg.setTitleTextAttributes(titleTextAttributes, for:.normal)
            titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.black]
            timerTypeSeg.setTitleTextAttributes(titleTextAttributes, for: .selected)
        }
        
        //table view cell
        let nib = UINib(nibName: "recordedStatsTableViewCell", bundle: nil)
        
        tableView.register(nib, forCellReuseIdentifier: "recordedStatsTableViewCell")
        
        tableView.delegate = self
        tableView.dataSource = self
        self.tableView.isEditing = true
        
        generator.prepare()
        
        if positionDefualts != nil {
            for i in 0...(positionDefualts!.count - 1) {
                
                stats[i] = positionDefualts![i]
            }
        }
    }
    
    @IBAction func didChangeSeg(_ sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 0{
            myDefaults.set(false, forKey: "stopwatchSelected")
            stopwatchSelected = false
        }else if sender.selectedSegmentIndex == 1{
            myDefaults.set(true, forKey:  "stopwatchSelected")
            stopwatchSelected = true
        }else{
            myDefaults.set(false, forKey: "stopwatchSelected")
            stopwatchSelected = false
        }
        generator.selectionChanged()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return stats.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "recordedStatsTableViewCell", for: indexPath) as! recordedStatsTableViewCell
        
        
        let item = stats[indexPath.row]
        var switchState:Bool!
        
        if isNotFirstLaunch == true{
            switchState = myDefaults.bool(forKey: item + "State")
        }else{
            switchState = true
            myDefaults.set(true, forKey: item + "State")
            myDefaults.set(true, forKey: "isNotFirstLaunch")
        }
        
        cell.lblStatName.text = stats[indexPath.row]
        
        cell.statSwitch.isOn = switchState
        cell.statSwitch.tag = indexPath.row
        cell.statSwitch.addTarget(self, action: #selector(self.changeState(_ :)), for: .valueChanged)
        return cell
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .none
    }

    func tableView(_ tableView: UITableView, shouldIndentWhileEditingRowAt indexPath: IndexPath) -> Bool {
        return false
    }
    
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let objectToMove = stats[sourceIndexPath.row]
        
        stats.remove(at: sourceIndexPath.row)
        stats.insert(objectToMove, at: destinationIndexPath.row)
        myDefaults.set(stats, forKey: "statPositions")
    }
    
    @objc func changeState(_ sender: UISwitch){
        
        myDefaults.set(sender.isOn, forKey: stats[sender.tag] + "State")
        print(sender.tag, sender.isOn)
    }
}
