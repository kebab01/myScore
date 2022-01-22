//
//  saveGameViewController.swift
//  FootballStats2
//
//  Created by Thomas Karbowiak on 4/9/20.
//  Copyright © 2020 Thomas Karbowiak. All rights reserved.
//

import UIKit
import CoreData
import GoogleMobileAds

class saveGameViewController: UIViewController, UITextViewDelegate, UITextFieldDelegate {
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    var interstitial: GADInterstitial!
    var gameID:Int64!
    
    @IBOutlet weak var txtHome: UITextField!
    @IBOutlet weak var txtAway: UITextField!
    @IBOutlet weak var txtLocation: UITextField!
    @IBOutlet weak var lblDate: UILabel!
    @IBOutlet weak var lblTime: UILabel!
    
    @IBOutlet weak var btnSave: UIButton!
    @IBOutlet weak var closeButton: UIButton!
    
    @IBOutlet weak var txtNotes: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // ad id ca-app-pub-4446566958882170/5960991316
        interstitial = GADInterstitial(adUnitID: "ca-app-pub-4446566958882170/5960991316")
        
        if premiumPurchase == false{
            let request = GADRequest()
            interstitial.load(request)
        }
        
        interstitial.delegate = self
        
        txtHome.text = homeTeamStats.name
        txtAway.text = awayTeamStats.name
        txtLocation.text = gameInfo.location
        lblDate.text = gameInfo.date
        lblTime.text = gameInfo.time
        
        self.txtHome.delegate = self
        self.txtAway.delegate = self
        self.txtLocation.delegate = self
        self.txtNotes.delegate = self
        
//        //formats text view
        txtNotes.layer.cornerRadius = 5
        txtNotes.layer.borderColor = UIColor.gray.withAlphaComponent(0.5).cgColor
        txtNotes.layer.borderWidth = 0.5
        txtNotes.clipsToBounds = true
        self.txtNotes.addDoneButton(title: "Done", target: self, selector: #selector(tapDone(sender:)))
        
        btnSave.layer.cornerRadius = 30
        closeButton.layer.cornerRadius = 13
        
        self.isModalInPresentation = true
        
        print(awayTeamStats.goalTimes.count)
        print("\(awayTeamStats.goalTimes)")
    }
    @IBAction func btnBack(_ sender: UIButton) {
        exitAlert()
    }
    
