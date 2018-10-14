//
//  HomeViewController.swift
//  StudentManagement
//
//  Created by Zubair on 12/10/18.
//  Copyright © 2018 joseph. All rights reserved.
//

import UIKit

class HomeViewController: UIViewController {

    @IBOutlet weak var viewStudent: UIView!
    @IBOutlet weak var viewExams: UIView!
    @IBOutlet weak var viewImages: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.title = "Home"
        
        //Cornering view radius
        cornerViewRadius(sourceView: viewStudent)
        cornerViewRadius(sourceView: viewExams)
        cornerViewRadius(sourceView: viewImages)
    }
    
    @IBAction func studentsTapped(_ sender: UIButton) {
        let vc = storyboard?.instantiateViewController(withIdentifier: "StudentListViewController") as! StudentListViewController
        navigationController?.pushViewController(vc, animated: true)
    }
    @IBAction func examsTapped(_ sender: UIButton) {
        let vc = storyboard?.instantiateViewController(withIdentifier: "ExamListViewController") as! ExamListViewController
        navigationController?.pushViewController(vc, animated: true)

    }
    @IBAction func imagesTapped(_ sender: UIButton) {
        let vc = storyboard?.instantiateViewController(withIdentifier: "AddImagesViewController") as! AddImagesViewController
        navigationController?.pushViewController(vc, animated: true)

    }
    
    //MARK: Custom Methods
    func cornerViewRadius(sourceView: UIView) {
        sourceView.layer.cornerRadius = 10
        sourceView.layer.masksToBounds = true
    }
}
