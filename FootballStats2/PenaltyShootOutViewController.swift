//
//  PenaltyShootOutViewController.swift
//  FootballStats2
//
//  Created by Thomas Karbowiak on 14/9/20.
//  Copyright © 2020 Thomas Karbowiak. All rights reserved.
//

import UIKit

class PenaltyShootOutViewController: UIViewController {

    @IBOutlet weak var btnAddHome: UIButton!
    @IBOutlet weak var btnMissHome: UIButton!
    @IBOutlet weak var btnAddAway: UIButton!
    @IBOutlet weak var btnMissAway: UIButton!
    
    @IBOutlet weak var btnHome1: UIButton!
    @IBOutlet weak var btnHome2: UIButton!
    @IBOutlet weak var btnHome3: UIButton!
    @IBOutlet weak var btnHome4: UIButton!
    @IBOutlet weak var btnHome5: UIButton!
    
    @IBOutlet weak var btnAway1: UIButton!
    @IBOutlet weak var btnAway2: UIButton!
    @IBOutlet weak var btnAway3: UIButton!
    @IBOutlet weak var btnAway4: UIButton!
    @IBOutlet weak var btnAway5: UIButton!
    
    @IBOutlet weak var lblHomeGoals: UILabel!
    @IBOutlet weak var lblAwayGoals: UILabel!
    @IBOutlet weak var lblHome: UILabel!
    @IBOutlet weak var lblAway: UILabel!
    
    @IBOutlet weak var btnEndGame: UIButton!
    
    var homeShots = 0
    var awayShots = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        (homeTeamStats.penalties == nil) ? (homeTeamStats.penalties = 0) : ()
        (awayTeamStats.penalties == nil) ? (awayTeamStats.penalties = 0) : ()
        
        format()
        lblHome.text = homeTeamStats.name
        lblAway.text = awayTeamStats.name
        lblHomeGoals.text = String(homeTeamStats.goals ?? 0)
        lblAwayGoals.text = String(awayTeamStats.goals ?? 0)
        self.isModalInPresentation = true
    }
    
    func format(){
        btnEndGame.layer.cornerRadius = 20
        
        btnAddHome.layer.cornerRadius = 20
        btnMissHome.layer.cornerRadius = 20
        btnAddAway.layer.cornerRadius = 20
        btnMissAway.layer.cornerRadius = 20
        
        btnHome1.layer.cornerRadius = 10
        btnHome2.layer.cornerRadius = 10
        btnHome3.layer.cornerRadius = 10
        btnHome4.layer.cornerRadius = 10
        btnHome5.layer.cornerRadius = 10
        
        btnAway1.layer.cornerRadius = 10
        btnAway2.layer.cornerRadius = 10
        btnAway3.layer.cornerRadius = 10
        btnAway4.layer.cornerRadius = 10
        btnAway5.layer.cornerRadius = 10
        
    }
    @IBAction func btnAddGoal(_ sender: Any) {
        homeTeamStats.penalties! += 1
        if homeShots < 5{
            homeShots += 1
            checkGoal(team: "home", value: homeShots, colour: .systemGreen)
        }else{
            for i in 1...5{
                checkGoal(team: "home", value: i, colour: .systemGray4)
            }
            homeShots = 1
            checkGoal(team: "home", value: homeShots, colour: .systemGreen)
        }
    }
    @IBAction func btnMissGoal(_ sender: Any) {
        if homeShots < 5{
            homeShots += 1
            checkGoal(team: "home", value: homeShots, colour: .red)
        }else{
            for i in 1...5{
                checkGoal(team: "home", value: i, colour: .systemGray4)
            }
            homeShots = 1
            checkGoal(team: "home", value: homeShots, colour: .red)
        }
    }
    @IBAction func btnAddGoalAway(_ sender: Any) {
        awayTeamStats.penalties! += 1
        if awayShots < 5{
            awayShots += 1
            checkGoal(team: "away", value: awayShots, colour: .systemGreen)
        }else{
            for i in 1...5{
                checkGoal(team: "away", value: i, colour: .systemGray4)
            }
            awayShots = 1
            checkGoal(team: "away", value: awayShots, colour: .systemGreen)
        }
    }
    @IBAction func btnMissGoalAway(_ sender: Any) {
        if awayShots < 5{
            awayShots += 1
            checkGoal(team: "away", value: awayShots, colour: .red)
        }else{
            for i in 1...5{
                checkGoal(team: "away", value: i, colour: .systemGray4)
            }
            awayShots = 1
            checkGoal(team: "away", value: awayShots, colour: .red)
        }
    }
    
    @IBAction func btnEndGame(_ sender: Any) {
        let alert = UIAlertController(title: "End Game?", message: "Are you sure you would like to end the game", preferredStyle: .alert)
            
            let endGameButton = UIAlertAction(title: "End Game", style: .default) { (action) in
                self.performSegue(withIdentifier: "penEnded", sender: self)
            }
            let cancelButton = UIAlertAction(title: "Cancel", style: .default) { (action) in
                self.dismiss(animated: true, completion: nil)
            }
            
            alert.addAction(endGameButton)
            alert.addAction(cancelButton)
            
            self.present(alert, animated: true, completion: nil)
    }
    
    func checkGoal(team:String, value:Int, colour: UIColor){
        if team == "home"{
            switch value {
            case 1:
                btnHome1.backgroundColor = colour
            case 2:
                btnHome2.backgroundColor = colour
            case 3:
                btnHome3.backgroundColor = colour
            case 4:
                btnHome4.backgroundColor = colour
            case 5:
                btnHome5.backgroundColor = colour
            default:
                break
            }
            
        }else if team == "away"{
            switch value {
            case 1:
                btnAway1.backgroundColor = colour
            case 2:
                btnAway2.backgroundColor = colour
            case 3:
                btnAway3.backgroundColor = colour
            case 4:
                btnAway4.backgroundColor = colour
            case 5:
                btnAway5.backgroundColor = colour
            default:
                break
            }
        }
    }
}
