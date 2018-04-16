//
//  GooglePlacesTransactions.swift
//  Places
//
//  Created by Mohsin Khawas on 3/11/18.
//  Copyright © 2018 Mohsin Khawas. All rights reserved.
//

import Foundation

private let kGoogleAPIKey = "AIzaSyBZSVXX8QCLotLiBcyWjvRdY9Mk_C8cnWA"
private let kURLGoogleSearch = "https://maps.googleapis.com/maps/api/place/nearbysearch/json"

class GooglePlacesAPI {
    
    //api call for search using radius
    func getUrlGoogleAPI(radius: Int, lat: Double, lon: Double, keyWord: String) -> URL? {
        //        return kURL_GOOGLE + "?location=\(lat),\(lon)&radius=\(radius)&types=car_repair&key=" + kGOOGLE_API_KEY
        let string: String = kURLGoogleSearch + "?location=\(lat),\(lon)&radius=\(radius)&keyword=\(keyWord)&key=" + kGoogleAPIKey
        let urlString = string.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)
        return URL(string: urlString!)
    }
    
    //api call for nearby places
    func getUrlGoogleAPIbyDistance(lat: Double, lon: Double, keyWord: String) -> URL? {
        //        return kURL_GOOGLE + "?location=\(lat),\(lon)&radius=\(radius)&types=car_repair&key=" + kGOOGLE_API_KEY
        
        let string: String = kURLGoogleSearch + "?location=\(lat),\(lon)&rankby=distance&keyword=\(keyWord)&key=" + kGoogleAPIKey
        let urlString = string.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)
        return URL(string: urlString!)
    }
}
