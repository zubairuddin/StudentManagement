//
//  AddStudentViewController.swift
//  StudentManagement
//
//  Created by Zubair.Nagori on 11/10/18.
//  Copyright © 2018 joseph. All rights reserved.
//

import UIKit

class AddStudentViewController: UIViewController {

    //Outlets
    @IBOutlet weak var txtStudentId: UITextField!
    @IBOutlet weak var txtFirstName: UITextField!
    @IBOutlet weak var txtLastName: UITextField!
    @IBOutlet weak var txtAddress: UITextField!
    @IBOutlet weak var txtCourse: UITextField!
    @IBOutlet weak var segmentGender: UISegmentedControl!
    @IBOutlet weak var stepperAge: UIStepper!
    @IBOutlet weak var lblAge: UILabel!
    
    //Instance variables
    var gender: String?
    var age: Int64 = 18
    
    //Validation Enum
    enum ValidateData {
        case invalid(String)
        case valid
    }
    
    //MARK: View Lifecycle methods
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
    }
    
    //MARK: Actions
    @IBAction func saveStudentAction(_ sender: UIButton) {
        let validationStage = validateDetails()
        
        switch validationStage {
        case .valid:
            //Save user Info
            DatabaseManager.saveStudent(studentId: txtStudentId.text!, firstName: txtFirstName.text!, lastName: txtLastName.text!, gender: gender!, age: age, courseStudy: txtCourse.text!, address: txtAddress.text!)
            
        case .invalid(let errorMessage):
            presentAlert(withTitle: errorMessage, message: "")
        }
    }
        
    @IBAction func genderSelected(_ sender: UISegmentedControl) {
        gender = sender.selectedSegmentIndex == 0 ? "Male" : "Female"
    }
    
    @IBAction func ageChanged(_ sender: UIStepper) {
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
        else if gender == nil {
            return .invalid("Please select gender.")
        }
        else {
            return .valid
        }
        
    }
    
}
