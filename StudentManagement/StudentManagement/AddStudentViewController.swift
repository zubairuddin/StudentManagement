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
    
    //This will be called when the view has loaded
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
    
    //This will be called when the view is about to appear
    override func viewWillAppear(_ animated: Bool) {
        //Add notification observers
        NotificationCenter.default.addObserver(self, selector: #selector(addStudentSuccess), name: Notification.Name("AddStudentSuccess"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(addStudentFailed(notification:)), name: Notification.Name("AddStudentFailed"), object: nil)

    }
    
    //This will be called when the view has disappeared
    override func viewDidDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self, name: Notification.Name("AddStudentSuccess"), object: nil)
        NotificationCenter.default.removeObserver(self, name: Notification.Name("AddStudentFailed"), object: nil)
    }
    
    //MARK: Actions
    
    //Save student function
    @IBAction func saveStudentAction(_ sender: UIButton) {
        let validationStage = validateDetails()
        
        switch validationStage {
            
            //Validate that user has entered all the data required for the student
        case .valid:
            //Save user Info
            
            //Convert image to binary data so that it can be saved in core data
            var userImageData: Data!
            if let profileImage = self.imgUserImage.image, let imageData = profileImage.jpegData(compressionQuality: 0.1)  {
                userImageData = imageData
            }
            
            //If user is updating the student detail, call updateStudent function and update the detail of the existing student
            if isEditingStudent {
                DatabaseManager.updateStudent(withObjectId: selectedStudent.objectID, studentId: txtStudentId.text!, firstName: txtFirstName.text!, lastName: txtLastName.text!, gender: gender, age: age, courseStudy: txtCourse.text!, city: txtCity.text!, street: txtStreet.text! ,imageData: userImageData)

            }
                
            //If user is adding a new student, call saveStudent method and save the new student in the DB
            else {
                DatabaseManager.saveStudent(studentId: txtStudentId.text!, firstName: txtFirstName.text!, lastName: txtLastName.text!, gender: gender, age: age, courseStudy: txtCourse.text!, city: txtCity.text!, street: txtStreet.text!, imageData: userImageData)

            }
            
        case .invalid(let errorMessage):
            presentAlert(withTitle: errorMessage, message: "")
        }
        
    }
    
    //This is called when the user taps on the profile image to select an image
    @IBAction func selectImageAction(_ sender: UIButton) {
        
        //When user taps on the image to select image for the student, show options for taking a new image from camera or selecting an existing image from gallery
        
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
    
    //This is called when the user changes the segmented control to select gender of student.
    @IBAction func genderSelected(_ sender: UISegmentedControl) {
        gender = sender.selectedSegmentIndex == 0 ? "Male" : "Female"
    }
    
    //This is called when the user increments or decrements age from stepper
    @IBAction func ageChanged(_ sender: UIStepper) {
        age =  Int64(sender.value)
        lblAge.text = "Age: \(age!)"
    }
    
    //This is called when the user taps on the pin icon to show student's address on the map
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
    
    //This function validates that user enters alll the data required to add an student in DB
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
    
    //This function rounds the corners of the save button
    func formatControls() {
        btnSave.layer.cornerRadius = btnSave.frame.height / 2
        btnSave.layer.masksToBounds = true
    }
    
    //This function will open camera if running on a physical iPhone device
    private func openCamera() {
        //Instantiate UIImagePickerController
        let picker = UIImagePickerController()
        picker.delegate = self
        
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
    
    //This function will open gallery of iPhone or iPhone simulator
    private func openPhotoLibrary() {
        //Instantiate UIImagePickerController
        let picker = UIImagePickerController()
        picker.delegate = self
        //picker.allowsEditing = true
        picker.sourceType = .photoLibrary
        present(picker, animated: true, completion: nil)
    }

    //This function notifies that new student has been added successfully
    @objc func addStudentSuccess(){
        print("Pop to student list")
        navigationController?.popViewController(animated: true)
    }
    
    //This function notifies that the student could not be added due to some error
    @objc func addStudentFailed(notification: NSNotification) {
        
        let userInfo = notification.userInfo
        
        if let message = userInfo?["message"] as? String {
            self.presentAlert(withTitle: "Unable to Save.", message: message)
        }
        
    }
    
    //This function is called when the user taps on the delete button on top right
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
    
    //This function deletes the student from DB
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
    
    //This function is called when user cancels image selection
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    //This function is called when the user has selected the image for student
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        print(info)
        
        var selectedImage: UIImage?
        
        //Get the selected image
        if let originalImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            selectedImage = originalImage
        }
        
        //Set the image
        if let image = selectedImage {
            imgUserImage.image = image
        }
        
        dismiss(animated: true, completion: nil)
        
    }
}
