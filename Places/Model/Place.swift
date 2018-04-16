//
//  Place.swift
//  Places
//
//  Created by Mohsin Khawas on 3/11/18.
//  Copyright © 2018 Mohsin Khawas. All rights reserved.
//

import Foundation
struct Locations: Codable {
    
    let htmlAttributions: [String]
    let nextPageToken: String
    let results: [Place]
    let status: String
    
    struct Place: Codable {
        let formattedAddress: String?
        let geometry: Geometry
        let icon: String
        let id: String
        let name: String
        let photos: [Photo]?
        let placeID: String
        let rating: Double?
        let reference: String
        let types: [String]
        
        struct Geometry: Codable {
            let location: Coordinates
            let viewport: Viewport
            
            struct Coordinates: Codable {
                let lat: Double
                let lng: Double
                init(from decoder: Decoder) throws {
                    let values = try decoder.container(keyedBy: CodingKeys.self)
                    lat = try values.decode(Double.self, forKey: .lat)
                    lng = try values.decode(Double.self, forKey: .lng)
                }
                enum CodingKeys : String, CodingKey {
                    case lat
                    case lng
                }
            }
            
            struct Viewport: Codable {
                let northeast: Coordinates
                let southwest: Coordinates
                
                enum CodingKeys : String, CodingKey {
                    case northeast
                    case southwest
                }
            }
            
            enum CodingKeys : String, CodingKey {
                case location
                case viewport
            }
        }
        
        struct Photo: Codable {
            
            let height: Int
            let htmlAttributions: [String]
            let photoReference: String?
            let width: Int
            enum CodingKeys : String, CodingKey {
                case height
                case htmlAttributions = "html_attributions"
                case photoReference = "photo_reference"
                case width
            }
        }
        
        enum CodingKeys : String, CodingKey {
            case formattedAddress = "formatted_address"
            case geometry
            case icon
            case id
            case name
            case photos
            case placeID = "place_id"
            case rating
            case reference
            case types
        }
    }
    
    enum CodingKeys : String, CodingKey {
        case htmlAttributions = "html_attributions"
        case nextPageToken = "next_page_token"
        case results
        case status
    }
}
