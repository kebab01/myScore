//
//  global.swift
//  FootballStats2
//
//  Created by Thomas Karbowiak on 6/9/20.
//  Copyright © 2020 Thomas Karbowiak. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class gameStats{
    var name = ""
    
    var goals:Int?
    var goalTimes = [Int]()
    var goalsIn1:Int?
    var goalsIn2:Int?
    
    var corners:Int?
    var cornerTimes = [Int]()
    var cornersIn1:Int?
    var cornersIn2:Int?
    
    var offsides:Int?
    var offsideTimes = [Int]()
    var offsidesIn1:Int?
    var offsidesIn2:Int?
    
    var shots:Int?
    var shotTimes = [Int]()
    var shotsIn1:Int?
    var shotsIn2:Int?
    
    var shotsOnTarget:Int?
    var shotsOnTargetTimes = [Int]()
    var shotsOnTargetIn1:Int?
    var shotsOnTargetIn2:Int?
    
    var fouls:Int?
    var foulTimes = [Int]()
    var foulsIn1:Int?
    var foulsIn2:Int?
    
    var saves:Int?
    var saveTimes = [Int]()
    var savesIn1:Int?
    var savesIn2:Int?
    
    var goalKicks:Int?
    var goalKickTimes = [Int]()
    var goalKicksIn1:Int?
    var goalKicksIn2:Int?
    
    var throwIns:Int?
    var throwInTimes = [Int]()
    var throwInsIn1:Int?
    var throwInsIn2:Int?
    
    var yellowCard:Int?
    var yellowCardTimes = [Int]()
    var yellowCardIn1:Int?
    var yellowCardIn2:Int?
    
    var redCard:Int?
    var redCardTimes = [Int]()
    var redCardIn1:Int?
    var redCardIn2:Int?
    
    var penalties:Int?
    
    var gameID:Int?
}

class gameInfomation{
    var location = ""
    var halfLength = 0
    var extraTime = 0
    var notes:String?
    var date = ""
    var dateAsDate: Date?
    var time = ""
}
var gameVersion = 3
var gameSubVersion = 0.0

var stats = ["Goals", "Corners", "Offsides", "Shots", "Shots on Target", "Fouls", "Saves", "Goal Kicks", "Throw-ins", "Yellow Cards", "Red Cards"]

var gameInProgress = false

var statsToRecord = [String]()

let homeTeamStats = gameStats()
let awayTeamStats = gameStats()
let gameInfo = gameInfomation()

//for retrieving data from core
var homeItems:[HomeTeam]?
var awayItems:[AwayTeam]?
var infoItems:[GameInfo]?

let myDefaults = UserDefaults.standard
var premiumPurchase = myDefaults.bool(forKey: "premium")
var stopwatchSelected = myDefaults.bool(forKey: "stopwatchSelected")

var isNotFirstLaunch = myDefaults.bool(forKey: "isNotFirstLaunch")
var hasUpdated = myDefaults.integer(forKey: "hasUpdated")
var neverShowOldGameAlert = myDefaults.bool(forKey: "neverShowOldGameAlert")

var positionDefualts = myDefaults.object(forKey: "statPositions") as? [String]

