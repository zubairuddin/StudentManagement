//
//  AddExamViewController.swift
//  StudentManagement
//
//  Created by Zubair.Nagori on 11/10/18.
//  Copyright © 2018 joseph. All rights reserved.
//

import UIKit

class AddExamViewController: UIViewController {

    @IBOutlet weak var viewPickerBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var txtExamName: UITextField!
    @IBOutlet weak var txtDateTime: UITextField!
    @IBOutlet weak var txtLocation: UITextField!
    @IBOutlet weak var viewExamDatePicker: UIView!
    @IBOutlet weak var pickerExamDate: UIDatePicker!
    @IBOutlet weak var btnSave: UIButton!
    
    var isEditingExam = false
    var selectedExam: Exams!
    
    //MARK: View Lifecycle methods
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        if isEditingExam {
            title = selectedExam.examName
            
            txtExamName.becomeFirstResponder()
            txtExamName.text = selectedExam.examName
            txtDateTime.text = selectedExam.examDateTime.toString()
            txtLocation.text = selectedExam.examLocation
        }
        else {
            title = "Add Exam"
        }
        
        
        //Add notification observers
        NotificationCenter.default.addObserver(self, selector: #selector(addExamSuccess), name: Notification.Name("AddExamSuccess"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(addExamFailed), name: Notification.Name("AddExamFailed"), object: nil)
        
        //Formatting
        btnSave.layer.cornerRadius = btnSave.frame.height / 2
        btnSave.layer.masksToBounds = true
        
        //Add gesture to dismiss keyboard when user taps outside of textfield
        
        let gesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        gesture.numberOfTapsRequired = 1
        view.addGestureRecognizer(gesture)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self, name: Notification.Name("AddExamtSuccess"), object: nil)
        NotificationCenter.default.removeObserver(self, name: Notification.Name("AddExamFailed"), object: nil)
    }

    @IBAction func selectDateAction(_ sender: UIButton) {
        txtExamName.resignFirstResponder()
        showHideDateSelectionView(true)
    }
    @IBAction func saveExamAction(_ sender: UIButton) {
        let validationStage = validateDetails()
        
        switch validationStage {
        case .valid:
            if isEditingExam {
                //Update exam info
                DatabaseManager.updateExam(withObjectId: selectedExam.objectID, examName: txtExamName.text!, dateTime: pickerExamDate.date, location: txtLocation.text!)
            }
            else {
                //Save exam info
                DatabaseManager.saveExam(examName: txtExamName.text!, dateTime: pickerExamDate.date, location: txtLocation.text!)
            }
            
        case .invalid(let errorMessage):
            presentAlert(withTitle: errorMessage, message: "")
        }

    }
    @IBAction func dateSelected(_ sender: UIDatePicker) {
        txtDateTime.text = pickerExamDate.date.toString()
    }
    @IBAction func cancelDateSelection(_ sender: UIButton) {
        showHideDateSelectionView(false)
    }
    @IBAction func doneDateSelection(_ sender: UIButton) {
        showHideDateSelectionView(false)
    }
    
    //MARK: Custom Methods
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    func validateDetails() -> ValidateData {
        if (txtExamName.text?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)! {
            return .invalid("Please enter exam name.")
        }
        else if (txtDateTime.text?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)! {
            return .invalid("Please select exam date.")
        }
        else if (txtLocation.text?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)! {
            return .invalid("Please enter exam location.")
        }
            
        else {
            return .valid
        }
        
    }
    func showHideDateSelectionView(_ isShow: Bool) {
        if isShow {
            viewPickerBottomConstraint.constant = 0
            
            //Select first row by default
            
        }
        else {
            if #available(iOS 11.0, *) {
                viewPickerBottomConstraint.constant = -(viewExamDatePicker.frame.height + view.safeAreaInsets.bottom)
            } else {
                // Fallback on earlier versions
                viewPickerBottomConstraint.constant = -viewExamDatePicker.frame.height
            }
        }
        
        UIView.animate(withDuration: 0.5) {
            self.view.layoutIfNeeded()
        }
    }
    
    @objc func addExamSuccess(){
        navigationController?.popViewController(animated: true)
    }
    @objc func addExamFailed() {
        self.presentAlert(withTitle: "Unable to save exam in core data.", message: "An error occured.")
    }

}

extension AddExamViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    func textFieldDidEndEditing(_ textField: UITextField) {
        textField.resignFirstResponder()
    }
}
