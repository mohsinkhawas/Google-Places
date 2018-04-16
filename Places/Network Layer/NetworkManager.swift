//
//  NetworkManager.swift
//  Places
//
//  Created by Mohsin Khawas on 3/11/18.
//  Copyright © 2018 Mohsin Khawas. All rights reserved.
//

import Foundation

class NetworkManager {
    let api = GooglePlacesAPI()
    
    func fetchPlaces(keyWord: String, lat: Double, lon: Double, completionHandler: @escaping ([Locations.Place]?, Error?) -> ()) -> () {
        let googleAPIUrl = api.getUrlGoogleAPIbyDistance(lat: lat, lon: lon, keyWord: keyWord)
        
        guard let placesURL = googleAPIUrl else { return }
        
        URLSession.shared.dataTask(with: placesURL) { (responseData, response
            , error) in
            guard responseData != nil else { return }
            do {
                if let error = error {
                    print(error.localizedDescription)
                    completionHandler([], error)
                }
                guard let data = responseData,
                    let response = try? JSONDecoder().decode(Locations.self, from: data) else {
                        completionHandler([], error)
                        return
                }
                completionHandler(response.results, error)
            }
            }.resume()
    }
}
