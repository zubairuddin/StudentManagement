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
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    @IBAction func selectDateAction(_ sender: UIButton) {
        showHideDateSelectionView(true)
    }
    @IBAction func saveExamAction(_ sender: UIButton) {
    }
    @IBAction func dateSelected(_ sender: UIDatePicker) {
    }
    @IBAction func cancelDateSelection(_ sender: UIButton) {
        showHideDateSelectionView(false)
    }
    @IBAction func doneDateSelection(_ sender: UIButton) {
        showHideDateSelectionView(false
    }
    
    //MARK: Custom Methods
    func showHideDateSelectionView(_ isShow: Bool) {
        if isShow {
            viewPickerBottomConstraint.constant = 0
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
}
