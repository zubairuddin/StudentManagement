//
//  StudentExamsViewController.swift
//  StudentManagement
//
//  Created by Zubair on 13/10/18.
//  Copyright © 2018 joseph. All rights reserved.
//

import UIKit

class StudentExamsViewController: UIViewController {

    var arrExams = [Exams]()
    var arrAllStudents = [Student]()
    var selectedStudent: Student?
    
    @IBOutlet weak var btnSelectStudent: UIButton!
    @IBOutlet weak var lblNoExam: UILabel!
    @IBOutlet weak var tblExams: UITableView!
    @IBOutlet weak var pickerStudentSelection: UIPickerView!
    @IBOutlet weak var viewPickerContainer: UIView!
    @IBOutlet weak var viewPickerBottomConstraint: NSLayoutConstraint!

    //MARK: View Lifecycle methods
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        arrAllStudents = DatabaseManager.getAllStudents()
        
        tblExams.isHidden = true
        lblNoExam.isHidden = false
        lblNoExam.text = "Please Select a Student!"
        
        self.title = "Exams"
        
        //Add bar buttons
        let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(assignExam))
        let deleteButton = UIBarButtonItem(barButtonSystemItem: .trash, target: self, action: #selector(deleteExamsTapped))
        
        navigationItem.rightBarButtonItems = [addButton, deleteButton]
        
        //Formating
        btnSelectStudent.layer.cornerRadius = btnSelectStudent.frame.height / 2
        btnSelectStudent.layer.masksToBounds = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        refreshTable()
    }
    override func viewDidDisappear(_ animated: Bool) {
        setIsSelectedForDeleteFalse()
    }
    
    //MARK: Actions
    
    @IBAction func selectStudentTapped(_ sender: UIButton) {
        
        if arrAllStudents.count > 0 {
            showHideStudentSelectionView(true)
        }
        else {
            presentAlert(withTitle: "No Students Found.", message: "Please add some students first.")
        }
        
    }
    @IBAction func cancelStudentSelection(_ sender: UIButton) {
        showHideStudentSelectionView(false)
    }
    @IBAction func doneStudentSelection(_ sender: UIButton) {
        showHideStudentSelectionView(false)
        
        //Get the student detail along with exams relationship
        
        refreshTable()
    }
    
    //MARK: Custom Methods
    
    func refreshTable() {
        guard let student = selectedStudent else {
            return
        }
        
        guard let studentDetail = DatabaseManager.getStudentDetail(withObjectId: student.objectID) else {
            return
        }
        
        let name = student.firstName + " " + student.lastName
        
        btnSelectStudent.setTitle(name, for: .normal)
        
        arrExams = studentDetail.exams?.allObjects as! [Exams]
        
        if arrExams.count > 0 {
            tblExams.isHidden = false
            lblNoExam.isHidden = true
            tblExams.reloadData()
        }
        else {
            tblExams.isHidden = true
            lblNoExam.isHidden = false
            lblNoExam.text = "No Exams Found!"
            
        }

    }
    func showHideStudentSelectionView(_ isShow: Bool) {
        if isShow {
            viewPickerBottomConstraint.constant = 0
            
            //Select first row by default
            let row = pickerStudentSelection.selectedRow(inComponent: 0)
            pickerView(pickerStudentSelection, didSelectRow: row, inComponent:0)
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
    func setIsSelectedForDeleteFalse() {
        let arrExams = DatabaseManager.getAllExams()
        
        for exam in arrExams {
            exam.isSelectedForDelete = false
        }
        
        do {
            try KAPPDELEGATE.persistentContainer.viewContext.save()
        }
        catch let error {
            print("Unable to set isSelectedForDelete to false: \(error.localizedDescription)")
        }
    }
    
    @objc func assignExam() {
        let vc = storyboard?.instantiateViewController(withIdentifier: "AssignExamToStudentViewController") as! AssignExamToStudentViewController
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc func checkboxClicked(sender: UIButton) {
        sender.isSelected = !sender.isSelected
        
        let exam = arrExams[sender.tag]
        
        if sender.isSelected {
            exam.isSelectedForDelete = true
        }
        else {
            exam.isSelectedForDelete = false
        }
        
    }
    @objc func deleteExamsTapped() {
        deleteSelectedExamsForStudentFromCoreData()
    }
    
    @objc func deleteSelectedExamsForStudentFromCoreData() {
        
        let filteredSelectedExams = arrExams.filter { (exam) -> Bool in
            return exam.isSelectedForDelete == true
        }
        
        guard let student = selectedStudent else {
            return
        }
        
        for exam in filteredSelectedExams {
            student.removeFromExams(exam)
        }
        
        do {
            try KAPPDELEGATE.persistentContainer.viewContext.save()
            
            refreshTable()
        }
        catch let error {
            print("Unable to delete :\(error.localizedDescription)")
        }
    }

}

extension StudentExamsViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrExams.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "StudentExamsCell", for: indexPath) as! StudentExamsCell
        cell.btnCheckUncheck.tag = indexPath.row
        
        let exam = arrExams[indexPath.row]
        cell.lblExamName.text = exam.examName
        
        let strExamDateTime = exam.examDate.toStringDate() + " " + exam.examTime.toStringTime()
        cell.lblExameDateTime.text = strExamDateTime
        cell.lblExamLocation.text = exam.examLocation
        
        cell.btnCheckUncheck.addTarget(self, action: #selector(checkboxClicked(sender:)), for: .touchUpInside)
        
        //Diffrentiating between past and future dates
        if exam.examDate.isInPast() || exam.examTime.isInPast()  {
            cell.lblUpcomingOrPast.text = "Past"
            cell.lblUpcomingOrPast.textColor = .red
        }
        else {
            cell.lblUpcomingOrPast.text = "Upcoming"
            cell.lblUpcomingOrPast.textColor = .green
            
        }

        return cell
    }
}

extension StudentExamsViewController: UIPickerViewDelegate {
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        if arrAllStudents.count > 0 {
            selectedStudent = arrAllStudents[row]
        }
        
    }
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return arrAllStudents[row].firstName + " " + arrAllStudents[row].lastName
    }
    
}
extension StudentExamsViewController: UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return arrAllStudents.count
    }
}
