//
//  Exams+CoreDataProperties.swift
//  StudentManagement
//
//  Created by Zubair on 13/10/18.
//  Copyright © 2018 joseph. All rights reserved.
//
//

import Foundation
import CoreData


extension Exams {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Exams> {
        return NSFetchRequest<Exams>(entityName: "Exams")
    }

    @NSManaged public var examName: String
    @NSManaged public var examDateTime: Date
    @NSManaged public var examLocation: String
    @NSManaged public var isSelectedForDelete: Bool
    @NSManaged public var students: NSSet?

}

// MARK: Generated accessors for students
extension Exams {

    @objc(addStudentsObject:)
    @NSManaged public func addToStudents(_ value: Student)

    @objc(removeStudentsObject:)
    @NSManaged public func removeFromStudents(_ value: Student)

    @objc(addStudents:)
    @NSManaged public func addToStudents(_ values: NSSet)

    @objc(removeStudents:)
    @NSManaged public func removeFromStudents(_ values: NSSet)

}
