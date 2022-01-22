//
//  SelectedGameViewController.swift
//  FootballStats2
//
//  Created by Thomas Karbowiak on 13/9/20.
//  Copyright © 2020 Thomas Karbowiak. All rights reserved.
//

import UIKit
import GoogleMobileAds

// this variable can be accessed by the alert
var selectedGameNotes:String?

class SelectedGameViewController: UIViewController {

    //home team labels
    @IBOutlet weak var lblHomeTeam: UILabel!
    @IBOutlet weak var lblHomeTeam2: UILabel!
    @IBOutlet weak var lblHomeGoals: UILabel!
    @IBOutlet weak var lblHomeCorners: UILabel!
    @IBOutlet weak var lblHomeShots: UILabel!
    @IBOutlet weak var lblHomeShotsOnTarget: UILabel!
    @IBOutlet weak var lblHomeOffsides: UILabel!
    @IBOutlet weak var lblHomeFouls: UILabel!
    @IBOutlet weak var lblHomeSaves: UILabel!
    @IBOutlet weak var lblHomeGoalKicks: UILabel!
    @IBOutlet weak var lblHomeThrowIns: UILabel!
    @IBOutlet weak var lblHomeYellowCards: UILabel!
    @IBOutlet weak var lblHomeRedCards: UILabel!
    @IBOutlet weak var lblHomeGoalTimes: UILabel!
    
    @IBOutlet weak var lblAwayTeam: UILabel!
    @IBOutlet weak var lblAwayTeam2: UILabel!
    @IBOutlet weak var lblAwayGoals: UILabel!
    @IBOutlet weak var lblAwayCorners: UILabel!
    @IBOutlet weak var lblAwayShots: UILabel!
    @IBOutlet weak var lblAwayShotsOnTarget: UILabel!
    @IBOutlet weak var lblAwayOffsides: UILabel!
    @IBOutlet weak var lblAwayFouls: UILabel!
    @IBOutlet weak var lblAwaySaves: UILabel!
    @IBOutlet weak var lblAwayGoalKicks: UILabel!
    @IBOutlet weak var lblAwayThrowIns: UILabel!
    @IBOutlet weak var lblAwayYellowCards: UILabel!
    @IBOutlet weak var lblAwayRedCards: UILabel!
    @IBOutlet weak var lblAwayGoalTimes: UILabel!
    
    //text labels for game info
    @IBOutlet weak var lblDate: UILabel!
    @IBOutlet weak var lblTime: UILabel!
    @IBOutlet weak var lblLocation: UILabel!
    
    @IBOutlet weak var lblP: UILabel!
    @IBOutlet weak var lblPenalties: UILabel!
    
    @IBOutlet weak var btnNotes: UIButton!
    
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var prgSeperator: UIProgressView!
    @IBOutlet weak var bannerView: GADBannerView!
    
    @IBOutlet weak var homeGoalTimesScrollView: UIScrollView!
    
    var gameSelected = 0
    
    var positionDefualts = myDefaults.object(forKey: "statPositions") as? [String]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //id ca-app-pub-4446566958882170/9301410458
        if premiumPurchase == false{
            bannerView.adUnitID = "ca-app-pub-4446566958882170/9301410458"
            bannerView.rootViewController = self
            bannerView.load(GADRequest())
            bannerView.delegate = self
        }else{
            print("ad did not display as premium has been purchased")
        }
        
        prgSeperator.layer.cornerRadius = 5
        prgSeperator.clipsToBounds = true
        prgSeperator.clipsToBounds = true
        prgSeperator.layer.sublayers![1].cornerRadius = 5
        prgSeperator.subviews[1].clipsToBounds = true
        
        closeButton.layer.cornerRadius = 13
        
        self.homeGoalTimesScrollView.transform = CGAffineTransform(rotationAngle: CGFloat(Double.pi));
        lblHomeGoalTimes.transform = CGAffineTransform(rotationAngle: CGFloat(Double.pi));
        
