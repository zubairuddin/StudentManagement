//
//  AddImagesViewController.swift
//  StudentManagement
//
//  Created by joseph on 13/10/18.
//  Copyright © 2018 joseph. All rights reserved.
//

import UIKit

class AddImagesViewController: UIViewController {

    @IBOutlet weak var btnAddImage: UIButton!
    @IBOutlet weak var btnSelectStudent: UIButton!
    @IBOutlet weak var pickerStudent: UIPickerView!
    @IBOutlet weak var viewPicker: UIView!
    @IBOutlet weak var viewPickerBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var imgUserImage: UIImageView!
    
    var arrAllStudents = [Student]()
    var selectedStudent: Student?
    var imageData: Data?

    //MARK: View Lifecycle methods
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        arrAllStudents = DatabaseManager.getAllStudents()
        
        self.title = "Add Image"
        cornerViewRadius(sourceView: btnSelectStudent)
        cornerViewRadius(sourceView: btnAddImage)
    }
    
    //MARK: Actions
    
    //Called when user cancels image selection
    @IBAction func cancelTapped(_ sender: UIButton) {
        showHidePickerView(false)
    }
    
    //Called when user confirms image selection
    @IBAction func doneTapped(_ sender: UIButton) {
        showHidePickerView(false)
        
        guard let student = selectedStudent else {
            return
        }
        
        let name = student.firstName + " " + student.lastName
        btnSelectStudent.setTitle(name, for: .normal)
    }
    
    //Opens the action sheet to give user options for picking image from galllery or taking a new one from camera
    @IBAction func selectImage(_ sender: UIButton) {
        let alert = UIAlertController(title: "Select Image", message: nil, preferredStyle: .actionSheet)
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
    
    //Called when select student button is tapped
    @IBAction func selectStudentButtonTapped(_ sender: UIButton) {
        showHidePickerView(true)
    }
    
    //Add image button is tapped
    @IBAction func addImage(_ sender: UIButton) {
        
        //Convert image to binary data in order to save it in DB
        guard let data = imageData else {
            presentAlert(withTitle: "Please select an image.", message: "")
            return
        }
        
        //Get the selected student to which image is to be assigned
        guard let student = selectedStudent else {
            presentAlert(withTitle: "Please select a student.", message: "")
            return
        }
        
        //Assign the image to the student
        student.image = data
        
        do {
            try KAPPDELEGATE.persistentContainer.viewContext.save()
            print("Saved Image Successfully!")
            
            let alertController = UIAlertController(title: "Image saved successfully", message: nil, preferredStyle: .alert)
            let okAction = UIAlertAction(title: "OK", style: .default) { (action) in
                self.navigationController?.popViewController(animated: true)
            }
            
            alertController.addAction(okAction)
            self.present(alertController, animated: true, completion: nil)
        }
            
        catch let error {
            print("Unable to set image: \(error.localizedDescription)")
        }
        
    }
    
    //MARK: Custom Methods
    func showHidePickerView(_ isShow: Bool) {
        if isShow {
            viewPickerBottomConstraint.constant = 0
            
            //Select first row by default
            let row = pickerStudent.selectedRow(inComponent: 0)
            pickerView(pickerStudent, didSelectRow: row, inComponent:0)
            
        }
        else {
            if #available(iOS 11.0, *) {
                viewPickerBottomConstraint.constant = -(viewPicker.frame.height + view.safeAreaInsets.bottom)
            } else {
                // Fallback on earlier versions
                viewPickerBottomConstraint.constant = -viewPicker.frame.height
            }
        }
        
        UIView.animate(withDuration: 0.5) {
            self.view.layoutIfNeeded()
        }
    }
    
    //Adds a nice corner radius to buttons
    func cornerViewRadius(sourceView: UIView) {
        sourceView.layer.cornerRadius = sourceView.frame.height / 2
        sourceView.layer.masksToBounds = true
    }
    
    //This function will open devece's camera
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
    
    //This function will open photo library
    private func openPhotoLibrary() {
        //Instantiate UIImagePickerController
        let picker = UIImagePickerController()
        picker.delegate = self
        //picker.allowsEditing = true
        picker.sourceType = .photoLibrary
        present(picker, animated: true, completion: nil)
    }

}


extension AddImagesViewController: UIPickerViewDelegate {
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        if arrAllStudents.count > 0 {
            selectedStudent = arrAllStudents[row]
        }
        
    }
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return arrAllStudents[row].firstName + " " + arrAllStudents[row].lastName
    }
    
}
extension AddImagesViewController: UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return arrAllStudents.count
    }
}

extension AddImagesViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [String : Any]) {
        guard let image = info[UIImagePickerControllerOriginalImage] as? UIImage else {
            return
        }
        
        imgUserImage.image = image
        
        guard let imgData = UIImageJPEGRepresentation(image, 0.1) else {
            return
        }
        
        imageData = imgData
        
        dismiss(animated: true, completion: nil)
    }

}
