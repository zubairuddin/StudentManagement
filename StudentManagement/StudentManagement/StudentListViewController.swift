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
    }
    override func viewWillAppear(_ animated: Bool) {
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
    
    //MARK: Actions
    @IBAction func addStudentTapped(_ sender: UIBarButtonItem) {
        let vc = storyboard?.instantiateViewController(withIdentifier: "AddStudentViewController") as! AddStudentViewController
        navigationController?.pushViewController(vc, animated: true)
    }
    
    //MARK: Custom Methods
}

extension StudentListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrStudents.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "StudentListCell", for: indexPath) as! StudentListCell

        let student = arrStudents[indexPath.row]

        cell.lblStudentName.text = student.firstName + " " + student.lastName
        
        return cell
    }
}

extension StudentListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        //Get the selected student
        let selectedStudent = arrStudents[indexPath.row]
        
        let vc = storyboard?.instantiateViewController(withIdentifier: "StudentDetailViewController") as! StudentDetailViewController
        vc.selectedStudent = selectedStudent
        
        navigationController?.pushViewController(vc, animated: true)
    }
}
