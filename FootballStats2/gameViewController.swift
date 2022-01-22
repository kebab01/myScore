//
//  gameViewController.swift
//  FootballStats2
//
//  Created by Thomas Karbowiak on 4/9/20.
//  Copyright © 2020 Thomas Karbowiak. All rights reserved.
//

import UIKit
import GoogleMobileAds

class gameViewController: UIViewController, UITableViewDelegate,UITableViewDataSource, UITabBarDelegate {
    
    @IBOutlet weak var bannerView: GADBannerView!
    
    @IBOutlet weak var lblHome: UILabel!
    @IBOutlet weak var lblAway: UILabel!
    @IBOutlet weak var lblTimer: UILabel!
    
    @IBOutlet weak var txtPauseButton: UIButton!
    @IBOutlet weak var txtEndHalfButton: UIButton!
    @IBOutlet weak var txtEndGameButton: UIButton!
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var adErrorLabel: UILabel!
    
    var positionDefualts = myDefaults.object(forKey: "statPositions") as? [String]
    var statsToRecord = [String]()
    
    var totalNum = 0;
    
    var clock = Timer()
    
    var gameTimer = gameInfo.halfLength
    var gameClock = 0
    var timerCompleted = false
    var halfCompleted = false
    var halfTrack = 1
    var timerPaused = false
    
    let generator = UISelectionFeedbackGenerator()
    let impactGen = UIImpactFeedbackGenerator(style: .light)
    
    var interstitial: GADInterstitial!
    var adDidFail = false
    
    //MARK: - viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // ad id ca-app-pub-4446566958882170/1067697211
        // interstitial if ca-app-pub-4446566958882170/4336588885
        
        interstitial = GADInterstitial(adUnitID: "ca-app-pub-4446566958882170/4336588885")
        bannerView.adUnitID = "ca-app-pub-4446566958882170/1067697211"
        
        bannerView.delegate = self
        bannerView.rootViewController = self
        interstitial.delegate = self
        
        if premiumPurchase == false{
            //get banner ad
            bannerView.load(GADRequest())
            //get interstial ad
            let request = GADRequest()
            interstitial.load(request)
            
        }else{
            bannerView.removeFromSuperview()
            bannerView.backgroundColor = .red
            print("ad did not display as premium has been purchased")
        }

        lblHome.text = homeTeamStats.name
        lblAway.text = awayTeamStats.name
        
        gameInProgress = true
        setTimer()
        resetStats()
        generator.prepare()

        txtEndHalfButton.isUserInteractionEnabled = false
        txtEndGameButton.layer.cornerRadius = 20
        txtPauseButton.layer.cornerRadius = 20

        navigationItem.hidesBackButton = true
        
        let items =  self.tabBarController?.tabBar.items
        let itemToDisable = items![0]
        itemToDisable.isEnabled = false
        
        let nib = UINib(nibName: "gameStatsTableViewCell", bundle: nil)
        let seperatorNib = UINib(nibName: "seperatorTableViewCell", bundle: nil)
        
        tableView.register(nib, forCellReuseIdentifier: "gameStatsTableViewCell")
        tableView.register(seperatorNib, forCellReuseIdentifier: "seperatorTableViewCell")
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        tableView.allowsSelection = false
        
