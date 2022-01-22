//
//  detailedStatsViewController.swift
//  FootballStats2
//
//  Created by Thomas Karbowiak on 9/10/20.
//  Copyright © 2020 Thomas Karbowiak. All rights reserved.
//

import UIKit
import CoreData

struct statsInfo{
    
    var names = [String]()
    var lowerCaseNames = [String]()
    var gameID = [Int]()
    
    var totalStats:[String:Int] = ["goals": 0,
                              "corners": 0,
                              "offsides": 0,
                              "shots": 0 ,
                              "shotsOnTarget" : 0,
                              "fouls" : 0,
                              "saves" : 0,
                              "goalKicks" : 0,
                              "throwIns" : 0,
                              "yellowCards" : 0,
                              "redCards" : 0,
    ]
    
    var goalsIn1:Double = 0
    var goalsIn2:Double = 0
    var cornersIn1:Double = 0
    var cornersIn2:Double = 0
    var offsidesIn1:Double = 0
    var offsidesIn2:Double = 0
    var shotsIn1:Double = 0
    var shotsIn2:Double = 0
    var shotsOnTargetIn1:Double = 0
    var shotsOnTargetIn2:Double = 0
    var foulsIn1:Double = 0
    var foulsIn2:Double = 0
    var savesIn1:Double = 0
    var savesIn2:Double = 0
    var goalKicksIn1:Double = 0
    var goalKicksIn2:Double = 0
    var throwInsIn1:Double = 0
    var throwInsIn2:Double = 0
    var yellowCardsIn1:Double = 0
    var yellowCardsIn2:Double = 0
    var redCardsIn1:Double = 0
    var redCardsIn2:Double = 0
    
    var halfLength = [Int]()
}
class detailedStatsViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, UITableViewDelegate, UITableViewDataSource {
    
    
    @IBOutlet weak var teamPicker: UIPickerView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var numPerSeg: UISegmentedControl!
    @IBOutlet weak var gameRangeSeg: UISegmentedControl!
    
    var homeItems:[HomeTeam]?
    var awayItems:[AwayTeam]?
    var infoItems:[GameInfo]?
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    //getting data
    var data = statsInfo()
    
    var homeNames = [String]()
    var awayNames = [String]()
    
    var nameSelected:String!
    var rowSelected:Int!
    
    var displayPercentage = true
    var gameRange:Int?
    
    var oldGameAlertShown = false
    
