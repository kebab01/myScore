//
//  GameInfo+CoreDataProperties.swift
//  
//
//  Created by Thomas Karbowiak on 25/10/20.
//
//

import Foundation
import CoreData


extension GameInfo {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<GameInfo> {
        return NSFetchRequest<GameInfo>(entityName: "GameInfo")
    }

    @NSManaged public var date: String?
    @NSManaged public var dateAsDate: Date?
    @NSManaged public var gameID: Int64
    @NSManaged public var halfLength: String?
    @NSManaged public var location: String?
    @NSManaged public var notes: String?
    @NSManaged public var time: String?
    @NSManaged public var gameVersion: Float

}