        statToRecord()
        
    }
    //MARK: - @IBactions
    
    @IBAction func btnPause(_ sender: Any) {
        generator.selectionChanged()
        if timerPaused == false {
            txtPauseButton.setTitle("Resume", for: .normal)
            timerPaused = true
            clock.invalidate()
        }else{
            txtPauseButton.setTitle("Pause", for: .normal)
            timerPaused = false
            setTimer()
        }
    }
    @IBAction func btnEnd(_ sender: Any) {
        generator.selectionChanged()
        if halfCompleted == false{
            let alert = UIAlertController(title: "Finish Early", message: "Would you like to the half or game early?", preferredStyle: .alert)
            
            let endHalfButton = UIAlertAction(title: "End Half", style: .default) { (action) in
                self.halfCompleted = true
                self.startHalfButton()
                (premiumPurchase == false) ? (self.showAd()) : ()
            }
            let endGameButton = UIAlertAction(title: "End Game", style: .default) { (action) in
                self.halfCompleted = true
                self.timerCompleted = true
                gameInProgress = false
                self.clock.invalidate()
                self.performSegue(withIdentifier: "gameEnded", sender: self)
            }
            let cancelButton = UIAlertAction(title: "Cancel", style: .default) { (action) in
                self.dismiss(animated: true, completion: nil)
            }
            alert.addAction(endHalfButton)
            alert.addAction(endGameButton)
            alert.addAction(cancelButton)
            
            self.present(alert, animated: true, completion: nil)
        }else{
            let alert = UIAlertController(title: "End Game?", message: "Are you sure you would like to end the game", preferredStyle: .alert)
            
            let endGameButton = UIAlertAction(title: "End Game", style: .default) { (action) in
                self.halfCompleted = true
                self.timerCompleted = true
                self.clock.invalidate()
                self.performSegue(withIdentifier: "gameEnded", sender: self)
            }
            let cancelButton = UIAlertAction(title: "Cancel", style: .default) { (action) in
                self.dismiss(animated: true, completion: nil)
            }
            
            alert.addAction(endGameButton)
            alert.addAction(cancelButton)
            
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    @IBAction func btnEndHalf(_ sender: Any) {
        generator.selectionChanged()
        if halfCompleted == false{
            //diplayes green start button
            startHalfButton()
            halfCompleted = true
            
        }else if halfCompleted == true && halfTrack != 4 { // clicked start
            halfCompleted = false
            //removes button
            txtEndHalfButton.setTitle("", for: .normal)
            txtEndHalfButton.tintColor = .clear
            txtEndHalfButton.backgroundColor = .clear
            txtEndHalfButton.isUserInteractionEnabled = false
            //reset timer
            setTimer()
            halfTrack += 1
            
        }else{
            performSegue(withIdentifier: "shootOut", sender: self)
        }
    }
    
    // MARK: - Functions
    //tableView functions
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var numberOfCell = 0
        
        (premiumPurchase == false && adDidFail == false)  ? (numberOfCell += 1) : ()
        
        numberOfCell += statsToRecord.count
        
        return numberOfCell
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "gameStatsTableViewCell", for: indexPath) as! gameStatsTableViewCell
        let seperatorCell = tableView.dequeueReusableCell(withIdentifier: "adCell", for: indexPath)
        
        //adds space for ad
        if premiumPurchase == false && adDidFail == false && indexPath.row == 0{
            return seperatorCell
        }else{
            
            if premiumPurchase == false && adDidFail == false{
                if statsToRecord[indexPath.row - 1] == "Yellow Cards"{
                    let image = #imageLiteral(resourceName: "Yellow Card.png") // yellowcard
                    cell.statImage.image = image
                    cell.lblStat.text = ""
                }else if statsToRecord[indexPath.row - 1] == "Red Cards"{
                    let image = #imageLiteral(resourceName: "Red Card.png") //redcard
                    cell.statImage.image = image
                    cell.lblStat.text = ""
                }else{
                    cell.statImage.image = nil
                    cell.lblStat.text = statsToRecord[indexPath.row - 1]
                }
            }else{
                if statsToRecord[indexPath.row] == "Yellow Cards"{
                    let image = #imageLiteral(resourceName: "Yellow Card.png") // yellowcard
                    cell.statImage.image = image
                    cell.lblStat.text = ""
                }else if statsToRecord[indexPath.row] == "Red Cards"{
                    let image = #imageLiteral(resourceName: "Red Card.png") //redcard
                    cell.statImage.image = image
                    cell.lblStat.text = ""
                }else{
                    cell.statImage.image = nil
                    cell.lblStat.text = statsToRecord[indexPath.row]
                }
                
            }
            
            let values = cellStatValue(index: indexPath.row)
            cell.lblHomeCount.text = String(values.homeValue)
            cell.lblAwayCount.text = String(values.awayValue)
            
            var progress = Progress(totalUnitCount: 0)
            totalNum = Int(values.homeValue) + Int(values.awayValue)
            progress = Progress(totalUnitCount: Int64(totalNum))
            progress.completedUnitCount = Int64(values.homeValue)
            
            if (values.homeValue == 0) && (values.awayValue == 0){
                cell.progressBar.setProgress(Float(0.5), animated: true)
            }else{
                cell.progressBar.setProgress(Float(progress.fractionCompleted), animated: true)
            }
            cell.homeStepper.value = Double(values.homeValue)
            cell.awayStepper.value = Double(values.awayValue)
            
            cell.homeStepper.tag = indexPath.row
            cell.lblHomeCount.tag = indexPath.row
            cell.awayStepper.tag = indexPath.row + 100 // + 100 is so away stat will never clash with home stat
            cell.awayStepper.tag = indexPath.row + 100
            
            cell.homeStepper.addTarget(self, action: #selector(changeValue(_ :)), for: .valueChanged)
            cell.awayStepper.addTarget(self, action: #selector(changeValue(_ :)), for: .valueChanged)
            
            return cell
            
        }
    }
    func cellStatValue(index: Int) -> (homeValue: Int, awayValue: Int){
        var homeValue = 0
        var awayValue = 0
        
        var row = index
        (index >= 100) ? (row -= 100) : ()
        
        (premiumPurchase == false && adDidFail == false) ? (row -= 1) : ()
        
        let stat = statsToRecord[row]
        
        switch stat {
        case "Goals":
            homeValue = homeTeamStats.goals ?? 0
            awayValue = awayTeamStats.goals ?? 0
        case "Corners":
            homeValue = homeTeamStats.corners ?? 0
            awayValue = awayTeamStats.corners ?? 0
        case "Offsides":
            homeValue = homeTeamStats.offsides ?? 0
            awayValue = awayTeamStats.offsides ?? 0
        case "Shots":
            homeValue = homeTeamStats.shots ?? 0
            awayValue = awayTeamStats.shots ?? 0
        case "Shots on Target":
            homeValue = homeTeamStats.shotsOnTarget ?? 0
            awayValue = awayTeamStats.shotsOnTarget ?? 0
        case "Fouls":
            homeValue = homeTeamStats.fouls ?? 0
            awayValue = awayTeamStats.fouls ?? 0
        case "Saves":
            homeValue = homeTeamStats.saves ?? 0
            awayValue = awayTeamStats.saves ?? 0
        case "Goal Kicks":
            homeValue = homeTeamStats.goalKicks ?? 0
            awayValue = awayTeamStats.goalKicks ?? 0
        case "Throw-ins":
            homeValue = homeTeamStats.throwIns ?? 0
            awayValue = awayTeamStats.throwIns ?? 0
        case "Yellow Cards":
            homeValue = homeTeamStats.yellowCard ?? 0
            awayValue = awayTeamStats.yellowCard ?? 0
        case "Red Cards":
            homeValue = homeTeamStats.redCard ?? 0
            awayValue = awayTeamStats.redCard ?? 0
        default:
            break
        }
        return (homeValue, awayValue)
    }
    
    func statToRecord(){
        for i in 0...(positionDefualts!.count - 1) {
            let switchState = myDefaults.bool(forKey: positionDefualts![i] + "State")

            if switchState == true{
                statsToRecord.append(positionDefualts![i])
            }
            print(positionDefualts![i], switchState)
        }
        print(statsToRecord.count)
    }
    
    @objc func changeValue(_ sender: UIStepper){
        impactGen.impactOccurred()
        
        var tag = sender.tag
        (sender.tag >= 100) ? (tag -= 100) : ()
        
        let indexPath = IndexPath(row: tag, section: 0)
        let cell = tableView.cellForRow(at: indexPath) as! gameStatsTableViewCell
        
        if sender.tag < 100{
            cell.lblHomeCount.text = String(Int(sender.value))
        }else{
            cell.lblAwayCount.text = String(Int(sender.value))
        }
        
        writeToVar(senderTag: sender.tag, value: Int(sender.value))
        
        updateProgress(row: tag)
        
    }
     
    func writeToVar(senderTag: Int, value: Int){
        var tag = senderTag
        (senderTag >= 100) ? (tag -= 100) : ()
        
        var stat:String!
        
        //because on free we return 1 extra cell for ad
        if premiumPurchase == false && adDidFail == false{
            stat = statsToRecord[tag - 1]
        }else{
            stat = statsToRecord[tag]
        }
        
        switch stat {
        case "Goals":
            if senderTag < 100{
                homeTeamStats.goals = value
                homeTeamStats.goalTimes.append(gameClock / 60 + 1)
                
                //checks what half the goal was scored
                if halfTrack == 1{
                    (homeTeamStats.goalsIn1 == nil) ? (homeTeamStats.goalsIn1 = 0) : ()
                    homeTeamStats.goalsIn1! += 1
                    
                }else if halfTrack == 2{
                    (homeTeamStats.goalsIn2 == nil) ? (homeTeamStats.goalsIn2 = 0) : ()
                    (homeTeamStats.goalsIn2!) += 1
                }
                
            }else{
                awayTeamStats.goals = value
                awayTeamStats.goalTimes.append(gameClock / 60 + 1)
                
                //checks what half the goal was scored
                if halfTrack == 1{
                    (awayTeamStats.goalsIn1 == nil) ? (awayTeamStats.goalsIn1 = 0) : ()
                    (awayTeamStats.goalsIn1!) += 1
                }else if halfTrack == 2{
                    (awayTeamStats.goalsIn2 == nil) ? (awayTeamStats.goalsIn2 = 0) : ()
                    (awayTeamStats.goalsIn2!) += 1
                }
            }
        case "Corners":
            if senderTag < 100{
                homeTeamStats.corners = value
                homeTeamStats.cornerTimes.append(gameClock / 60 + 1)
                
                if halfTrack == 1{
                    (homeTeamStats.cornersIn1 == nil) ? (homeTeamStats.cornersIn1 = 0) : ()
                    (homeTeamStats.cornersIn1!) += 1
                }else if halfTrack == 2{
                    (homeTeamStats.cornersIn1 == nil) ? (homeTeamStats.cornersIn1 = 0) : ()
                    (homeTeamStats.cornersIn2!) += 1
                }
                
            }else{
                awayTeamStats.corners = value
                awayTeamStats.cornerTimes.append(gameClock / 60 + 1)
                
                if halfTrack == 1{
                    (awayTeamStats.cornersIn1 == nil) ? (awayTeamStats.cornersIn1 = 0) : ()
                    (awayTeamStats.cornersIn1!) += 1
                }else if halfTrack == 2{
                    (awayTeamStats.cornersIn2 == nil) ? (awayTeamStats.cornersIn2 = 0) : ()
                    (awayTeamStats.cornersIn2!) += 1
                }
            }
        case "Offsides":
            if senderTag < 100{
                homeTeamStats.offsides = value
                homeTeamStats.offsideTimes.append(gameClock / 60 + 1)
                
                if halfTrack == 1{
                    (homeTeamStats.offsidesIn1 == nil) ? (homeTeamStats.offsidesIn1 = 0) : ()
                    (homeTeamStats.offsidesIn1!) += 1
                }else if halfTrack == 2{
                    (homeTeamStats.offsidesIn2 == nil) ? (homeTeamStats.offsidesIn2 = 0) : ()
                    (homeTeamStats.offsidesIn2!) += 1
                }
                
            }else{
                awayTeamStats.offsides = value
                awayTeamStats.offsideTimes.append(gameClock / 60 + 1)
                
                if halfTrack == 1{
                    (awayTeamStats.offsidesIn1 == nil) ? (awayTeamStats.offsidesIn1 = 0) : ()
                    (awayTeamStats.offsidesIn1!) += 1
                }else if halfTrack == 2{
                    (awayTeamStats.offsidesIn2 == nil) ? (awayTeamStats.offsidesIn2 = 0) : ()
                    (awayTeamStats.offsidesIn2!) += 1
                }
                
            }
        case "Shots":
            if senderTag < 100{
                homeTeamStats.shots = value
                homeTeamStats.shotTimes.append(gameClock / 60 + 1)
                
                if halfTrack == 1{
                    (homeTeamStats.shotsIn1 == nil) ? (homeTeamStats.shotsIn1 = 0) : ()
                    (homeTeamStats.shotsIn1!) += 1
                }else if halfTrack == 2{
                    (homeTeamStats.shotsIn2 == nil) ? (homeTeamStats.shotsIn2 = 0) : ()
                    (homeTeamStats.shotsIn2!) += 1
                }
                
            }else{
                awayTeamStats.shots = value
                awayTeamStats.shotTimes.append(gameClock / 60 + 1)
                
                if halfTrack == 1{
                    (awayTeamStats.shotsIn1 == nil) ? (awayTeamStats.shotsIn1 = 0) : ()
                    (awayTeamStats.shotsIn1!) += 1
                }else if halfTrack == 2{
                    (awayTeamStats.shotsIn2 == nil) ? (awayTeamStats.shotsIn2 = 0) : ()
                    (awayTeamStats.shotsIn2!) += 1
                }
                
            }
        case "Shots on Target":
            if senderTag < 100{
                homeTeamStats.shotsOnTarget = value
                homeTeamStats.shotsOnTargetTimes.append(gameClock / 60 + 1)
                
                if halfTrack == 1{
                    (homeTeamStats.shotsOnTargetIn1 == nil) ? (homeTeamStats.shotsOnTargetIn1 = 0) : ()
                    (homeTeamStats.shotsOnTargetIn1!) += 1
                }else if halfTrack == 2{
                    (homeTeamStats.shotsOnTargetIn2 == nil) ? (homeTeamStats.shotsOnTargetIn2 = 0) : ()
                    (homeTeamStats.shotsOnTargetIn2!) += 1
                }
                
            }else{
                awayTeamStats.shotsOnTarget = value
                awayTeamStats.shotsOnTargetTimes.append(gameClock / 60 + 1)
                
                if halfTrack == 1{
                    (awayTeamStats.shotsOnTargetIn1 == nil) ? (awayTeamStats.shotsOnTargetIn1 = 0) : ()
                    (awayTeamStats.shotsOnTargetIn1!) += 1
                }else if halfTrack == 2{
                    (awayTeamStats.shotsOnTargetIn2 == nil) ? (awayTeamStats.shotsOnTargetIn2 = 0) : ()
                    (awayTeamStats.shotsOnTargetIn2!) += 1
                }
            }
        case "Fouls":
            if senderTag < 100{
                homeTeamStats.fouls = value
                homeTeamStats.foulTimes.append(gameClock / 60 + 1)
                
                if halfTrack == 1{
                    (homeTeamStats.foulsIn1 == nil) ? (homeTeamStats.foulsIn1 = 0) : ()
                    (homeTeamStats.foulsIn1!) += 1
                }else if halfTrack == 2{
                    (homeTeamStats.foulsIn2 == nil) ? (homeTeamStats.foulsIn2 = 0) : ()
                    (homeTeamStats.foulsIn2!) += 1
                }
                
            }else{
                awayTeamStats.fouls = value
                awayTeamStats.foulTimes.append(gameClock / 60 + 1)
                
                if halfTrack == 1{
                    (awayTeamStats.foulsIn1 == nil) ? (awayTeamStats.foulsIn1 = 0) : ()
                    (awayTeamStats.foulsIn1!) += 1
                }else if halfTrack == 2{
                    (awayTeamStats.foulsIn2 == nil) ? (awayTeamStats.foulsIn2 = 0) : ()
                    (awayTeamStats.foulsIn2!) += 1
                }
                
            }
        case "Saves":
            if senderTag < 100{
                homeTeamStats.saves = value
                homeTeamStats.saveTimes.append(gameClock / 60 + 1)
                
                if halfTrack == 1{
                    (homeTeamStats.savesIn1 == nil) ? (homeTeamStats.savesIn1 = 0) : ()
                    (homeTeamStats.savesIn1!) += 1
                }else if halfTrack == 2{
                    (homeTeamStats.savesIn2 == nil) ? (homeTeamStats.savesIn2 = 0) : ()
                    (homeTeamStats.savesIn2!) += 1
                }
                
            }else{
                awayTeamStats.saves = value
                awayTeamStats.saveTimes.append(gameClock / 60 + 1)
                
                if halfTrack == 1{
                    (awayTeamStats.savesIn1 == nil) ? (awayTeamStats.savesIn1 = 0) : ()
                    (awayTeamStats.savesIn1!) += 1
                }else if halfTrack == 2{
                    (awayTeamStats.savesIn2 == nil) ? (awayTeamStats.savesIn2 = 0) : ()
                    (awayTeamStats.savesIn2!) += 1
                }
                
            }
        case "Goal Kicks":
            if senderTag < 100{
                homeTeamStats.goalKicks = value
                homeTeamStats.goalKickTimes.append(gameClock / 60 + 1)
                
                if halfTrack == 1{
                    (homeTeamStats.goalKicksIn1 == nil) ? (homeTeamStats.goalKicksIn1 = 0) : ()
                    (homeTeamStats.goalKicksIn1!) += 1
                }else if halfTrack == 2{
                    (homeTeamStats.goalKicksIn2 == nil) ? (homeTeamStats.goalKicksIn2 = 0) : ()
                    (homeTeamStats.goalKicksIn2!) += 1
                }
                
            }else{
                awayTeamStats.goalKicks = value
                awayTeamStats.goalKickTimes.append(gameClock / 60 + 1)
                
                if halfTrack == 1{
                    (awayTeamStats.goalKicksIn1 == nil) ? (awayTeamStats.goalKicksIn1 = 0) : ()
                    (awayTeamStats.goalKicksIn1!) += 1
                }else if halfTrack == 2{
                    (awayTeamStats.goalKicksIn2 == nil) ? (awayTeamStats.goalKicksIn2 = 0) : ()
                    (awayTeamStats.goalKicksIn2!) += 1
                }
                
            }
        case "Throw-ins":
            if senderTag < 100{
                homeTeamStats.throwIns = value
                homeTeamStats.throwInTimes.append(gameClock / 60 + 1)
                
                if halfTrack == 1{
                    (homeTeamStats.throwInsIn1 == nil) ? (homeTeamStats.throwInsIn1 = 0) : ()
                    (homeTeamStats.throwInsIn1!) += 1
                }else if halfTrack == 2{
                    (homeTeamStats.throwInsIn2 == nil) ? (homeTeamStats.throwInsIn2 = 0) : ()
                    (homeTeamStats.throwInsIn2!) += 1
                }
                
            }else{
                awayTeamStats.throwIns = value
                awayTeamStats.throwInTimes.append(gameClock / 60 + 1)
                
                if halfTrack == 1{
                    (awayTeamStats.throwInsIn1 == nil) ? (awayTeamStats.throwInsIn1 = 0) : ()
                    (awayTeamStats.throwInsIn1!) += 1
                }else if halfTrack == 2{
                    (awayTeamStats.throwInsIn2 == nil) ? (awayTeamStats.throwInsIn2 = 0) : ()
                    (awayTeamStats.throwInsIn2!) += 1
                }
                
            }
        case "Yellow Cards":
            if senderTag < 100{
                homeTeamStats.yellowCard = value
                homeTeamStats.yellowCardTimes.append(gameClock / 60 + 1)
                
                if halfTrack == 1{
                    (homeTeamStats.yellowCardIn1 == nil) ? (homeTeamStats.yellowCardIn1 = 0) : ()
                    (homeTeamStats.yellowCardIn1!) += 1
                }else if halfTrack == 2{
                    (homeTeamStats.yellowCardIn2 == nil) ? (homeTeamStats.yellowCardIn2 = 0) : ()
                    (homeTeamStats.yellowCardIn2!) += 1
                }
                
            }else{
                awayTeamStats.yellowCard = value
                awayTeamStats.yellowCardTimes.append(gameClock / 60 + 1)
                
                if halfTrack == 1{
                    (awayTeamStats.yellowCardIn1 == nil) ? (awayTeamStats.yellowCardIn1 = 0) : ()
                    (awayTeamStats.yellowCardIn1!) += 1
                }else if halfTrack == 2{
                    (awayTeamStats.yellowCardIn2 == nil) ? (awayTeamStats.yellowCardIn2 = 0) : ()
                    (awayTeamStats.yellowCardIn2!) += 1
                }
                
            }
        case "Red Cards":
            if senderTag < 100{
                homeTeamStats.redCard = value
                homeTeamStats.redCardTimes.append(gameClock / 60 + 1)
                
                if halfTrack == 1{
                    (homeTeamStats.redCardIn1 == nil) ? (homeTeamStats.redCardIn1 = 0) : ()
                    (homeTeamStats.redCardIn1!) += 1
                }else if halfTrack == 2{
                    
                    (homeTeamStats.redCardIn2 == nil) ? (homeTeamStats.redCardIn2 = 0) : ()
                    (homeTeamStats.redCardIn2!) += 1
                }
                
            }else{
                awayTeamStats.redCard = value
                awayTeamStats.redCardTimes.append(gameClock / 60 + 1)
                
                if halfTrack == 1{
                    (awayTeamStats.redCardIn1 == nil) ? (awayTeamStats.redCardIn1 = 0) : ()
                    (awayTeamStats.redCardIn1!) += 1
                }else if halfTrack == 2{
                    (awayTeamStats.redCardIn2 == nil) ? (awayTeamStats.redCardIn2 = 0) : ()
                    (awayTeamStats.redCardIn2!) += 1
                }
                
            }
        default:
            break
        }
        print(stat, value)
    }
    func updateProgress(row: Int){
        let indexRow = row
        
        let indexPath = IndexPath(row: indexRow, section: 0)
        let cell = tableView.cellForRow(at: indexPath) as! gameStatsTableViewCell
        
        var stat:String!
        
        //because on free we return 1 extra cell for ad
        if premiumPurchase == false && adDidFail == false{
            stat = statsToRecord[indexRow - 1]
        }else{
            stat = statsToRecord[indexRow]
        }
        var progress = Progress(totalUnitCount: 0)
        
        switch stat {
        case "Goals":
            totalNum = (homeTeamStats.goals ?? 0) + (awayTeamStats.goals ?? 0)
            progress = Progress(totalUnitCount: Int64(totalNum))
            progress.completedUnitCount = Int64(homeTeamStats.goals ?? 0)
            
            //if goals both 0 prg bar is half
            if homeTeamStats.goals == 0 && awayTeamStats.goals == 0 {
                cell.progressBar.setProgress(Float(0.5), animated: true)
            }else{
                cell.progressBar.setProgress(Float(progress.fractionCompleted), animated: true)
            }
        case "Corners":
            totalNum = (homeTeamStats.corners ?? 0) + (awayTeamStats.corners ?? 0)
            progress = Progress(totalUnitCount: Int64(totalNum))
            progress.completedUnitCount = Int64(homeTeamStats.corners ?? 0)
            if homeTeamStats.corners == 0 && awayTeamStats.corners == 0 {
                cell.progressBar.setProgress(Float(0.5), animated: true)
            }else{
                cell.progressBar.setProgress(Float(progress.fractionCompleted), animated: true)
            }
            
        case "Offsides":
            totalNum = (homeTeamStats.offsides ?? 0) + (awayTeamStats.offsides ?? 0)
            progress = Progress(totalUnitCount: Int64(totalNum))
            progress.completedUnitCount = Int64(homeTeamStats.offsides ?? 0)
            if homeTeamStats.offsides == 0 && awayTeamStats.offsides == 0 {
                cell.progressBar.setProgress(Float(0.5), animated: true)
            }else{
                cell.progressBar.setProgress(Float(progress.fractionCompleted), animated: true)
            }
            
        case "Shots":
            totalNum = (homeTeamStats.shots ?? 0) + (awayTeamStats.shots ?? 0)
            progress = Progress(totalUnitCount: Int64(totalNum))
            progress.completedUnitCount = Int64(homeTeamStats.shots ?? 0)
            if homeTeamStats.shots == 0 && awayTeamStats.shots == 0 {
                cell.progressBar.setProgress(Float(0.5), animated: true)
            }else{
                cell.progressBar.setProgress(Float(progress.fractionCompleted), animated: true)
            }
            
        case "Shots on Target":
            totalNum = (homeTeamStats.shotsOnTarget ?? 0) + (awayTeamStats.shotsOnTarget ?? 0)
            progress = Progress(totalUnitCount: Int64(totalNum))
            progress.completedUnitCount = Int64(homeTeamStats.shotsOnTarget ?? 0)
            if homeTeamStats.shotsOnTarget == 0 && awayTeamStats.shotsOnTarget == 0 {
                cell.progressBar.setProgress(Float(0.5), animated: true)
            }else{
                cell.progressBar.setProgress(Float(progress.fractionCompleted), animated: true)
            }
            
        case "Fouls":
            totalNum = (homeTeamStats.fouls ?? 0) + (awayTeamStats.fouls ?? 0)
            progress = Progress(totalUnitCount: Int64(totalNum))
            progress.completedUnitCount = Int64(homeTeamStats.fouls ?? 0)
            if homeTeamStats.fouls == 0 && awayTeamStats.fouls == 0 {
                cell.progressBar.setProgress(Float(0.5), animated: true)
            }else{
                cell.progressBar.setProgress(Float(progress.fractionCompleted), animated: true)
            }
            
        case "Saves":
            totalNum = (homeTeamStats.saves ?? 0) + (awayTeamStats.saves ?? 0)
            progress = Progress(totalUnitCount: Int64(totalNum))
            progress.completedUnitCount = Int64(homeTeamStats.saves ?? 0)
            if homeTeamStats.saves == 0 && awayTeamStats.saves == 0 {
                cell.progressBar.setProgress(Float(0.5), animated: true)
            }else{
                cell.progressBar.setProgress(Float(progress.fractionCompleted), animated: true)
            }
            
        case "Goal Kicks":
            totalNum = (homeTeamStats.goalKicks ?? 0) + (awayTeamStats.goalKicks ?? 0)
            progress = Progress(totalUnitCount: Int64(totalNum))
            progress.completedUnitCount = Int64(homeTeamStats.goalKicks ?? 0)
            if homeTeamStats.goalKicks == 0 && awayTeamStats.goalKicks == 0 {
                cell.progressBar.setProgress(Float(0.5), animated: true)
            }else{
                cell.progressBar.setProgress(Float(progress.fractionCompleted), animated: true)
            }
            
        case "Throw-ins":
            totalNum = (homeTeamStats.throwIns ?? 0) + (awayTeamStats.throwIns ?? 0)
            progress = Progress(totalUnitCount: Int64(totalNum))
            progress.completedUnitCount = Int64(homeTeamStats.throwIns ?? 0)
            if homeTeamStats.throwIns == 0 && awayTeamStats.throwIns == 0 {
                cell.progressBar.setProgress(Float(0.5), animated: true)
            }else{
                cell.progressBar.setProgress(Float(progress.fractionCompleted), animated: true)
            }
            
        case "Yellow Cards":
            totalNum = (homeTeamStats.yellowCard ?? 0) + (awayTeamStats.yellowCard ?? 0)
            progress = Progress(totalUnitCount: Int64(totalNum))
            progress.completedUnitCount = Int64(homeTeamStats.yellowCard ?? 0)
            if homeTeamStats.yellowCard == 0 && awayTeamStats.yellowCard == 0 {
                cell.progressBar.setProgress(Float(0.5), animated: true)
            }else{
                cell.progressBar.setProgress(Float(progress.fractionCompleted), animated: true)
            }
            
        case "Red Cards":
            totalNum = (homeTeamStats.redCard ?? 0) + (awayTeamStats.redCard ?? 0)
            progress = Progress(totalUnitCount: Int64(totalNum))
            progress.completedUnitCount = Int64(homeTeamStats.redCard ?? 0)
            if homeTeamStats.redCard == 0 && awayTeamStats.redCard == 0 {
                cell.progressBar.setProgress(Float(0.5), animated: true)
            }else{
                cell.progressBar.setProgress(Float(progress.fractionCompleted), animated: true)
            }
        default:
            break
        }
    }
    
    func endHalfButton(){
        
        txtEndHalfButton.isUserInteractionEnabled = true
        txtEndHalfButton.layer.cornerRadius = 10
        txtEndHalfButton.clipsToBounds = true
        txtEndHalfButton.backgroundColor = .red
        txtEndHalfButton.tintColor = .white
        
        switch halfTrack {
        case 1:
            txtEndHalfButton.setTitle("End Half", for: .normal)
        case 2:
            if homeTeamStats.goals == awayTeamStats.goals{
                txtEndHalfButton.setTitle("End Half", for: .normal)
            }else{
                txtEndHalfButton.setTitle("End Game", for: .normal)
            }
        case 3:
            txtEndHalfButton.setTitle("End Half", for: .normal)
        case 4:
            if homeTeamStats.goals == awayTeamStats.goals{
                txtEndHalfButton.setTitle("End Half", for: .normal)
            }else{
                txtEndHalfButton.setTitle("End Game", for: .normal)
            }
        default:
            break
        }
    }
    
    func startHalfButton(){
        
        timerCompleted = false
        halfCompleted = true
        clock.invalidate()
        
        switch halfTrack {
        case 1:
            
            txtEndHalfButton.setTitle("Start Half", for: .normal)
            gameTimer = gameInfo.halfLength
            gameClock = gameInfo.halfLength
            (premiumPurchase == false) ? (showAd()) : ()
        case 2:
            
            if homeTeamStats.goals == awayTeamStats.goals{
                extraTimeAlert()
            }else{
                //removes button
                txtEndHalfButton.setTitle("", for: .normal)
                txtEndHalfButton.tintColor = .clear
                txtEndHalfButton.backgroundColor = .clear
                txtEndHalfButton.isUserInteractionEnabled = false
                
                performSegue(withIdentifier: "gameEnded", sender: self)
            }
        case 3:
            txtEndHalfButton.setTitle("Start Half", for: .normal)
            gameTimer = gameInfo.extraTime
            gameClock = (gameInfo.halfLength * 2) + gameInfo.extraTime
            (premiumPurchase == false) ? (showAd()) : ()
        case 4:
            if homeTeamStats.goals == awayTeamStats.goals{
                txtEndHalfButton.setTitle("Shoot Out", for: .normal)
            }else{
                //removes button
                txtEndHalfButton.setTitle("", for: .normal)
                txtEndHalfButton.tintColor = .clear
                txtEndHalfButton.backgroundColor = .clear
                txtEndHalfButton.isUserInteractionEnabled = false
                
                performSegue(withIdentifier: "gameEnded", sender: self)
            }
        default:
            break
        }
        
        print(halfTrack)
        txtEndHalfButton.layer.cornerRadius = 10
        txtEndHalfButton.clipsToBounds = true
        txtEndHalfButton.backgroundColor = .systemGreen
        
        if stopwatchSelected == false{
            lblTimer.text = timeString(time: TimeInterval(gameTimer))
        }else{
            lblTimer.text = timeString(time: TimeInterval(gameClock))
        }
        
        txtEndHalfButton.isUserInteractionEnabled = true
    }
    func resetStats(){
        homeTeamStats.goalTimes = []
        homeTeamStats.cornerTimes = []
        homeTeamStats.offsideTimes = []
        homeTeamStats.shotTimes = []
        homeTeamStats.shotsOnTargetTimes = []
        homeTeamStats.foulTimes = []
        homeTeamStats.saveTimes = []
        homeTeamStats.throwInTimes = []
        homeTeamStats.goalKickTimes = []
        homeTeamStats.yellowCardTimes = []
        homeTeamStats.redCardTimes = []
        
        awayTeamStats.goalTimes = []
        awayTeamStats.cornerTimes = []
        awayTeamStats.offsideTimes = []
        awayTeamStats.shotTimes = []
        awayTeamStats.shotsOnTargetTimes = []
        awayTeamStats.foulTimes = []
        awayTeamStats.saveTimes = []
        awayTeamStats.throwInTimes = []
        awayTeamStats.goalKickTimes = []
        awayTeamStats.yellowCardTimes = []
        awayTeamStats.redCardTimes = []
        
        homeTeamStats.goals = 0
        homeTeamStats.corners = 0
        homeTeamStats.offsides = 0
        homeTeamStats.shots = 0
        homeTeamStats.shotsOnTarget = 0
        homeTeamStats.fouls = 0
        homeTeamStats.saves = 0
        homeTeamStats.goalKicks = 0
        homeTeamStats.throwIns = 0
        homeTeamStats.yellowCard = 0
        homeTeamStats.redCard = 0
        
        awayTeamStats.goals = 0
        awayTeamStats.corners = 0
        awayTeamStats.offsides = 0
        awayTeamStats.shots = 0
        awayTeamStats.shotsOnTarget = 0
        awayTeamStats.fouls = 0
        awayTeamStats.saves = 0
        awayTeamStats.goalKicks = 0
        awayTeamStats.throwIns = 0
        awayTeamStats.yellowCard = 0
        awayTeamStats.redCard = 0
        
        homeTeamStats.goalsIn1 = 0
        homeTeamStats.goalsIn2 = 0
        homeTeamStats.cornersIn1 = 0
        homeTeamStats.cornersIn2 = 0
        homeTeamStats.offsidesIn1 = 0
        homeTeamStats.offsidesIn2 = 0
        homeTeamStats.shotsIn1 = 0
        homeTeamStats.shotsIn2 = 0
        homeTeamStats.shotsOnTargetIn1 = 0
        homeTeamStats.shotsOnTargetIn2 = 0
        homeTeamStats.foulsIn1 = 0
        homeTeamStats.foulsIn2 = 0
        homeTeamStats.savesIn1 = 0
        homeTeamStats.savesIn2 = 0
        homeTeamStats.goalKicksIn1 = 0
        homeTeamStats.goalKicksIn2 = 0
        homeTeamStats.throwInsIn1 = 0
        homeTeamStats.throwInsIn2 = 0
        homeTeamStats.yellowCardIn1 = 0
        homeTeamStats.yellowCardIn2 = 0
        homeTeamStats.redCardIn1 = 0
        homeTeamStats.redCardIn2 = 0
        
        awayTeamStats.goalsIn1 = 0
        awayTeamStats.goalsIn2 = 0
        awayTeamStats.cornersIn1 = 0
        awayTeamStats.cornersIn2 = 0
        awayTeamStats.offsidesIn1 = 0
        awayTeamStats.offsidesIn2 = 0
        awayTeamStats.shotsIn1 = 0
        awayTeamStats.shotsIn2 = 0
        awayTeamStats.shotsOnTargetIn1 = 0
        awayTeamStats.shotsOnTargetIn2 = 0
        awayTeamStats.foulsIn1 = 0
        awayTeamStats.foulsIn2 = 0
        awayTeamStats.savesIn1 = 0
        awayTeamStats.savesIn2 = 0
        awayTeamStats.goalKicksIn1 = 0
        awayTeamStats.goalKicksIn2 = 0
        awayTeamStats.throwInsIn1 = 0
        awayTeamStats.throwInsIn2 = 0
        awayTeamStats.yellowCardIn1 = 0
        awayTeamStats.yellowCardIn2 = 0
        awayTeamStats.redCardIn1 = 0
        awayTeamStats.redCardIn2 = 0
    }
    // MARK:- timer
    func setTimer(){
        clock = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(Action), userInfo: nil, repeats: true)
    }
    
    //format timer to string
    func timeString(time:TimeInterval) -> String {
        if stopwatchSelected == false{
            if timerCompleted == false{
                let minutes = Int(time) / 60
                let seconds = Int(time) % 60
                return String(format:"%02i:%02i",minutes, seconds)
            }else{
                let minutes = Int(time) / 60
                let seconds = Int(time) % 60
                let formatTimer = String(format:"%02i:%02i",minutes, seconds)
                return String("-" + formatTimer)
            }
        }else{
            let minutes = Int(time) / 60
            let seconds = Int(time) % 60
            return String(format:"%02i:%02i",minutes, seconds)
        }
    }
    //control timer and display
    @objc func Action(){
        
        if gameTimer > 0 && timerCompleted == false{
            gameTimer -= 1
            halfCompleted = false
            
        }else{
            gameTimer += 1
            timerCompleted = true
        }
        gameClock += 1
        
        //checks mode fo game clock
        if stopwatchSelected == false{
            lblTimer.text = timeString(time: TimeInterval(gameTimer))
        }else{
            lblTimer.text = timeString(time: TimeInterval(gameClock))
        }
        //displayes red end button
        if timerCompleted == true && halfCompleted == false{
            endHalfButton()
        }
    }
    //MARK:- Alerts
    func extraTimeAlert(){
        let alert = UIAlertController(title: "Extra Time?", message: "Will extra time be played?", preferredStyle: .alert)
            
            let endGameButton = UIAlertAction(title: "Yes", style: .default) { (action) in
                
                self.setLength()
                self.gameClock = gameInfo.halfLength * 2
                
                self.txtEndHalfButton.setTitle("Start", for: .normal)
            }
            let cancelButton = UIAlertAction(title: "No", style: .default) { (action) in
                self.txtEndHalfButton.setTitle("", for: .normal)
                self.performSegue(withIdentifier: "gameEnded", sender: self)
            }
            
            alert.addAction(endGameButton)
            alert.addAction(cancelButton)
            
            self.present(alert, animated: true, completion: nil)
        }
        

    func setLength() {
        let alert = UIAlertController(title: "Set Length", message: "Set the half length of extra time (mins)", preferredStyle: .alert)
        
        alert.addTextField(configurationHandler: { textField in
            textField.keyboardType = .numberPad
        })
        
        alert.textFields![0].text = "15"
        let textField = alert.textFields![0]
        
        let confirm = UIAlertAction(title: "Confirm", style: .default) { (action) in
            
            let number = String(textField.text!)
            
            gameInfo.extraTime = (Int(number) ?? 15) * 60
            self.gameTimer = gameInfo.extraTime
            
            if stopwatchSelected == false{
                self.lblTimer.text = self.timeString(time: TimeInterval(self.gameTimer))
            }else{
                self.lblTimer.text = self.timeString(time: TimeInterval(self.gameClock))
            }
        }
        alert.addAction(confirm)
        self.present(alert, animated: true, completion: nil)
    }
    func showAd(){
        if self.interstitial.isReady {
            self.interstitial.present(fromRootViewController: self)
        } else {
          print("Ad wasn't ready")
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        let items =  self.tabBarController?.tabBar.items
        let itemToDisable = items![0]
        itemToDisable.isEnabled = false
    }
    override func viewWillDisappear(_ animated: Bool) {
        let items =  self.tabBarController?.tabBar.items
        let itemToDisable = items![0]
        itemToDisable.isEnabled = true
    }
}


// MARK:- Advertisment control
extension gameViewController:GADBannerViewDelegate{
    func adViewDidReceiveAd(_ bannerView: GADBannerView) {
        print("revieved ad")
    }

    func adView(_ bannerView: GADBannerView, didFailToReceiveAdWithError error: GADRequestError) {
        //if ad fails to load, remove space from top of tableView
        bannerView.removeFromSuperview()
        adDidFail = true
        tableView.reloadData()
    }

}
extension gameViewController:GADInterstitialDelegate{
    func interstitialDidReceiveAd(_ ad: GADInterstitial) {
      print("interstitialDidReceiveAd")
    }
    func interstitialWillPresentScreen(_ ad: GADInterstitial) {
        print("Ad presented")
    }

    func interstitialDidDismissScreen(_ ad: GADInterstitial) {
        // Send another GADRequest here
        print("Ad dismissed")
    }
}
