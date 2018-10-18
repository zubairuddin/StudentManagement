//
//  ViewController.swift
//  StudentManagement
//
//  Created by Zubair.Nagori on 11/10/18.
//  Copyright © 2018 joseph. All rights reserved.
//

import UIKit

class StudentListViewController: UIViewController {

    //Students array
    var arrStudents = [Student]()
    
    //MARK: Outlets
    @IBOutlet weak var tblStudents: UITableView!
    @IBOutlet weak var lblNoStudents: UILabel!
    
    //MARK: View Lifecycle methods
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        //Add bar buttons
        let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addNewStudent))
        let assignExamButton = UIBarButtonItem(image: UIImage(named: "exam"), style: .plain, target: self, action: #selector(assignExamToStudent))
        
        navigationItem.rightBarButtonItems = [addButton, assignExamButton]
    }
    override func viewWillAppear(_ animated: Bool) {
        
        //Get all the students from the database.
        arrStudents = DatabaseManager.getAllStudents()
        
        if arrStudents.count > 0 {
            tblStudents.isHidden = false
            lblNoStudents.isHidden = true
            tblStudents.reloadData()
        }
        else {
            tblStudents.isHidden = true
            lblNoStudents.isHidden = false
        }
    }
    
    //MARK: Custom Methods
    
    //This function will take us to add new student screen
    @objc func addNewStudent() {
        let vc = storyboard?.instantiateViewController(withIdentifier: "AddStudentViewController") as! AddStudentViewController
        navigationController?.pushViewController(vc, animated: true)

    }
    
    //This function will take us to the screen where we can assign exams to students
    @objc func assignExamToStudent() {
        let vc = storyboard?.instantiateViewController(withIdentifier: "AssignExamToStudentViewController") as! AssignExamToStudentViewController
        navigationController?.pushViewController(vc, animated: true)
    }
    
}

extension StudentListViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrStudents.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "StudentListCell", for: indexPath) as! StudentListCell

        let student = arrStudents[indexPath.row]

        cell.lblStudentName.text = student.firstName + " " + student.lastName
        
        if let imgData = student.image, let image = UIImage(data: imgData) {
            cell.imgStudentImage.image = image
        }

        
        print("Height = \(cell.imgStudentImage.frame.height)")
        print("Width = \(cell.imgStudentImage.frame.width)")
        
        return cell
    }
}

extension StudentListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        //Get the selected student
        let selectedStudent = arrStudents[indexPath.row]
                
        let vc = storyboard?.instantiateViewController(withIdentifier: "AddStudentViewController") as! AddStudentViewController

        vc.selectedStudent = selectedStudent
        vc.isEditingStudent = true
        
        navigationController?.pushViewController(vc, animated: true)
    }
}
