//
//  DetailsViewController.swift
//  Places
//
//  Created by Mohsin Khawas on 3/11/18.
//  Copyright © 2018 Mohsin Khawas. All rights reserved.
//

import UIKit
//Simple DetailsViewController, fetches the icon in background and displays as well.
class DetailsViewController: UIViewController {
    
    @IBOutlet weak var placeName: UILabel!
    @IBOutlet weak var placeImageView: UIImageView!
    @IBOutlet weak var placeRating: UILabel!
    @IBOutlet weak var typeOfEstablishment: UITextView!
    
    func loadDetailView(_ place: Locations.Place){
        self.placeName.text = place.name

        if let rating = place.rating {
            if (rating > 0){
                self.placeRating.text = "\(String(format:"Rating: %.1f", rating))/5.0"
            }
        }else{
            self.placeRating.text = "Not rated yet."
        }
        
        self.typeOfEstablishment.text = "Type of Establishment: " + place.types.joined(separator: ",")
        self.downloadIconImage(urlPath: place.icon)
        }
    
    func downloadIconImage(urlPath: String){
        let imageUrl:URL = URL(string: urlPath)!
        
        //Background thread so that image loading does not make app unresponsive
        DispatchQueue.global(qos: .userInitiated).async {
            let imageData:NSData = NSData(contentsOf: imageUrl)!
            
            // When from background thread, UI needs to be updated on main_queue
            DispatchQueue.main.async {
                if let image = UIImage(data: imageData as Data) {
                    self.placeImageView.image = image
                }
            }
        }
    }
}
