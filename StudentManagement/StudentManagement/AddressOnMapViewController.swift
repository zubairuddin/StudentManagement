//
//  AddressOnMapViewController.swift
//  StudentManagement
//
//  Created by Zubair on 14/10/18.
//  Copyright © 2018 joseph. All rights reserved.
//

import UIKit
import MapKit
class AddressOnMapViewController: UIViewController {

    @IBOutlet weak var mapViewAddress: MKMapView!
    
    var strAddress: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        title = "Student Address"
        
        showAddressOnMap()
    }
    
    func showAddressOnMap() {
        
        guard let location = strAddress else {
            presentAlert(withTitle: "No address.", message: "")
            return
        }
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(location) { [weak self] placemarks, error in
            
            if error != nil {
                print("Address not found! \(error!.localizedDescription)")
                self?.presentAlert(withTitle: "Address not found.", message: "")
                return
            }
            
            if let placemark = placemarks?.first, let location = placemark.location {
                let mark = MKPlacemark(placemark: placemark)
                
                if var region = self?.mapViewAddress.region {
                    region.center = location.coordinate
                    region.span.longitudeDelta /= 8.0
                    region.span.latitudeDelta /= 8.0
                    self?.mapViewAddress.setRegion(region, animated: true)
                    self?.mapViewAddress.addAnnotation(mark)
                }
            }
            else {
                self?.presentAlert(withTitle: "An error occured.", message: "")
                print("Location not found!")
            }
        }
    }
    
}
