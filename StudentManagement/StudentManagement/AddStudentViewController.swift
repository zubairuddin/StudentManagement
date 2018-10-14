//
//  AddStudentViewController.swift
//  StudentManagement
//
//  Created by Zubair.Nagori on 11/10/18.
//  Copyright © 2018 joseph. All rights reserved.
//

import UIKit


//Validation Enum
enum ValidateData {
    case invalid(String)
    case valid
}

class AddStudentViewController: UIViewController {

    //Outlets
    @IBOutlet weak var imgUserImage: UIImageView!
    @IBOutlet weak var txtStudentId: UITextField!
    @IBOutlet weak var txtFirstName: UITextField!
    @IBOutlet weak var txtLastName: UITextField!
    @IBOutlet weak var txtCourse: UITextField!
    @IBOutlet weak var segmentGender: UISegmentedControl!
    @IBOutlet weak var stepperAge: UIStepper!
    @IBOutlet weak var lblAge: UILabel!
    @IBOutlet weak var btnSave: UIButton!
    @IBOutlet weak var txtCity: UITextField!
    @IBOutlet weak var txtStreet: UITextField!
    
    //Instance variables
    var gender = "Male"
    var age: Int64!
    
    var selectedStudent: Student!
    var isEditingStudent = false
    
    //MARK: View Lifecycle methods
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        if isEditingStudent {
            //Set up the delete student button
            let deleteButton = UIBarButtonItem(barButtonSystemItem: .trash, target: self, action: #selector(deleteStudent))
            navigationItem.rightBarButtonItem = deleteButton
            
            //Show Student's name on the title
            title = selectedStudent.firstName + " " + selectedStudent.lastName
            
            //Show the data for the selected student
            txtStudentId.becomeFirstResponder()
            
            txtStudentId.text = selectedStudent.studentId
            txtFirstName.text = selectedStudent.firstName
            txtLastName.text = selectedStudent.lastName
            txtCourse.text = selectedStudent.courseStudy
            txtCity.text = selectedStudent.city
            txtStreet.text = selectedStudent.street
            
            if let imgData = selectedStudent.image {
                imgUserImage.image = UIImage(data: imgData)
            }
            
            age = selectedStudent.age
            gender = selectedStudent.gender
            lblAge.text = "Age: \(age!)"
            stepperAge.value = Double(age)
            segmentGender.selectedSegmentIndex = gender == "Male" ? 0 : 1
        }
            
        else {
            title = "Add Student"
        }
        
        age = Int64(stepperAge.value)
        formatControls()
        
    }
    override func viewWillAppear(_ animated: Bool) {
        //Add notification observers
        NotificationCenter.default.addObserver(self, selector: #selector(addStudentSuccess), name: Notification.Name("AddStudentSuccess"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(addStudentFailed(notification:)), name: Notification.Name("AddStudentFailed"), object: nil)

    }
    
    override func viewDidDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self, name: Notification.Name("AddStudentSuccess"), object: nil)
        NotificationCenter.default.removeObserver(self, name: Notification.Name("AddStudentFailed"), object: nil)
    }
    
    //MARK: Actions
    @IBAction func saveStudentAction(_ sender: UIButton) {
        let validationStage = validateDetails()
        
        switch validationStage {
        case .valid:
            //Save user Info
            
            var userImageData: Data!
            if let profileImage = self.imgUserImage.image, let imageData = profileImage.jpegData(compressionQuality: 0.1)  {
                userImageData = imageData
            }
            
            if isEditingStudent {
                DatabaseManager.updateStudent(withObjectId: selectedStudent.objectID, studentId: txtStudentId.text!, firstName: txtFirstName.text!, lastName: txtLastName.text!, gender: gender, age: age, courseStudy: txtCourse.text!, city: txtCity.text!, street: txtStreet.text! ,imageData: userImageData)

            }
            else {
                DatabaseManager.saveStudent(studentId: txtStudentId.text!, firstName: txtFirstName.text!, lastName: txtLastName.text!, gender: gender, age: age, courseStudy: txtCourse.text!, city: txtCity.text!, street: txtStreet.text!, imageData: userImageData)

            }
            
        case .invalid(let errorMessage):
            presentAlert(withTitle: errorMessage, message: "")
        }
        
    }
    
    @IBAction func selectImageAction(_ sender: UIButton) {
        
        let alert = UIAlertController(title: "Select Profile Image", message: nil, preferredStyle: .actionSheet)
        let cameraAction = UIAlertAction(title: "Camera", style: .default) { (action) in
            self.openCamera()
        }
        let galleryAction = UIAlertAction(title: "Photo Library", style: .default) { (action) in
            self.openPhotoLibrary()
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (action) in
        }
        
        alert.addAction(cameraAction)
        alert.addAction(galleryAction)
        alert.addAction(cancelAction)
        
        present(alert, animated: true, completion: nil)
    }
    
    @IBAction func genderSelected(_ sender: UISegmentedControl) {
        gender = sender.selectedSegmentIndex == 0 ? "Male" : "Female"
    }
    
    @IBAction func ageChanged(_ sender: UIStepper) {
        age =  Int64(sender.value)
        lblAge.text = "Age: \(age!)"
    }
    @IBAction func showAddressOnMap(_ sender: UIButton) {
        let vc = storyboard?.instantiateViewController(withIdentifier: "AddressOnMapViewController") as! AddressOnMapViewController
        
        if (txtCity.text?.isEmpty)! || (txtStreet.text?.isEmpty)! {
            presentAlert(withTitle: "Invalid address.", message: "Please fill all address fields.")
        }
        
        let fullAddress = txtStreet.text! + " " + txtCity.text! + " "
        vc.strAddress = fullAddress
        navigationController?.pushViewController(vc, animated: true)
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
        else if (txtCity.text?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)! {
            return .invalid("Please enter city.")
        }
        else if (txtStreet.text?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)! {
            return .invalid("Please enter street.")
        }

            
        else {
            return .valid
        }
        
    }
    func formatControls() {
        btnSave.layer.cornerRadius = btnSave.frame.height / 2
        btnSave.layer.masksToBounds = true
    }
    
    private func openCamera() {
        //Instantiate UIImagePickerController
        let picker = UIImagePickerController()
        picker.delegate = self
        //picker.allowsEditing = true
        
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            //Show UIImagePicker with Camera
            picker.sourceType = .camera
            present(picker, animated: true, completion: nil)
        }
        else {
            //Show Alert
            let alert  = UIAlertController(title: "Warning", message: "Camera not available", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    private func openPhotoLibrary() {
        //Instantiate UIImagePickerController
        let picker = UIImagePickerController()
        picker.delegate = self
        //picker.allowsEditing = true
        picker.sourceType = .photoLibrary
        present(picker, animated: true, completion: nil)
    }

    @objc func addStudentSuccess(){
        print("Pop to student list")
        navigationController?.popViewController(animated: true)
    }
    @objc func addStudentFailed(notification: NSNotification) {
        
        let userInfo = notification.userInfo
        
        if let message = userInfo?["message"] as? String {
            self.presentAlert(withTitle: "Unable to Save.", message: message)
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

//MARK: - UIImagePickerController delegate
extension AddStudentViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        print(info)
        
        var selectedImage: UIImage?
        
        if let editedImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
            selectedImage = editedImage
        }
        else if let originalImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            selectedImage = originalImage
        }
        
        if let image = selectedImage {
            imgUserImage.image = image
        }
        
        dismiss(animated: true, completion: nil)
        
    }
}
