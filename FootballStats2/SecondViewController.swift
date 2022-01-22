//
//  SecondViewController.swift
//  FootballStats2
//
//  Created by Thomas Karbowiak on 4/9/20.
//  Copyright © 2020 Thomas Karbowiak. All rights reserved.
//

import UIKit
import CoreData


class SecondViewController: UIViewController, UITableViewDelegate, UITableViewDataSource{
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var gameSelected  = 0
    var didTapMore = false
    
    @IBOutlet var tableView: UITableView!
    
    lazy var refreshPage:UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.tintColor = .black
        refreshControl.addTarget(self, action: #selector(refresh), for: .valueChanged)
        return refreshControl
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        deleteAllData(entity: "HomeTeam")
//        deleteAllData(entity: "AwayTeam")
//        deleteAllData(entity: "GameInfo")
        getData()
        
        //get custom cell
        let nib = UINib(nibName: "SavedGamesTableViewCell", bundle: nil)
        
        tableView.register(nib, forCellReuseIdentifier: "SavedGamesTableViewCell")
        
        tableView.delegate = self
        tableView.dataSource = self
        
        //add refresh control
        tableView.refreshControl = refreshPage
        
    }
    @IBAction func didTapMore(_ sender: Any) {
        didTapMore = true
        performSegue(withIdentifier: "more", sender: self)
    }
    
    //MARK: - Table View
    var items = 0
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        items = infoItems!.count
        if premiumPurchase == false && items != 0{
            items += 1
        }else if items == 0 {
            items += 1
        }
        return items
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SavedGamesTableViewCell", for: indexPath) as! SavedGamesTableViewCell
        let noGamesCell = tableView.dequeueReusableCell(withIdentifier: "noGamesCell", for: indexPath)
        
        if infoItems!.count > 0 {
            if premiumPurchase == true{
                let homeTeam = homeItems![indexPath.row]
                let awayTeam = awayItems![indexPath.row]
                let gameInfo = infoItems![indexPath.row]
                
                cell.lblHomeTeam.text = homeTeam.name
                cell.lblHomeScore.text = homeTeam.goals
                cell.lblAwayTeam.text = awayTeam.name
                cell.lblAwayScore.text = awayTeam.goals
                cell.lblDate.text = gameInfo.date
                cell.lblTime.text = gameInfo.time
                cell.lblPremium.text = ""
            }else{
                if indexPath.row > 0{
                    cell.lblHomeTeam.text = ""
                    cell.lblHomeScore.text = ""
                    cell.lblAwayTeam.text = ""
                    cell.lblAwayScore.text = ""
                    cell.lblDate.text = ""
                    cell.lblTime.text = ""
                    cell.lblV.text = ""
                    cell.lblDash.text = ""
                    cell.lblPremium.text = "Purchase premium to view all results"
                }else{
                    
                    let homeTeam = homeItems![indexPath.row]
                    let awayTeam = awayItems![indexPath.row]
                    let gameInfo = infoItems![indexPath.row]
                    
                    cell.lblHomeTeam.text = homeTeam.name
                    cell.lblHomeScore.text = homeTeam.goals
                    cell.lblAwayTeam.text = awayTeam.name
                    cell.lblAwayScore.text = awayTeam.goals
                    cell.lblDate.text = gameInfo.date
                    cell.lblTime.text = gameInfo.time
                }
            }
            
            return cell
        }else{
            noGamesCell.isUserInteractionEnabled = false
            return noGamesCell
        }
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        gameSelected = indexPath.row
        if premiumPurchase == true{
            self.performSegue(withIdentifier: "selectedGame", sender: self)
            
        }else{
            if indexPath.row == 1{
                self.performSegue(withIdentifier: "getPremium", sender: self)
                
            }else{
                self.performSegue(withIdentifier: "selectedGame", sender: self)
            }
        }
    }
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == UITableViewCell.EditingStyle.delete{
            
            let alert = UIAlertController(title: "Delete Game", message: "Are you sure that you would like to permanently delte this game?", preferredStyle: .alert)
            
            let yesButton = UIAlertAction(title: "Yes", style: .default) { (action) in
                let homeItemToRemove = homeItems![indexPath.row]
                let awayItemsToRemove = awayItems![indexPath.row]
                let infoItemsToRemove = infoItems![indexPath.row]
                
                self.context.delete(homeItemToRemove)
                self.context.delete(awayItemsToRemove)
                self.context.delete(infoItemsToRemove)
                
                do{
                    try self.context.save()
                    print("game Deleted")
                    
                }catch{
                    print("There was an error deleting", error)
                }
                
                self.getData()
            }
            let noButton = UIAlertAction(title: "No", style: .default) { (action) in
                
            }
            alert.addAction(yesButton)
            alert.addAction(noButton)
            
            self.present(alert, animated: true, completion: nil)
            
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if didTapMore == false{
            if premiumPurchase == true || gameSelected != 1{
                
                let vc = segue.destination as! SelectedGameViewController
                vc.gameSelected = gameSelected
            }
        }else{
            didTapMore = false
        }
    }
    //MARK: - Get Data
    func getData(){
        
        let requestHome = HomeTeam.fetchRequest() as NSFetchRequest<HomeTeam>
        let requestAway = AwayTeam.fetchRequest() as NSFetchRequest<AwayTeam>
        let requestInfo = GameInfo.fetchRequest() as NSFetchRequest<GameInfo>
        
        //Sorts results so most recent is first
        let sortHomeByDate = NSSortDescriptor(key: "dateAsDate", ascending: false)
        let sortHomeByTime = NSSortDescriptor(key: "time", ascending: false)
        
        let sortAwayByDate = NSSortDescriptor(key: "dateAsDate", ascending: false)
        let sortAwayByTime = NSSortDescriptor(key: "time", ascending: false)
        
        let sortInfoByDate = NSSortDescriptor(key: "dateAsDate", ascending: false)
        let sortInfoByTime = NSSortDescriptor(key: "time", ascending: false)
        
        requestHome.sortDescriptors = [sortHomeByDate, sortHomeByTime]
        requestAway.sortDescriptors = [sortAwayByDate, sortAwayByTime]
        requestInfo.sortDescriptors = [sortInfoByDate, sortInfoByTime]
        
        if premiumPurchase == false{
            requestInfo.fetchLimit = 1
        }

        do{
            
            homeItems = try context.fetch(requestHome)
            awayItems = try context.fetch(requestAway)
            infoItems = try context.fetch(requestInfo)
            
            DispatchQueue.main.async {
                self.tableView.reloadData()
                
            }
                    
        }catch{
            print("there was an error",error)
        }
    }
    @objc func refresh(){
        getData()
        tableView.reloadData()
        print("page Refreshed")
        refreshPage.endRefreshing()
    }
    func deleteAllData(entity: String)
    {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        let ReqVar = NSFetchRequest<NSFetchRequestResult>(entityName: entity)
        let DelAllReqVar = NSBatchDeleteRequest(fetchRequest: ReqVar)
        do {
            try context.execute(DelAllReqVar)
            print("Deleted",DelAllReqVar,"deleted")
        }
        catch {
            print(error) }
    }
    
}

