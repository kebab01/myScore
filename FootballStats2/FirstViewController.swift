//
//  FirstViewController.swift
//  FootballStats2
//
//  Created by Thomas Karbowiak on 4/9/20.
//  Copyright © 2020 Thomas Karbowiak. All rights reserved.
//

import UIKit
import CoreData
import GoogleMobileAds

class FirstViewController: UIViewController, UITextFieldDelegate, UITabBarDelegate {
    
    @IBOutlet weak var bannerView: GADBannerView!
    
    @IBOutlet weak var txtHome: UITextField!
    @IBOutlet weak var txtAway: UITextField!
    @IBOutlet weak var txtLocation: UITextField!
    
    @IBOutlet weak var lblStartGameButton: UIButton!
    @IBOutlet weak var segmentControl: UISegmentedControl!
    
    //haptic engine declaration
    let generator = UISelectionFeedbackGenerator()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // ad id ca-app-pub-4446566958882170/6455815338
        // test id ca-app-pub-3940256099942544/2934735716
        print("has updated" , hasUpdated)
        (isNotFirstLaunch == true && hasUpdated == 0) ? (launchAlert()) : ()
        (isNotFirstLaunch == false) ? (firstLaunch()) : ()
        if premiumPurchase == false{
            bannerView.adUnitID = "ca-app-pub-4446566958882170/6455815338"
            bannerView.rootViewController = self
            bannerView.load(GADRequest())
            bannerView.delegate = self
        }else{
            print("ad did not display as premium has been purchased")
            
        }
        self.tabBarController?.selectedIndex = 0
        
        generator.prepare()
        
        // Do any additional setup after loading the view.
        self.txtHome.delegate = self
        self.txtAway.delegate = self
        self.txtLocation.delegate = self
        
//        formatting segment control
        var titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
        segmentControl.setTitleTextAttributes(titleTextAttributes, for:.normal)
        titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.black]
        segmentControl.setTitleTextAttributes(titleTextAttributes, for: .selected)
        segmentControl.layer.cornerRadius = 10
        segmentControl.clipsToBounds = true
        
//        formatting stat button
        lblStartGameButton.layer.cornerRadius = 30

      
    }
    @IBAction func didChangeSeg(_ sender: UISegmentedControl) {
        
         switch sender.selectedSegmentIndex {
         case 0:
             gameInfo.halfLength = 45
         case 1:
             gameInfo.halfLength = 35
         case 2:
             gameInfo.halfLength = 30
         default:
             gameInfo.halfLength = 45
         }
        generator.selectionChanged()
     }
    
    @IBAction func btnSubmit(_ sender: UIButton) {
        
        generator.selectionChanged()
        //sorts glitch where correct game time is not displayed
        if gameInfo.halfLength == 0{
            gameInfo.halfLength = 45
        }
        //stop consistently mulitplying the time
        print(gameInfo.halfLength)
        if gameInfo.halfLength <= 45{
            gameInfo.halfLength = gameInfo.halfLength * 60
        }
    
        
        (txtHome.text == "")  ? (homeTeamStats.name = "Home") : (homeTeamStats.name = txtHome.text!)
        (txtAway.text == "")  ? (awayTeamStats.name = "Away") : (awayTeamStats.name = txtAway.text!)
        (txtLocation.text == "")  ? (gameInfo.location = "Field 1") : (gameInfo.location = txtLocation.text!)
        
        let gameDate = Date()
        
        let dateFormat = DateFormatter()
        dateFormat.dateFormat = "dd/MM/yy"
        let date = dateFormat.string(from: gameDate)
        gameInfo.date = date
        gameInfo.dateAsDate = gameDate
        
        let timeFormat = DateFormatter()
        timeFormat.dateFormat = "hh:mm"
        let time = timeFormat.string(from: gameDate)
        gameInfo.time = time
        print(gameInfo.date, "this is the time", gameInfo.time)
    }
    
    func firstLaunch(){
        
        myDefaults.set(stats, forKey: "statPositions")
        positionDefualts = stats
        
        for i in 0...stats.count - 1{
            
            (stats[i] == "Goal Kicks" || stats[i] == "Throw-ins") ? (myDefaults.set(false, forKey: stats[i] + "State")):(myDefaults.set(true, forKey: stats[i] + "State"))
        }
        
        isNotFirstLaunch = true
        myDefaults.set(true, forKey: "isNotFirstLaunch")
    }
    
    func launchAlert(){
        myDefaults.set(1, forKey: "hasUpdated")
        let message = "You now have the ability to control which statistics you actually want to record. Head to the setting page to change this."
        let alert = UIAlertController(title: "Whats New?", message: message, preferredStyle: .alert)
        
        let btnShowMe = UIAlertAction(title: "Show me", style: .default) {(action) in
            
            self.performSegue(withIdentifier: "settings", sender: self)
        }
        let btnClose = UIAlertAction(title: "close", style: .cancel, handler: nil)
        
        alert.addAction(btnClose)
        alert.addAction(btnShowMe)
        self.present(alert, animated: true, completion: nil)
    }
    @IBAction func unwindToViewControllerA(segue: UIStoryboardSegue) {
        
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
extension FirstViewController:GADBannerViewDelegate{
    func adViewDidReceiveAd(_ bannerView: GADBannerView) {
        print("revieved ad")
    }

    func adView(_ bannerView: GADBannerView, didFailToReceiveAdWithError error: GADRequestError) {
        
        print(error)
    }

}