    @IBAction func btnSave(_ sender: UIButton) {
        
        (homeTeamStats.name == "")  ? (homeTeamStats.name = "Home") : (homeTeamStats.name = txtHome.text!)
        (awayTeamStats.name == "")  ? (awayTeamStats.name = "Away") : (awayTeamStats.name = txtAway.text!)
        (gameInfo.location == "")  ? (gameInfo.location = "Field 1") : (gameInfo.location = txtLocation.text!)
        
        gameInfo.notes = txtNotes.text
        
        checkForOff()
        save()
        
        homeTeamStats.name = txtHome.text!
        awayTeamStats.name = txtAway.text!
        gameInfo.location = txtLocation.text!
        
        if premiumPurchase == false{
            showAd()
        }else{
            self.performSegue(withIdentifier: "goBack", sender: self)
        }
        
    }
    func save(){
        
        var infoItems:[GameInfo]?
        let requestInfo = GameInfo.fetchRequest() as NSFetchRequest<GameInfo>
        
        //get value for game ID
        do{
            
            infoItems = try context.fetch(requestInfo)
                    
        }catch{
            print("there was an error",error)
        }
        if infoItems!.count != 0 && infoItems?[infoItems!.count - 1] != nil{
            let latestGame = infoItems![infoItems!.count - 1]
            gameID = latestGame.gameID
            gameID += 1
        }else{
            gameID = 0
        }
        
        
        let newHomeTeam = HomeTeam(context: self.context)
        let newAwayTeam = AwayTeam(context: self.context)
        let newGameInfo = GameInfo(context: self.context)
        
        newHomeTeam.name = String(homeTeamStats.name)
        
        newHomeTeam.goals = String(homeTeamStats.goals ?? 0)
        newHomeTeam.goalTimes = homeTeamStats.goalTimes
        newHomeTeam.goalsIn1 = Int64(homeTeamStats.goalsIn1 ?? 0)
        newHomeTeam.goalsIn2 = Int64(homeTeamStats.goalsIn2 ?? 0)
        
        newHomeTeam.corners = String(homeTeamStats.corners ?? 0)
        newHomeTeam.cornerTimes = homeTeamStats.cornerTimes
        newHomeTeam.cornersIn1 = Int64(homeTeamStats.cornersIn1 ?? 0)
        newHomeTeam.cornersIn2 = Int64(homeTeamStats.cornersIn2 ?? 0)
        
        newHomeTeam.offsides = String(homeTeamStats.offsides ?? 0)
        newHomeTeam.offsideTimes = homeTeamStats.offsideTimes
        newHomeTeam.offsidesIn1 = Int64(homeTeamStats.offsidesIn1 ?? 0)
        newHomeTeam.offsidesIn2 = Int64(homeTeamStats.offsidesIn2 ?? 0)
        
        newHomeTeam.shots = String(homeTeamStats.shots ?? 0)
        newHomeTeam.shotTimes = homeTeamStats.shotTimes
        newHomeTeam.shotsIn1 = Int64(homeTeamStats.shotsIn1 ?? 0)
        newHomeTeam.shotsIn2 = Int64(homeTeamStats.shotsIn2 ?? 0)
        
        newHomeTeam.shotsOnTarget = String(homeTeamStats.shotsOnTarget ?? 0)
        newHomeTeam.shotOnTargetTimes = homeTeamStats.shotsOnTargetTimes
        newHomeTeam.shotsOnTargetIn1 = Int64(homeTeamStats.shotsOnTargetIn1 ?? 0)
        newHomeTeam.shotsOnTargetIn2 = Int64(homeTeamStats.shotsOnTargetIn2 ?? 0)
        
        newHomeTeam.fouls = String(homeTeamStats.fouls ?? 0)
        newHomeTeam.foulTimes = homeTeamStats.foulTimes
        newHomeTeam.foulsIn1 = Int64(homeTeamStats.foulsIn1 ?? 0)
        newHomeTeam.foulsIn2 = Int64(homeTeamStats.foulsIn2 ?? 0)
        
        newHomeTeam.saves = String(homeTeamStats.saves ?? 0)
        newHomeTeam.saveTimes = homeTeamStats.saveTimes
        newHomeTeam.savesIn1 = Int64(homeTeamStats.savesIn1 ?? 0)
        newHomeTeam.savesIn2 = Int64(homeTeamStats.savesIn2 ?? 0)
        
        newHomeTeam.goalKicks = String(homeTeamStats.goalKicks ?? 0)
        newHomeTeam.goalKickTimes = homeTeamStats.goalKickTimes
        newHomeTeam.goalKicksIn1 = Int64(homeTeamStats.goalKicksIn1 ?? 0)
        newHomeTeam.goalKicksIn2 = Int64(homeTeamStats.goalKicksIn2 ?? 0)
        
        newHomeTeam.throwIns = String(homeTeamStats.throwIns ?? 0)
        newHomeTeam.throwInTimes = homeTeamStats.throwInTimes
        newHomeTeam.throwInsIn1 = Int64(homeTeamStats.throwInsIn1 ?? 0)
        newHomeTeam.throwInsIn2 = Int64(homeTeamStats.throwInsIn2 ?? 0)
        
        newHomeTeam.yellowCards = String(homeTeamStats.yellowCard ?? 0)
        newHomeTeam.yellowCardTimes = homeTeamStats.yellowCardTimes
        newHomeTeam.yellowCardsIn1 = Int64(homeTeamStats.yellowCardIn1 ?? 0)
        newHomeTeam.yellowCardsIn2 = Int64(homeTeamStats.yellowCardIn2 ?? 0)
        
        newHomeTeam.redCards = String(homeTeamStats.redCard ?? 0)
        newHomeTeam.redCardTimes = homeTeamStats.redCardTimes
        newHomeTeam.redCardsIn1 = Int64(homeTeamStats.redCardIn1 ?? 0)
        newHomeTeam.redCardsIn2 = Int64(homeTeamStats.redCardIn2 ?? 0)
        
        newHomeTeam.penalties = String(homeTeamStats.penalties ?? 0)
        
        newHomeTeam.date = String(gameInfo.date)
        newHomeTeam.time = String(gameInfo.time)
        newHomeTeam.dateAsDate = gameInfo.dateAsDate
        newHomeTeam.gameID = gameID
        newHomeTeam.gameVersion = Float(gameVersion)
        
        //away team saving
        newAwayTeam.name = String(awayTeamStats.name)
        
        newAwayTeam.goals = String(awayTeamStats.goals ?? 0)
        newAwayTeam.goalTimes = awayTeamStats.goalTimes
        newAwayTeam.goalsIn1 = Int64(awayTeamStats.goalsIn1 ?? 0)
        newAwayTeam.goalsIn2 = Int64(awayTeamStats.goalsIn2 ?? 0)
        
        newAwayTeam.corners = String(awayTeamStats.corners ?? 0)
        newAwayTeam.cornerTimes = awayTeamStats.cornerTimes
        newAwayTeam.cornersIn1 = Int64(awayTeamStats.cornersIn1 ?? 0)
        newAwayTeam.cornersIn2 = Int64(awayTeamStats.cornersIn2 ?? 0)
        
        newAwayTeam.offsides = String(awayTeamStats.offsides ?? 0)
        newAwayTeam.offsideTimes = awayTeamStats.offsideTimes
        newAwayTeam.offsidesIn1 = Int64(awayTeamStats.offsidesIn1 ?? 0)
        newAwayTeam.offsidesIn2 = Int64(awayTeamStats.offsidesIn2 ?? 0)
        
        newAwayTeam.shots = String(awayTeamStats.shots ?? 0)
        newAwayTeam.shotTimes = awayTeamStats.shotTimes
        newAwayTeam.shotsIn1 = Int64(awayTeamStats.shotsIn1 ?? 0)
        newAwayTeam.shotsIn2 = Int64(awayTeamStats.shotsIn2 ?? 0)
        
        newAwayTeam.shotsOnTarget = String(awayTeamStats.shotsOnTarget ?? 0)
        newAwayTeam.shotOnTargetTimes = awayTeamStats.shotsOnTargetTimes
        newAwayTeam.shotsOnTargetIn1 = Int64(awayTeamStats.shotsOnTargetIn1 ?? 0)
        newAwayTeam.shotsOnTargetIn2 = Int64(awayTeamStats.shotsOnTargetIn2 ?? 0)
        
        newAwayTeam.fouls = String(awayTeamStats.fouls ?? 0)
        newAwayTeam.foulTimes = awayTeamStats.foulTimes
        newAwayTeam.foulsIn1 = Int64(awayTeamStats.foulsIn2 ?? 0)
        newAwayTeam.foulsIn2 = Int64(awayTeamStats.foulsIn2 ?? 0)
        
        newAwayTeam.saves = String(awayTeamStats.saves ?? 0)
        newAwayTeam.saveTimes = awayTeamStats.saveTimes
        newAwayTeam.savesIn1 = Int64(awayTeamStats.savesIn1 ?? 0)
        newAwayTeam.savesIn2 = Int64(awayTeamStats.savesIn2 ?? 0)
        
        newAwayTeam.goalKicks = String(awayTeamStats.goalKicks ?? 0)
        newAwayTeam.goalKickTimes = awayTeamStats.goalKickTimes
        newAwayTeam.goalKicksIn1 = Int64(awayTeamStats.goalKicksIn1 ?? 0)
        newAwayTeam.goalKicksIn2 = Int64(awayTeamStats.goalKicksIn2 ?? 0)
        
        newAwayTeam.throwIns = String(awayTeamStats.throwIns ?? 0)
        newAwayTeam.throwInTimes = awayTeamStats.throwInTimes
        newAwayTeam.throwInsIn1 = Int64(awayTeamStats.throwInsIn1 ?? 0)
        newAwayTeam.throwInsIn2 = Int64(awayTeamStats.throwInsIn2 ?? 0)
        
        newAwayTeam.yellowCards = String(awayTeamStats.yellowCard ?? 0)
        newAwayTeam.yellowCardTimes = awayTeamStats.yellowCardTimes
        newAwayTeam.yellowCardsIn1 = Int64(awayTeamStats.yellowCardIn1 ?? 0)
        newAwayTeam.yellowCardsIn2 = Int64(awayTeamStats.yellowCardIn2 ?? 0)
        
        newAwayTeam.redCards = String(awayTeamStats.redCard ?? 0)
        newAwayTeam.redCardTimes = awayTeamStats.redCardTimes
        newAwayTeam.redCardsIn1 = Int64(awayTeamStats.redCardIn1 ?? 0)
        newAwayTeam.redCardsIn2 = Int64(awayTeamStats.redCardIn2 ?? 0)
        
        newAwayTeam.penalties = String(awayTeamStats.penalties ?? 0)
        
        newAwayTeam.date = String(gameInfo.date)
        newAwayTeam.time = String(gameInfo.time)
        newAwayTeam.dateAsDate = gameInfo.dateAsDate
        newAwayTeam.gameID = gameID
        newAwayTeam.gameVersion = Float(gameVersion)
        
        //gameinfo saving
        newGameInfo.location = String(gameInfo.location)
        newGameInfo.notes = gameInfo.notes
        newGameInfo.date = String(gameInfo.date)
        newGameInfo.dateAsDate = gameInfo.dateAsDate
        newGameInfo.time = String(gameInfo.time)
        newGameInfo.halfLength = String(gameInfo.halfLength / 60)
        newGameInfo.gameID = gameID
        newGameInfo.gameVersion = Float(gameVersion)
        
            do{
                try self.context.save()
                print("Games Saved on", gameInfo.date, "time", gameInfo.time)
                
            }catch {
                print("there was an error", error)
            }
        }
    func exitAlert(){
        let alert = UIAlertController(title: "Exit without saving", message: "Do you wish to exit this game without saving?", preferredStyle: .alert)
        
        let yesButton = UIAlertAction(title: "Yes", style: .default) { (action) in
            if premiumPurchase == false{
                self.showAd()
            }else{
                self.performSegue(withIdentifier: "goBack", sender: self)
            }
        }
        let noButton = UIAlertAction(title: "No", style: .default) { (action) in
            
        }
        alert.addAction(yesButton)
        alert.addAction(noButton)
        self.present(alert, animated: true)
    }
    func showAd(){
        if self.interstitial.isReady {
            self.interstitial.present(fromRootViewController: self)
        } else {
          print("Ad wasn't ready")
            self.performSegue(withIdentifier: "goBack", sender: self)
        }
    }
    func checkForOff(){

            for i in 0...(positionDefualts!.count - 1) {
                let stat = positionDefualts![i]

                let switchState = myDefaults.bool(forKey: positionDefualts![i] + "State")

                if switchState == false{
                    markStat(stat: stat)
                }
            }
        }
    func markStat(stat: String){
        // if stat was turned off value of stat is chnaged to 999
        // for reading in saved Game page
        let mark = 9999
        switch stat {
        case "Goals":
            homeTeamStats.goals = mark
            awayTeamStats.goals = mark
        case "Corners":
            homeTeamStats.corners = mark
            awayTeamStats.corners = mark
        case "Offsides":
            homeTeamStats.offsides = mark
            awayTeamStats.offsides = mark
        case "Shots":
            homeTeamStats.shots = mark
            awayTeamStats.shots = mark
        case "Shots on Target":
            homeTeamStats.shotsOnTarget = mark
            awayTeamStats.shotsOnTarget = mark
        case "Fouls":
            homeTeamStats.fouls = mark
            awayTeamStats.fouls = mark
        case "Saves":
            homeTeamStats.saves = mark
            awayTeamStats.saves = mark
        case "Goal Kicks":
            homeTeamStats.goalKicks = mark
            awayTeamStats.goalKicks = mark
        case "Throw-ins":
            homeTeamStats.throwIns = mark
            awayTeamStats.throwIns = mark
        case "Yellow Cards":
            homeTeamStats.yellowCard = mark
            awayTeamStats.yellowCard = mark
        case "Red Cards":
            homeTeamStats.redCard = mark
            awayTeamStats.redCard = mark
        default:
            break
        }
    }
    
    //MARK:- addition textView/Field setup
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    func textViewShouldEndEditing(_ textView: UITextView) -> Bool {
        textView.resignFirstResponder()
        return true
    }
    @objc func tapDone(sender: Any) {
            self.view.endEditing(true)
        }
}
extension saveGameViewController:GADInterstitialDelegate{
    func interstitialDidReceiveAd(_ ad: GADInterstitial) {
      print("interstitialDidReceiveAd")
    }
    func interstitialWillPresentScreen(_ ad: GADInterstitial) {
        print("Ad presented")
    }

    func interstitialDidDismissScreen(_ ad: GADInterstitial) {
        // Send another GADRequest here
        print("Ad dismissed")
        self.performSegue(withIdentifier: "goBack", sender: self)
    }
}
extension UITextView {
    
    func addDoneButton(title: String, target: Any, selector: Selector) {
        
        let toolBar = UIToolbar(frame: CGRect(x: 0.0, y: 0.0, width: UIScreen.main.bounds.size.width, height: 44.0))//1
        let flexible = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)//2
        let barButton = UIBarButtonItem(title: title, style: .plain, target: target, action: selector)//3
        toolBar.setItems([flexible, barButton], animated: false)//4
        self.inputAccessoryView = toolBar//5
    }
}
