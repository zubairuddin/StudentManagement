//
//  StudentDetailViewController.swift
//  StudentManagement
//
//  Created by Zubair.Nagori on 11/10/18.
//  Copyright © 2018 joseph. All rights reserved.
//

import UIKit
import CoreData

class StudentDetailViewController: UIViewController {

    //Outlets
    @IBOutlet weak var txtStudentId: UITextField!
    @IBOutlet weak var txtFirstName: UITextField!
    @IBOutlet weak var txtLastName: UITextField!
    @IBOutlet weak var txtAddress: UITextField!
    @IBOutlet weak var txtCourse: UITextField!
    @IBOutlet weak var segmentGender: UISegmentedControl!
    @IBOutlet weak var stepperAge: UIStepper!
    @IBOutlet weak var lblAge: UILabel!
    @IBOutlet weak var btnExams: UIButton!
    @IBOutlet weak var btnSaveChanges: UIButton!
    
    //Instance variables
    var gender = "Male"
    var age: Int64!

    //Validation Enum
    enum ValidateData {
        case invalid(String)
        case valid
    }

    //Variables
    var selectedStudent: Student!
    
    //MARK: View Lifecycle methods
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        setUpView()
        formatControls()
    }
    func setUpView() {
        
        //Set up the delete student button
        let deleteButton = UIBarButtonItem(barButtonSystemItem: .trash, target: self, action: #selector(deleteStudent))
        navigationItem.rightBarButtonItem = deleteButton
        
        //Show Student's name on the title
        title = selectedStudent.firstName + " " + selectedStudent.lastName
        
        //Show the data for the selected student
        txtStudentId.text = selectedStudent.studentId
        txtFirstName.text = selectedStudent.firstName
        txtLastName.text = selectedStudent.lastName
        txtCourse.text = selectedStudent.courseStudy
        txtAddress.text = selectedStudent.address
        
        age = selectedStudent.age
        gender = selectedStudent.gender
        lblAge.text = "Age: \(age!)"
        stepperAge.value = Double(age)
        segmentGender.selectedSegmentIndex = gender == "Male" ? 0 : 1
    }
    
    func formatControls() {
        btnExams.layer.cornerRadius = btnExams.frame.height / 2
        btnExams.layer.masksToBounds = true
        
        btnSaveChanges.layer.cornerRadius = btnExams.frame.height / 2
        btnSaveChanges.layer.masksToBounds = true

    }
    
    //MARK: Actions
    @IBAction func updateStudentAction(_ sender: UIButton) {
        let validationStage = validateDetails()
        
        switch validationStage {
        case .valid:
            //Update user Info
            DatabaseManager.updateStudent(withStudentId: selectedStudent.studentId, firstName: txtFirstName.text!, lastName: txtLastName.text!, gender: gender, age: age, courseStudy: txtCourse.text!, address: txtAddress.text!)
        case .invalid(let errorMessage):
            presentAlert(withTitle: errorMessage, message: "")
        }
    }
    @IBAction func showExamsForStudent(_ sender: UIButton) {
    }
    
    @IBAction func genderSelected(_ sender: UISegmentedControl) {
        gender = sender.selectedSegmentIndex == 0 ? "Male" : "Female"
    }
    
    @IBAction func ageChanged(_ sender: UIStepper) {
        age =  Int64(sender.value)
        lblAge.text = "Age: \(age!)"
    }
    
    //MARK: Custom Methods
    func validateDetails() -> ValidateData {
        if (txtStudentId.text?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)! {
            return .invalid("Please enter student id.")
        }
        else if (txtFirstName.text?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)! {
            return .invalid("Please enter first name.")
        }
        else if (txtLastName.text?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)! {
            return .invalid("Please enter last name.")
        }
        else if (txtCourse.text?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)! {
            return .invalid("Please enter course.")
        }
        else if (txtAddress.text?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)! {
            return .invalid("Please enter address.")
        }
        else {
            return .valid
        }
        
    }

    @objc func deleteStudent() {
        let alertController = UIAlertController(title: "Are you sure you want to delete this student?", message: nil, preferredStyle: .alert)
        let yesAction = UIAlertAction(title: "Yes", style: .default) { (action) in
            self.deleteStudentFromCoreData()
        }
        let noAction = UIAlertAction(title: "No", style: .cancel, handler: nil)
        alertController.addAction(yesAction)
        alertController.addAction(noAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
    func deleteStudentFromCoreData() {
        KAPPDELEGATE.persistentContainer.viewContext.delete(selectedStudent)
        do {
            try KAPPDELEGATE.persistentContainer.viewContext.save()
            print("Deleted successfully")
            navigationController?.popViewController(animated: true)
        }
        catch let error {
            print("Unable to delete student: \(error.localizedDescription)")
        }
    }

}
