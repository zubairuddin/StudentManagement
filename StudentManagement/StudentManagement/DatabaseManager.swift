//
//  DatabaseManager.swift
//  StudentManagement
//
//  Created by joseph on 11/10/18.
//  Copyright © 2018 joseph. All rights reserved.
//

import Foundation
import CoreData

class DatabaseManager {
    
    //Save the new student in Core Data
    class func saveStudent(studentId: String, firstName: String, lastName: String, gender: String, age: Int64, courseStudy: String, city: String, street: String, imageData: Data) {
        
        let entity = NSEntityDescription.entity(forEntityName: "Student", in: MANAGED_OBJECT_CONTEXT)
        let studentObject = Student(entity: entity!, insertInto: MANAGED_OBJECT_CONTEXT)
        
        studentObject.studentId = studentId
        studentObject.firstName = firstName
        studentObject.lastName = lastName
        studentObject.gender = gender
        studentObject.age = age
        studentObject.courseStudy = courseStudy
        studentObject.city = city
        studentObject.street = street

        studentObject.image = imageData
        
        //Save the context
        do {
            try MANAGED_OBJECT_CONTEXT.save()
            
            print("Student saved successfully!")
            NotificationCenter.default.post(name: Notification.Name("AddStudentSuccess"), object: nil)
        }
        catch let error {
            
            let errorCode = (error as NSError).code
            
            print("Unable to save student: \(error.localizedDescription)")
            print("Error Code is \(errorCode)")
            
            //Error code 133021 means duplicacy in one of the attributes. In our case this error will occur if someone tries to add student with the a student id that already exists
            
            if errorCode == 133021 {
                NotificationCenter.default.post(name: Notification.Name("AddStudentFailed"), object: nil, userInfo: ["message": "Student ID already exists"])
                return
            }
            
            NotificationCenter.default.post(name: Notification.Name("AddStudentFailed"), object: nil, userInfo: ["message": error.localizedDescription])

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
    class func updateStudent(withObjectId objectId: NSManagedObjectID, studentId: String, firstName: String, lastName: String, gender: String, age: Int64, courseStudy: String, city: String, street: String, imageData: Data) {
        
        let fetchRequest: NSFetchRequest<Student> = Student.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "SELF =  %@", objectId)
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
            student?.city = city
            student?.street = street
            student?.image = imageData
            
            do {
                try MANAGED_OBJECT_CONTEXT.save()
                print("Student updated successfully!")
                NotificationCenter.default.post(name: Notification.Name("AddStudentSuccess"), object: nil)
            }
            catch let error {
                let errorCode = (error as NSError).code
                
                print("Unable to save student: \(error.localizedDescription)")
                print("Error Code is \(errorCode)")
                
                //Error code 133021 means duplicacy in one of the attributes. In our case this error will occur if someone tries to add student with the a student id that already exists
                
                if errorCode == 133021 {
                    NotificationCenter.default.post(name: Notification.Name("AddStudentFailed"), object: nil, userInfo: ["message": "Student ID already exists"])
                    return
                }
                
                NotificationCenter.default.post(name: Notification.Name("AddStudentFailed"), object: nil, userInfo: ["message": error.localizedDescription])
            }
        }
            
        else {
            return
        }
    }
    
    class func saveExam(examName: String, examDate: Date, examTime: Date, location: String) {
        let entity = NSEntityDescription.entity(forEntityName: "Exams", in: MANAGED_OBJECT_CONTEXT)
        let examManagedObject = Exams(entity: entity!, insertInto: MANAGED_OBJECT_CONTEXT)
        
        examManagedObject.examName = examName
        examManagedObject.examDate = examDate
        examManagedObject.examTime = examTime
        examManagedObject.examLocation = location
        
        //Save the context
        do {
            try MANAGED_OBJECT_CONTEXT.save()
            
            print("Exam saved successfully!")
            NotificationCenter.default.post(name: Notification.Name("AddExamSuccess"), object: nil)
        }
        catch let error {
            print("Unable to save exam: \(error.localizedDescription)")
            NotificationCenter.default.post(name: Notification.Name("AddExamFailed"), object: nil)
        }
    }
    
    //Get all the exams from core data
    class func getAllExams() -> [Exams] {
        let fetchRequest: NSFetchRequest<Exams> = Exams.fetchRequest()
        var arrExams = [Exams]()
        
        do {
            try arrExams = MANAGED_OBJECT_CONTEXT.fetch(fetchRequest)
        }
            
        catch let error {
            print("Unable to fetch exams: \(error.localizedDescription)")
        }
        
        return arrExams
    }
    class func getSelectedExams() -> [Exams] {
        let fetchRequest: NSFetchRequest<Exams> = Exams.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "isSelectedForDelete == true")
        
        var arrExams = [Exams]()
        
        do {
            try arrExams = MANAGED_OBJECT_CONTEXT.fetch(fetchRequest)
        }
            
        catch let error {
            print("Unable to fetch exams: \(error.localizedDescription)")
        }
        
        return arrExams
    }
    
    class func getStudentDetail(withObjectId objectId: NSManagedObjectID) -> Student? {
        let fetchRequest: NSFetchRequest<Student> = Student.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "SELF = %@", objectId)
        
        var arrStudents = [Student]()
        
        do {
            try arrStudents = MANAGED_OBJECT_CONTEXT.fetch(fetchRequest)
        }
            
        catch let error {
            print("Unable to fetch students: \(error.localizedDescription)")
            return nil
        }
        
        return arrStudents.last
    }
    
    class func updateExam(withObjectId managedObjectId: NSManagedObjectID, examName: String, examDate: Date, examTime: Date, location: String) {
        
        let fetchRequest: NSFetchRequest<Exams> = Exams.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "SELF = %@", managedObjectId)
        var arrExams = [Exams]()
        
        do {
            try arrExams = MANAGED_OBJECT_CONTEXT.fetch(fetchRequest)
        }
            
        catch let error {
            print("Unable to fetch exams: \(error.localizedDescription)")
        }
        
        if arrExams.count > 0 {
            let exam = arrExams.last
            
            exam?.examName = examName
            exam?.examDate = examDate
            exam?.examTime = examTime
            exam?.examLocation = location
            
            do {
                try MANAGED_OBJECT_CONTEXT.save()
                print("exam updated successfully!")
                NotificationCenter.default.post(name: Notification.Name("AddExamSuccess"), object: nil)
            }
            catch let error {
                print("Unable to update exam: \(error.localizedDescription)")
                NotificationCenter.default.post(name: Notification.Name("AddExamFailed"), object: nil)
            }
        }
            
        else {
            return
        }
    }
}