        getData()
        if selectedGameNotes == nil || selectedGameNotes == ""{
            btnNotes.removeFromSuperview()
        }
    }
    @IBAction func didTapViewNotes(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let myAlert = storyboard.instantiateViewController(withIdentifier: "alert")
        myAlert.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext
        myAlert.modalTransitionStyle = UIModalTransitionStyle.crossDissolve
        self.present(myAlert, animated: true) {
                let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.dissmissAlert))
                myAlert.view.superview?.subviews[0].addGestureRecognizer(tapGesture)
        }
    }
    @IBAction func btnClose(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    func getData(){
        
        let homeTeam = homeItems![gameSelected]
        let awayTeam = awayItems![gameSelected]
        let gameInfomation = infoItems![gameSelected]
        
        displayGoalTimes()
        
        let mark = "9999" // if stat has value of 9999 it was not recorded
        // displays game stats
        lblHomeTeam.text = homeTeam.name
        lblHomeTeam2.text = homeTeam.name
        (homeTeam.goals == mark) ? (lblHomeGoals.text = "-"): (lblHomeGoals.text = homeTeam.goals)
        (homeTeam.corners == mark) ? (lblHomeCorners.text = "-"): (lblHomeCorners.text = homeTeam.corners)
        (homeTeam.shots == mark) ? (lblHomeShots.text = "-"): (lblHomeShots.text = homeTeam.shots)
        (homeTeam.shotsOnTarget == mark) ? (lblHomeShotsOnTarget.text = "-"): (lblHomeShotsOnTarget.text = homeTeam.shotsOnTarget)
        (homeTeam.offsides == mark) ? (lblHomeOffsides.text = "-"): (lblHomeOffsides.text = homeTeam.offsides)
        (homeTeam.fouls == mark) ? (lblHomeFouls.text = "-"): (lblHomeFouls.text = homeTeam.fouls)
        (homeTeam.saves == mark) ? (lblHomeSaves.text = "-"): (lblHomeSaves.text = homeTeam.saves)
        //for backwards compatability
        (homeTeam.goalKicks == mark || homeTeam.goalKicks == nil) ? (lblHomeGoalKicks.text = "-"): (lblHomeGoalKicks.text = homeTeam.goalKicks)
        (homeTeam.throwIns == mark || homeTeam.throwIns == nil) ? (lblHomeThrowIns.text = "-"): (lblHomeThrowIns.text = homeTeam.throwIns)
        
        (homeTeam.yellowCards == mark) ? (lblHomeYellowCards.text = "-"): (lblHomeYellowCards.text = homeTeam.yellowCards)
        (homeTeam.redCards == mark) ? (lblHomeRedCards.text = "-"): (lblHomeRedCards.text = homeTeam.redCards)
        
        lblAwayTeam.text = awayTeam.name
        lblAwayTeam2.text = awayTeam.name
        (awayTeam.goals == mark) ? (lblAwayGoals.text = "-"): (lblAwayGoals.text = awayTeam.goals)
        (awayTeam.corners == mark) ? (lblAwayCorners.text = "-"): (lblAwayCorners.text = awayTeam.corners)
        (awayTeam.shots == mark) ? (lblAwayShots.text = "-"): (lblAwayShots.text = awayTeam.shots)
        (awayTeam.shotsOnTarget == mark) ? (lblAwayShotsOnTarget.text = "-"): (lblAwayShotsOnTarget.text = awayTeam.shotsOnTarget)
        (awayTeam.offsides == mark) ? (lblAwayOffsides.text = "-"): (lblAwayOffsides.text = awayTeam.offsides)
        (awayTeam.fouls == mark) ? (lblAwayFouls.text = "-"): (lblAwayFouls.text = awayTeam.fouls)
        (awayTeam.saves == mark) ? (lblAwaySaves.text = "-"): (lblAwaySaves.text = awayTeam.saves)
        //backwards compatability
        (awayTeam.goalKicks == mark || awayTeam.goalKicks == nil) ? (lblAwayGoalKicks.text = "-"): (lblAwayGoalKicks.text = awayTeam.goalKicks)
        (awayTeam.throwIns == mark || awayTeam.throwIns == nil) ? (lblAwayThrowIns.text = "-"): (lblAwayThrowIns.text = awayTeam.throwIns)
        
        (awayTeam.yellowCards == mark) ? (lblAwayYellowCards.text = "-"): (lblAwayYellowCards.text = awayTeam.yellowCards)
        (awayTeam.redCards == mark) ? (lblAwayRedCards.text = "-"): (lblAwayRedCards.text = awayTeam.redCards)
        
        lblDate.text = gameInfomation.date
        lblTime.text = gameInfomation.time
        lblLocation.text = gameInfomation.location
        selectedGameNotes = gameInfomation.notes
        
        if Int(homeTeam.penalties!)! > 0 || Int(awayTeam.penalties!)! > 0{
            lblPenalties.text = String(homeTeam.penalties!) + " - " + String(awayTeam.penalties!)
            
        }else{
            lblP.text = ""
            lblPenalties.text = ""
        }
    }
    func displayGoalTimes(){
        let homeTeam = homeItems![gameSelected]
        let awayTeam = awayItems![gameSelected]
        
        if homeTeam.goalTimes!.count > 1{
            var goalTimeString = [String]()
            let items = homeTeam.goalTimes
            for i in 0...items!.count - 1{
                goalTimeString.append(String(homeTeam.goalTimes![i]))
            }
            // reverses the order of the array
            var goalTimeReversed = [String]()
            
            for i in 0...goalTimeString.count - 1{

                goalTimeReversed.append(goalTimeString[(goalTimeString.count - 1) - i])
            }
            goalTimeReversed.append("")
            let joined = goalTimeReversed.joined(separator: "' ")
            lblHomeGoalTimes.text = joined
            
        }else if homeTeam.goalTimes!.count == 1{
            var goalTimeString = [String]()
            goalTimeString.append(String(homeTeam.goalTimes![0]))
            goalTimeString.append("")
            let joined = goalTimeString.joined(separator: "' ")
            lblHomeGoalTimes.text = joined
        }else{
            lblHomeGoalTimes.text = ""
        }
        // away goal times
        if awayTeam.goalTimes!.count > 1{
            var goalTimeString = [String]()
            let items = awayTeam.goalTimes
            for i in 0...items!.count - 1{
                goalTimeString.append(String(awayTeam.goalTimes![i]))
            }
            
            goalTimeString.append("")
            let joined = goalTimeString.joined(separator: "' ")
            lblAwayGoalTimes.text = joined
            
        }else if awayTeam.goalTimes!.count == 1{
            var goalTimeString = [String]()
            goalTimeString.append(String(awayTeam.goalTimes![0]))
            goalTimeString.append("")
            let joined = goalTimeString.joined(separator: "' ")
            lblAwayGoalTimes.text = joined
        }else{
            lblAwayGoalTimes.text = ""
        }
    }
    
    @objc func dissmissAlert()
    {
        self.dismiss(animated: true, completion: nil)
    }
}
extension SelectedGameViewController:GADBannerViewDelegate{
    func adViewDidReceiveAd(_ bannerView: GADBannerView) {
        print("revieved ad")
    }
    
    func adView(_ bannerView: GADBannerView, didFailToReceiveAdWithError error: GADRequestError) {
        print(error)
    }
    
}
