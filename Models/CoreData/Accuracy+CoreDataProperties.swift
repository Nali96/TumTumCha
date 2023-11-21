//
//  Accuracy+CoreDataProperties.swift
//  TumTumCha
//
//  Created by Marco Di Fiandra on 22/05/2019.
//  Copyright © 2019 Apple Academy. All rights reserved.
//
//

import Foundation
import CoreData


extension Accuracy {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Accuracy> {
        return NSFetchRequest<Accuracy>(entityName: "Accuracy")
    }

    @NSManaged public var accuracy: Int16
    @NSManaged public var idLevel: String?
    @NSManaged public var idWorld: String?

}
