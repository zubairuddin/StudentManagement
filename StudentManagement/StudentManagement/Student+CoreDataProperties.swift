//
//  Student+CoreDataProperties.swift
//  StudentManagement
//
//  Created by Zubair.Nagori on 11/10/18.
//  Copyright © 2018 joseph. All rights reserved.
//
//

import Foundation
import CoreData


extension Student {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Student> {
        return NSFetchRequest<Student>(entityName: "Student")
    }

    @NSManaged public var studentId: String
    @NSManaged public var firstName: String
    @NSManaged public var lastName: String
    @NSManaged public var gender: String
    @NSManaged public var age: Int64
    @NSManaged public var courseStudy: String
    @NSManaged public var address: String

}
