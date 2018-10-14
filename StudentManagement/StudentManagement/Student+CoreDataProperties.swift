//
//  Student+CoreDataProperties.swift
//  StudentManagement
//
//  Created by Zubair on 14/10/18.
//  Copyright © 2018 joseph. All rights reserved.
//
//

import Foundation
import CoreData


extension Student {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Student> {
        return NSFetchRequest<Student>(entityName: "Student")
    }

    @NSManaged public var age: Int64
    @NSManaged public var courseStudy: String
    @NSManaged public var firstName: String
    @NSManaged public var gender: String
    @NSManaged public var image: Data?
    @NSManaged public var lastName: String
    @NSManaged public var studentId: String
    @NSManaged public var city: String
    @NSManaged public var street: String
    @NSManaged public var exams: NSSet?

}

// MARK: Generated accessors for exams
extension Student {

    @objc(addExamsObject:)
    @NSManaged public func addToExams(_ value: Exams)

    @objc(removeExamsObject:)
    @NSManaged public func removeFromExams(_ value: Exams)

    @objc(addExams:)
    @NSManaged public func addToExams(_ values: NSSet)

    @objc(removeExams:)
    @NSManaged public func removeFromExams(_ values: NSSet)

}
