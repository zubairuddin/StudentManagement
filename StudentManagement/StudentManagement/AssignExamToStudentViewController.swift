//
//  AssignExamToStudentViewController.swift
//  StudentManagement
//
//  Created by Zubair on 13/10/18.
//  Copyright © 2018 joseph. All rights reserved.
//

import UIKit

class AssignExamToStudentViewController: UIViewController {
    
    //Outlets
    @IBOutlet weak var btnSelectExam: UIButton!
    @IBOutlet weak var btnSelectStudent: UIButton!
    @IBOutlet weak var btnAdd: UIButton!
    @IBOutlet weak var pickerView: UIPickerView!
    @IBOutlet weak var viewPickerBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var viewPickerContainer: UIView!
    
    enum SelectedPicker {
        case student
        case exam
    }
    
    var selectedPicker: SelectedPicker?
    var selectedStudent: Student?
    var selectedExam: Exams?
    var arrAllStudents = [Student]()
    var arrAllExams = [Exams]()
    
    //MARK: View Lifecycle methods
    
    //This function is called when the view first loads
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        self.title = "Assign Exams"
        
        //Populate the arrays
        arrAllStudents = DatabaseManager.getAllStudents()
        arrAllExams = DatabaseManager.getAllExams()
        
        //Cornering controls
        cornerViewRadius(sourceView: btnSelectExam)
        cornerViewRadius(sourceView: btnSelectStudent)
        cornerViewRadius(sourceView: btnAdd)
        
        selectedPicker = .exam
    }
    
    //MARK: Actions
    
    //This method is called when user cancels the selection
    @IBAction func cancelSelection(_ sender: UIButton) {
        showHidePickerView(false)
    }
    
    //This method is called when the user confirms the selection
    @IBAction func doneSelection(_ sender: UIButton) {
        showHidePickerView(false)
        
        if selectedPicker == .student {
            guard let student = selectedStudent else {
                return
            }
            
            let name = student.firstName + " " + student.lastName
            btnSelectStudent.setTitle(name, for: .normal)
        }
        else {
            guard let exam = selectedExam else {
                return
            }
            
            btnSelectExam.setTitle(exam.examName, for: .normal)
        }
    }
    
    //This method is called when the user taps on the exams button
    @IBAction func selectExamTapped(_ sender: UIButton) {
        if arrAllExams.count > 0 {
            selectedPicker = .exam
            showHidePickerView(true)
        }
        else {
            presentAlert(withTitle: "No Exams Found.", message: "Please add some exams first.")
        }
    }
    
    //The select student button was tapped
    @IBAction func selectStudentTapped(_ sender: UIButton) {
        if arrAllStudents.count > 0 {
            selectedPicker = .student
            showHidePickerView(true)

        }
        else {
            presentAlert(withTitle: "No Students Found.", message: "Please add some students first.")
        }
    }
    
    //The add button was tapped
    @IBAction func addTapped(_ sender: UIButton) {
        
        //Get the selected student and selected exam
        guard let selectedStudent = selectedStudent, let selectedExam = selectedExam else {
            return
        }
        
        //Add the selected exam to student object
        selectedStudent.addToExams(selectedExam)
        
        do {
            try KAPPDELEGATE.persistentContainer.viewContext.save()
            print("Assigned exam successfully.")
            navigationController?.popViewController(animated: true)
        }
        catch let error {
            print("Error while assigning exam to student: \(error.localizedDescription)")
            presentAlert(withTitle: "Can't Assign exam.", message: "Error: \(error.localizedDescription)")
        }
        
    }
    
    //MARK: Custom Methods
    func showHidePickerView(_ isShow: Bool) {
        if isShow {
            
            pickerView.reloadAllComponents()
            viewPickerBottomConstraint.constant = 0
            
            //Select first row by default
            let row = pickerView.selectedRow(inComponent: 0)
            pickerView(pickerView, didSelectRow: row, inComponent:0)

        }
        else {
            if #available(iOS 11.0, *) {
                viewPickerBottomConstraint.constant = -(viewPickerContainer.frame.height + view.safeAreaInsets.bottom)
            } else {
                // Fallback on earlier versions
                viewPickerBottomConstraint.constant = -viewPickerContainer.frame.height
            }
        }
        
        UIView.animate(withDuration: 0.5) {
            self.view.layoutIfNeeded()
        }
    }
    
    func cornerViewRadius(sourceView: UIView) {
        sourceView.layer.cornerRadius = sourceView.frame.height / 2
        sourceView.layer.masksToBounds = true
    }

}


extension AssignExamToStudentViewController: UIPickerViewDelegate {
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if selectedPicker == .student {
            
            if arrAllStudents.count > 0 {
                selectedStudent = arrAllStudents[row]
            }
            
        }
        else {
            if arrAllExams.count > 0 {
                selectedExam = arrAllExams[row]
            }
            
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        
        if selectedPicker == .student {
            return arrAllStudents[row].firstName + " " + arrAllStudents[row].lastName
        }
        else {
            return arrAllExams[row].examName
        }
        
    }
}

extension AssignExamToStudentViewController: UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if selectedPicker == .student {
            return arrAllStudents.count
        }
        else {
            return arrAllExams.count
        }

    }
}