    //for checking duplicates
    let coreStats = ["goals", "corners", "offsides", "shots", "shotsOnTarget", "fouls", "saves", "goalKicks", "throwIns", "yellowCards", "redCards"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        self.teamPicker.delegate = self
        self.teamPicker.dataSource = self
        
        
        let nib = UINib(nibName: "detailedStatsTableViewCell", bundle: nil)
        
        tableView.register(nib, forCellReuseIdentifier: "detailedStatsTableViewCell")
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.allowsSelection = false
        
        getNames()
        
        //checks to see if games exist
        if data.names.count != 0 {
            gameRange = 1
            getData(row: 0)
            rowSelected = 0
            getTeamStats()
            
        }else{
            teamPicker.isUserInteractionEnabled = false
        }
        
    }
    @IBAction func didChangeViewSeg(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            displayPercentage = true
        case 1:
            displayPercentage = false
        default:
            break
        }
        tableView.reloadData()
    }
    
    @IBAction func didChangeGameRangeSeg(_ sender: UISegmentedControl) {
        
        if data.gameID.count != 0 {
            switch sender.selectedSegmentIndex {
                case 0:
                    gameRange = 1
                case 1:
                    gameRange = 2
                case 2:
                    gameRange = 5
                case 3:
                    gameRange = 8
                case 4:
                    // assigned value 0 as indictor to display all
                    gameRange = data.gameID.count
                default:
                    break
                }
            clearStatsDic()
            getData(row: rowSelected)
            getTeamStats()
            tableView.reloadData()
        }
    }
    //MARK: - getting data
    func getNames(){
        
        let requestHome = HomeTeam.fetchRequest() as NSFetchRequest<HomeTeam>
        let requestAway = AwayTeam.fetchRequest() as NSFetchRequest<AwayTeam>
        let requestInfo = GameInfo.fetchRequest() as NSFetchRequest<GameInfo>
        
        let sort = NSSortDescriptor(key: "gameID", ascending: false)
        
        requestHome.sortDescriptors = [sort]
        requestAway.sortDescriptors = [sort]
        requestInfo.sortDescriptors = [sort]
        
        do{
            
            homeItems = try context.fetch(requestHome)
            awayItems = try context.fetch(requestAway)
            infoItems = try context.fetch(requestInfo)
                    
        }catch{
            print("there was an error",error)
        }
        
        
        let items = homeItems!.count as Int
        if items != 0 {
            for i in 0...items - 1{
                
                let homeTeam = homeItems![i]
                let awayTeam = awayItems![i]
                
                homeNames.append(homeTeam.name!)
                awayNames.append(awayTeam.name!)
                
                for i in 0...homeNames.count - 1{
                    if (data.lowerCaseNames.contains(homeNames[i].lowercased())) == false{
                        print("false")
                        data.names.append(homeNames[i])
                        data.lowerCaseNames.append(homeNames[i].lowercased())
                    }
                    
                }
                for i in 0...awayNames.count - 1{
                    
                    if (data.lowerCaseNames.contains(awayNames[i].lowercased())) == false{
                        print("false")
                        data.names.append(awayNames[i])
                        data.lowerCaseNames.append(awayNames[i].lowercased())
                    }
                }
            }
        }
        teamPicker.reloadAllComponents()
    }
    
    func getData(row: Int){
        nameSelected = data.names[row]
        print(data.names[row])
        
        let requestHome = HomeTeam.fetchRequest() as NSFetchRequest<HomeTeam>
        let requestAway = AwayTeam.fetchRequest() as NSFetchRequest<AwayTeam>
        let requestInfo = GameInfo.fetchRequest() as NSFetchRequest<GameInfo>
        
        let filter = NSPredicate(format: "name like[cd] %@", data.names[row])

        //checks name on both sides - home and away
        requestHome.predicate = filter
        requestAway.predicate = filter
        
        let sort = NSSortDescriptor(key: "dateAsDate", ascending: false)
        requestHome.fetchLimit = gameRange!
        requestAway.fetchLimit = gameRange!
        requestHome.sortDescriptors = [sort]
        requestAway.sortDescriptors = [sort]
        
        do{
            
            homeItems = try context.fetch(requestHome)
            awayItems = try context.fetch(requestAway)
                    
        }catch{
            print("there was an error",error)
        }
        
        //adjusts for team name being either an away team or a home team
        while homeItems!.count + awayItems!.count > gameRange! {
            let lastHome = homeItems![homeItems!.count - 1]
            let lastAway = awayItems![awayItems!.count - 1]
            
            if lastHome.gameID > lastAway.gameID {
                awayItems!.remove(at: awayItems!.count - 1)
            }else if lastHome.gameID < lastAway.gameID{
                homeItems!.remove(at: homeItems!.count - 1)
            }
        }
        //adding total amount of stats for given name
        if homeItems!.count > 0{
            for i in 0...homeItems!.count - 1{
                let game = homeItems![i]
                
                if Int(game.gameVersion) >= gameVersion {
                    data.totalStats["goals"] = (data.totalStats["goals"]! + Int(game.goals!)!)
                    data.totalStats["corners"] = (data.totalStats["corners"]! + Int(game.corners!)!)
                    data.totalStats["offsides"] = (data.totalStats["offsides"]! + Int(game.offsides!)!)
                    data.totalStats["shots"] = (data.totalStats["shots"]! + Int(game.shots!)!)
                    data.totalStats["shotsOnTarget"] = (data.totalStats["shotsOnTarget"]! + Int(game.shotsOnTarget!)!)
                    data.totalStats["fouls"] = (data.totalStats["fouls"]! + Int(game.fouls!)!)
                    data.totalStats["saves"] = (data.totalStats["saves"]! + Int(game.saves!)!)
                    data.totalStats["goalKicks"] = (data.totalStats["goalKicks"]! + Int(game.goalKicks!)!)
                    data.totalStats["throwIns"] = (data.totalStats["throwIns"]! + Int(game.throwIns!)!)
                    data.totalStats["yellowCards"] = (data.totalStats["yellowCards"]! + Int(game.yellowCards!)!)
                    data.totalStats["redCards"] = (data.totalStats["redCards"]! + Int(game.redCards!)!)
                    
                    data.gameID.append(Int(game.gameID))
                }else{
                    // notifies user that old versions are not compatible with current  version
                    if neverShowOldGameAlert == false && oldGameAlertShown == false{
                        oldGameAlert()
                    }
                    oldGameAlertShown = true
                }
            }
        }
        
        if awayItems!.count > 0 {
            for i in 0...awayItems!.count - 1{
                
                let game = awayItems![i]
                if Int(game.gameVersion) >= gameVersion{
                    data.totalStats["goals"] = (data.totalStats["goals"]! + Int(game.goals!)!)
                    data.totalStats["corners"] = (data.totalStats["corners"]! + Int(game.corners!)!)
                    data.totalStats["offsides"] = (data.totalStats["offsides"]! + Int(game.offsides!)!)
                    data.totalStats["shots"] = (data.totalStats["shots"]! + Int(game.shots!)!)
                    data.totalStats["shotsOnTarget"] = (data.totalStats["shotsOnTarget"]! + Int(game.shotsOnTarget!)!)
                    data.totalStats["fouls"] = (data.totalStats["fouls"]! + Int(game.fouls!)!)
                    data.totalStats["saves"] = (data.totalStats["saves"]! + Int(game.saves!)!)
                    data.totalStats["goalKicks"] = (data.totalStats["goalKicks"]! + Int(game.goalKicks!)!)
                    data.totalStats["throwIns"] = (data.totalStats["throwIns"]! + Int(game.throwIns!)!)
                    data.totalStats["yellowCards"] = (data.totalStats["yellowCards"]! + Int(game.yellowCards!)!)
                    data.totalStats["redCards"] = (data.totalStats["redCards"]! + Int(game.redCards!)!)
                    
                    data.gameID.append(Int(game.gameID))
                }else{
                    // notifies user that old versions are not compatible with current  version
                    if neverShowOldGameAlert == false && oldGameAlertShown == false{
                        oldGameAlert()
                    }
                    oldGameAlertShown = true
                }
            }
        }
        print(data.totalStats)
    }
    func getHalfData(stat: String, home: Bool){

        if home == true{

            let game = homeItems![0]
            switch stat {
            case "goals":
                data.goalsIn1 += Double(game.goalsIn1)
                data.goalsIn2 += Double(game.goalsIn2)
            case "corners":
                data.cornersIn1 += Double(game.cornersIn1)
                data.cornersIn2 += Double(game.cornersIn2)
            case "offsides":
                data.offsidesIn1 += Double(game.offsidesIn1)
                data.offsidesIn2 += Double(game.offsidesIn2)
            case "shots":
                data.shotsIn1 += Double(game.shotsIn1)
                data.shotsIn2 += Double(game.shotsIn2)
            case "shotsOntarget":
                data.shotsOnTargetIn1 += Double(game.shotsOnTargetIn1)
                data.shotsOnTargetIn2 += Double(game.shotsOnTargetIn2)
            case "fouls":
                data.foulsIn1 += Double(game.foulsIn1)
                data.foulsIn2 += Double(game.foulsIn2)
            case "saves":
                data.savesIn1 += Double(game.savesIn2)
                data.savesIn2 += Double(game.goalsIn2)
            case "goalKicks":
                data.goalKicksIn1 += Double(game.goalKicksIn1)
                data.goalKicksIn2 += Double(game.goalKicksIn2)
            case "throwIns":
                data.throwInsIn1 += Double(game.throwInsIn1)
                data.throwInsIn2 += Double(game.throwInsIn2)
            case "yellowCards":
                data.yellowCardsIn1 += Double(game.yellowCardsIn1)
                data.yellowCardsIn2 += Double(game.yellowCardsIn2)
            case "redCards":
                data.redCardsIn1 += Double(game.redCardsIn1)
                data.redCardsIn2 += Double(game.redCardsIn2)
            default:
                break
            }
        }else{

            let game = awayItems![0]
            switch stat {
            case "goals":
                data.goalsIn1 += Double(game.goalsIn1)
                data.goalsIn2 += Double(game.goalsIn2)
            case "corners":
                data.cornersIn1 += Double(game.cornersIn1)
                data.cornersIn2 += Double(game.cornersIn2)
            case "offsides":
                data.offsidesIn1 += Double(game.offsidesIn1)
                data.offsidesIn2 += Double(game.offsidesIn2)
            case "shots":
                data.shotsIn1 += Double(game.shotsIn1)
                data.shotsIn2 += Double(game.shotsIn2)
            case "shotsOntarget":
                data.shotsOnTargetIn1 += Double(game.shotsOnTargetIn1)
                data.shotsOnTargetIn2 += Double(game.shotsOnTargetIn2)
            case "fouls":
                data.foulsIn1 += Double(game.foulsIn1)
                data.foulsIn2 += Double(game.foulsIn2)
            case "saves":
                data.savesIn1 += Double(game.savesIn2)
                data.savesIn2 += Double(game.goalsIn2)
            case "goalKicks":
                data.goalKicksIn1 += Double(game.goalKicksIn1)
                data.goalKicksIn2 += Double(game.goalKicksIn2)
            case "throwIns":
                data.throwInsIn1 += Double(game.throwInsIn1)
                data.throwInsIn2 += Double(game.throwInsIn2)
            case "yellowCards":
                data.yellowCardsIn1 += Double(game.yellowCardsIn1)
                data.yellowCardsIn2 += Double(game.yellowCardsIn2)
            case "redCards":
                data.redCardsIn1 += Double(game.redCardsIn1)
                data.redCardsIn2 += Double(game.redCardsIn2)
            default:
                break
            }
        }
    }
    //MARK: - Other functions
    func clearStatsDic(){
        data.gameID = []
        
        data.totalStats["goals"] = 0
        data.totalStats["corners"] = 0
        data.totalStats["offsides"] = 0
        data.totalStats["shots"] = 0
        data.totalStats["shotsOnTarget"] = 0
        data.totalStats["fouls"] = 0
        data.totalStats["saves"] = 0
        data.totalStats["goalKicks"] = 0
        data.totalStats["throwIns"] = 0
        data.totalStats["yellowCards"] = 0
        data.totalStats["redCards"] = 0
        
        data.goalsIn1 = 0
        data.goalsIn2 = 0
        data.cornersIn1 = 0
        data.cornersIn2 = 0
        data.offsidesIn1 = 0
        data.offsidesIn2 = 0
        data.shotsIn1 = 0
        data.shotsIn2 = 0
        data.shotsOnTargetIn1 = 0
        data.shotsOnTargetIn2 = 0
        data.foulsIn1 = 0
        data.foulsIn2 = 0
        data.savesIn1 = 0
        data.savesIn2 = 0
        data.goalKicksIn1 = 0
        data.goalKicksIn2 = 0
        data.throwInsIn1 = 0
        data.throwInsIn2 = 0
        data.yellowCardsIn1 = 0
        data.yellowCardsIn2 = 0
        data.redCardsIn1 = 0
        data.redCardsIn2 = 0
    }
    func getTeamStats() {
        
        for i in 0...coreStats.count - 1 {
            let stat = coreStats[i]
            let requestHome = HomeTeam.fetchRequest() as NSFetchRequest<HomeTeam>
            let requestAway = AwayTeam.fetchRequest() as NSFetchRequest<AwayTeam>
            let requestInfo = GameInfo.fetchRequest() as NSFetchRequest<GameInfo>
            
            if data.gameID.count > 0 {
                for i in 0...data.gameID.count - 1{
                    let filter1 = NSPredicate(format: "gameID = %@", "\(data.gameID[i])")
                    let filter2 = NSPredicate(format: "name like[cd] %@", "\(nameSelected!)")
                    let predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [filter1, filter2])
                    print(predicate)
                    requestHome.predicate = predicate
                    requestAway.predicate = predicate
                    requestInfo.predicate = predicate

                    try! homeItems = context.fetch(requestHome)
                    try! awayItems = context.fetch(requestAway)
                    
                    if homeItems!.count != 0{
                        getHalfData(stat: stat, home: true)
                    }else if awayItems!.count != 0{
                        getHalfData(stat: stat, home: false)
                    }
                }
            }
        }
    }
    func calculatePercentage(stat: String) -> (first: Double, second: Double){
        
        var percentageIn1:Double = 0.5
        var percentageIn2:Double = 0.5
        
        switch stat {
        case "goals":
            let total = data.goalsIn1 + data.goalsIn2
            if total != 0 {
                percentageIn1 = (data.goalsIn1/total)
                percentageIn2 = (data.goalsIn2/total)
                print(percentageIn2, percentageIn1)
            }
        case "corners":
            let total = data.cornersIn1 + data.cornersIn2
            if total != 0 {
                percentageIn1 = data.cornersIn1/total
                percentageIn2 = data.cornersIn2/total
            }
        case "offsides":
            let total = data.offsidesIn1 + data.offsidesIn2
            if total != 0 {
                percentageIn1 = data.offsidesIn1/total
                percentageIn2 = data.offsidesIn2/total
            }
        case "shots":
            let total = data.shotsIn1 + data.shotsIn2
            if total != 0 {
                percentageIn1 = data.shotsIn1/total
                percentageIn2 = data.shotsIn2/total
            }
        case "shotsOntarget":
            let total = data.shotsOnTargetIn1 + data.shotsOnTargetIn2
            if total != 0 {
                percentageIn1 = data.shotsOnTargetIn1/total
                percentageIn2 = data.shotsOnTargetIn2/total
            }
        case "fouls":
            let total = data.foulsIn1 + data.foulsIn2
        if total != 0 {
                percentageIn1 = data.foulsIn1/total
                percentageIn2 = data.foulsIn2/total
        }
        case "saves":
            let total = data.savesIn1 + data.savesIn2
            if total != 0 {
                percentageIn1 = data.savesIn1/total
                percentageIn2 = data.savesIn2/total
            }
        case "goalKicks":
            let total = data.goalKicksIn1 + data.goalKicksIn2
            if total != 0 {
                percentageIn1 = data.goalKicksIn1/total
                percentageIn2 = data.goalKicksIn2/total
            }
        case "throwIns":
            let total = data.throwInsIn1 + data.throwInsIn2
            if total != 0 {
                percentageIn1 = data.throwInsIn1/total
                percentageIn2 = data.throwInsIn2/total
            }
        case "yellowCards":
            let total = data.yellowCardsIn1 + data.yellowCardsIn2
            if total != 0 {
                percentageIn1 = data.yellowCardsIn1/total
                percentageIn2 = data.yellowCardsIn2/total
            }
        case "redCards":
            let total = data.redCardsIn1 + data.redCardsIn2
            if total != 0 {
                percentageIn1 = data.redCardsIn1/total
                percentageIn2 = data.redCardsIn2/total
            }
        default:
            break
        }
        percentageIn1 *= 100
        percentageIn2 *= 100
        return (Double(percentageIn1) , Double(percentageIn2))
    }
    
    func getNumbers( stat: String) -> (first: Int, second: Int){
    
        var total1 = 0
        var total2 = 0
        
        switch stat {
        case "goals":
            total1 = Int(data.goalsIn1)
            total2 = Int(data.goalsIn2)
        case "corners":
            total1 = Int(data.cornersIn1)
            total2 = Int(data.cornersIn2)
        case "offsides":
            total1 = Int(data.offsidesIn1)
            total2 = Int(data.offsidesIn2)
        case "shots":
            total1 = Int(data.shotsIn1)
            total2 = Int(data.shotsIn2)
        case "shotsOntarget":
            total1 = Int(data.shotsOnTargetIn1)
            total2 = Int(data.shotsOnTargetIn2)
        case "fouls":
            total1 = Int(data.foulsIn1)
            total2 = Int(data.foulsIn2)
        case "saves":
            total1 = Int(data.savesIn1)
            total2 = Int(data.savesIn2)
        case "goalKicks":
            total1 = Int(data.goalKicksIn1)
            total2 = Int(data.goalKicksIn2)
        case "throwIns":
            total1 = Int(data.throwInsIn1)
            total2 = Int(data.throwInsIn2)
        case "yellowCards":
            total1 = Int(data.yellowCardsIn1)
            total2 = Int(data.yellowCardsIn2)
        case "redCards":
            total1 = Int(data.redCardsIn1)
            total2 = Int(data.redCardsIn2)
        default:
            break
        }
        return (total1 , total2)
    }
    func oldGameAlert(){
        let alert = UIAlertController(title: "Old Game Detected", message: "This feature is not compatible with older versions, therefore statistics matching this name from an older version will not appear nor contribute to the totals. The statistics of new games you play will be shown", preferredStyle: .alert)
        let close = UIAlertAction(title: "close", style: .cancel) { (action) in

        }
        let neverAgain = UIAlertAction(title: "Never show again", style: .default) { (action) in
            myDefaults.set(true, forKey: "neverShowOldGameAlert")
            neverShowOldGameAlert = true
        }
        alert.addAction(close)
        alert.addAction(neverAgain)
        self.present(alert, animated: true, completion: nil)
        
    }
    //MARK: - pickerView functions
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        
        return data.names.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return data.names[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        clearStatsDic()
        getData(row: row)
        nameSelected = data.names[row]
        getTeamStats()
        rowSelected = row
        tableView.reloadData()
    }
    //MARK: - tableView functions
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return stats.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "detailedStatsTableViewCell") as! detailedStatsTableViewCell
        cell.lblStat.text = stats[indexPath.row]
        
        let stat = coreStats[indexPath.row]
        
        (data.totalStats[stat] == 9999) ? (cell.lblTotal.text = "0") : (cell.lblTotal.text = String(data.totalStats[stat]!))
        
        if data.names.count != 0{
            //check whether to display numbers or percentage
            if displayPercentage == true{
                let percentages = calculatePercentage(stat: coreStats[indexPath.row])
                cell.lblFirstPercent.text = String(Int(percentages.first)) + "%"
                cell.lblSecondPercent.text = String(Int(percentages.second))  + "%"
            }else{
                let number = getNumbers(stat: coreStats[indexPath.row])
                cell.lblFirstPercent.text = String(number.first)
                cell.lblSecondPercent.text = String(number.second)
            }
            
        }else{
            cell.lblFirstPercent.text = "-%"
            cell.lblSecondPercent.text = "-%"
        }
        
        return cell
    }
}
