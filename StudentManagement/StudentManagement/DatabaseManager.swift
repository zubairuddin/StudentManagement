//
//  DatabaseManager.swift
//  StudentManagement
//
//  Created by Zubair.Nagori on 11/10/18.
//  Copyright © 2018 joseph. All rights reserved.
//

import Foundation
import CoreData

class DatabaseManager {
    
    //Save the new student in Core Data
    class func saveStudent(studentId: String, firstName: String, lastName: String, gender: String, age: Int64, courseStudy: String, address: String) {
        let entity = NSEntityDescription.entity(forEntityName: "Student", in: MANAGED_OBJECT_CONTEXT)
        let studentObject = Student(entity: entity!, insertInto: MANAGED_OBJECT_CONTEXT)
        
        studentObject.studentId = studentId
        studentObject.firstName = firstName
        studentObject.lastName = lastName
        studentObject.gender = gender
        studentObject.age = age
        studentObject.courseStudy = courseStudy
        studentObject.address = address
        
        //Save the context
        do {
            try MANAGED_OBJECT_CONTEXT.save()
            
            print("Student saved successfully!")
        }
        catch let error {
            print("Unable to save student: \(error.localizedDescription)")
        }
    }
    
    //Get all the students from core data
    class func getAllStudents() -> [Student] {
        let fetchRequest: NSFetchRequest<Student> = Student.fetchRequest()
        var arrStudents = [Student]()
        
        do {
            try arrStudents = MANAGED_OBJECT_CONTEXT.fetch(fetchRequest)
        }
            
        catch let error {
            print("Unable to fetch students: \(error.localizedDescription)")
        }
        
        return arrStudents
    }
    
    //Get the selected student from core data
    class func getStudent(withStudentId studentId: String) ->[Student] {
        let fetchRequest: NSFetchRequest<Student> = Student.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "studentId = %@", studentId)
        var arrStudents = [Student]()
        
        do {
            try arrStudents = MANAGED_OBJECT_CONTEXT.fetch(fetchRequest)
        }
            
        catch let error {
            print("Unable to fetch student: \(error.localizedDescription)")
        }
        
        return arrStudents
    }
    
    //Update the student in core data
    class func updateStudent(withStudentId studentId: String, firstName: String, lastName: String, gender: String, age: Int64, courseStudy: String, address: String) {
        
        let fetchRequest: NSFetchRequest<Student> = Student.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "studentId = %@", studentId)
        var arrStudents = [Student]()
        
        do {
            try arrStudents = MANAGED_OBJECT_CONTEXT.fetch(fetchRequest)
        }
            
        catch let error {
            print("Unable to fetch student: \(error.localizedDescription)")
        }
        
        if arrStudents.count > 0 {
            let student = arrStudents.last
            
            student?.firstName = firstName
            student?.lastName = lastName
            student?.gender = gender
            student?.age = age
            student?.courseStudy = courseStudy
            student?.address = address
            
            do {
                try MANAGED_OBJECT_CONTEXT.save()
                print("Student updated successfully!")
            }
            catch let error {
                print("Unable to update student: \(error.localizedDescription)")
            }

            
        }
        else {
            return
        }
    }
}
