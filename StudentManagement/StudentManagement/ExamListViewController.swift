//
//  ExamListViewController.swift
//  StudentManagement
//
//  Created by Zubair.Nagori on 11/10/18.
//  Copyright © 2018 joseph. All rights reserved.
//

import UIKit
import Foundation

class ExamListViewController: UIViewController {

    //Outlets
    @IBOutlet weak var tblExams: UITableView!
    @IBOutlet weak var lblNoExam: UILabel!
    
    //This array will hold all the exams
    var arrExams = [Exams]()
    
    //MARK: View Lifecycle methods
    //This method is called when the view first loads
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        self.title = "Exams"
        
        //Add bar buttons
        let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addNewExam))
        let deleteButton = UIBarButtonItem(barButtonSystemItem: .trash, target: self, action: #selector(deleteExams))
        
        let awardsButton = UIBarButtonItem(image: UIImage(named: "award"), style: .plain, target: self, action: #selector(showStudentExamsView))
        
        navigationItem.rightBarButtonItems = [addButton,deleteButton,awardsButton]
        
    }
    
    //This method is called when the view is about to appear
    override func viewWillAppear(_ animated: Bool) {
        refreshTable()
    }

    //MARK: Custom Methods
    
    //Used to refresh the exam list view
    func refreshTable() {
        
        //Get all the exams from the DB
        arrExams = DatabaseManager.getAllExams()
        
        if arrExams.count > 0 {
            tblExams.isHidden = false
            lblNoExam.isHidden = true
            tblExams.reloadData()
        }
        else {
            tblExams.isHidden = true
            lblNoExam.isHidden = false
        }
        
        tblExams.reloadData()
    }
    
    //This function will take to the add new exam screen
    @objc func addNewExam() {
        let vc = storyboard?.instantiateViewController(withIdentifier: "AddExamViewController") as! AddExamViewController
        navigationController?.pushViewController(vc, animated: true)
    }
    
    //Show exams for the student
    @objc func showStudentExamsView() {
        let vc = storyboard?.instantiateViewController(withIdentifier: "StudentExamsViewController") as! StudentExamsViewController
        navigationController?.pushViewController(vc, animated: true)
        
    }

    //Alert the user before deleting exam(s)
    @objc func deleteExams() {
        
        let arrSelectedExams = DatabaseManager.getSelectedExams()
        
        if arrSelectedExams.count > 0 {
            let alertController = UIAlertController(title: "Are you sure you want to delete selected exams?", message: nil, preferredStyle: .alert)
            let yesAction = UIAlertAction(title: "Yes", style: .default) { (action) in
                self.deleteSelectedExamsFromCoreData(exams: arrSelectedExams)
            }
            let noAction = UIAlertAction(title: "No", style: .cancel, handler: nil)
            alertController.addAction(yesAction)
            alertController.addAction(noAction)
            self.present(alertController, animated: true, completion: nil)

        }
        else {
            presentAlert(withTitle: "No Exams Selected.", message: "Please select exams that you want to delete.")
        }
    }
    
    //Delete the selected exam(s) from core data
    func deleteSelectedExamsFromCoreData(exams: [Exams]) {
        
        for exam in exams {
            KAPPDELEGATE.persistentContainer.viewContext.delete(exam)
            
            do {
                try KAPPDELEGATE.persistentContainer.viewContext.save()
                refreshTable()
            }
            catch let error {
                print("Unable to delete exams \(error.localizedDescription)")
            }
        }
    }
    
    //Called when the checkbox for an exam is selected/deselected
    @objc func examCheckBoxTapped(sender: UIButton) {
        print(sender.tag)
        sender.isSelected = !sender.isSelected
        
        let selectedExam = arrExams[sender.tag]
        
        print("Selected exam is \(selectedExam.examName)")
        if sender.isSelected {
            selectedExam.isSelectedForDelete = true
        }
        else {
            selectedExam.isSelectedForDelete = false
        }
    }
}


extension ExamListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrExams.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ExamListCell", for: indexPath) as! ExamListCell
        
        cell.btnCheckUncheck.tag = indexPath.row
        cell.btnCheckUncheck.addTarget(self, action: #selector(examCheckBoxTapped(sender:)), for: .touchUpInside)
        
        
        let exam = arrExams[indexPath.row]
        cell.lblExamName.text = exam.examName
        cell.lblLocation.text = exam.examLocation
        
        let strExamDateTime = exam.examDate.toStringDate() + " " + exam.examTime.toStringTime()
        cell.lblDateAndTime.text = strExamDateTime
        cell.btnCheckUncheck.isSelected = exam.isSelectedForDelete
        
        //Diffrentiating between past and future dates
        if exam.examDate.isInPast() {
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
extension ExamListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //Get the selected exam
        let selectedExam = arrExams[indexPath.row]
        
        let vc = storyboard?.instantiateViewController(withIdentifier: "AddExamViewController") as! AddExamViewController
        vc.selectedExam = selectedExam
        vc.isEditingExam = true
        
        navigationController?.pushViewController(vc, animated: true)

    }
}
