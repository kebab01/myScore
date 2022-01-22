//
//  AwayTeam+CoreDataProperties.swift
//  
//
//  Created by Thomas Karbowiak on 25/10/20.
//
//

import Foundation
import CoreData


extension AwayTeam {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<AwayTeam> {
        return NSFetchRequest<AwayTeam>(entityName: "AwayTeam")
    }

    @NSManaged public var corners: String?
    @NSManaged public var cornersIn1: Int64
    @NSManaged public var cornersIn2: Int64
    @NSManaged public var cornerTimes: Array<Int>?
    @NSManaged public var date: String?
    @NSManaged public var dateAsDate: Date?
    @NSManaged public var fouls: String?
    @NSManaged public var foulsIn1: Int64
    @NSManaged public var foulsIn2: Int64
    @NSManaged public var foulTimes: Array<Int>?
    @NSManaged public var gameID: Int64
    @NSManaged public var goalKicks: String?
    @NSManaged public var goalKicksIn1: Int64
    @NSManaged public var goalKicksIn2: Int64
    @NSManaged public var goalKickTimes: Array<Int>?
    @NSManaged public var goals: String?
    @NSManaged public var goalsIn1: Int64
    @NSManaged public var goalsIn2: Int64
    @NSManaged public var goalTimes: Array<Int>?
    @NSManaged public var name: String?
    @NSManaged public var offsides: String?
    @NSManaged public var offsidesIn1: Int64
    @NSManaged public var offsidesIn2: Int64
    @NSManaged public var offsideTimes: Array<Int>?
    @NSManaged public var penalties: String?
    @NSManaged public var redCards: String?
    @NSManaged public var redCardsIn1: Int64
    @NSManaged public var redCardsIn2: Int64
    @NSManaged public var redCardTimes: Array<Int>?
    @NSManaged public var saves: String?
    @NSManaged public var savesIn1: Int64
    @NSManaged public var savesIn2: Int64
    @NSManaged public var saveTimes: Array<Int>?
    @NSManaged public var shotOnTargetTimes: Array<Int>?
    @NSManaged public var shots: String?
    @NSManaged public var shotsIn1: Int64
    @NSManaged public var shotsIn2: Int64
    @NSManaged public var shotsOnTarget: String?
    @NSManaged public var shotsOnTargetIn1: Int64
    @NSManaged public var shotsOnTargetIn2: Int64
    @NSManaged public var shotTimes: Array<Int>?
    @NSManaged public var throwIns: String?
    @NSManaged public var throwInsIn1: Int64
    @NSManaged public var throwInsIn2: Int64
    @NSManaged public var throwInTimes: Array<Int>?
    @NSManaged public var time: String?
    @NSManaged public var yellowCards: String?
    @NSManaged public var yellowCardsIn1: Int64
    @NSManaged public var yellowCardsIn2: Int64
    @NSManaged public var yellowCardTimes: Array<Int>?
    @NSManaged public var gameVersion: Float

}
