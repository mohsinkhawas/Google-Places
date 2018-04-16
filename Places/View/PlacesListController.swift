//
//  PlacesListViewController.swift
//  Places
//
//  Created by Mohsin Khawas on 3/11/18.
//  Copyright © 2018 Mohsin Khawas. All rights reserved.
//

import UIKit
import CoreLocation

class PlacesListViewController:  UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate,LocationInterfaceDelegate {
    
    @IBOutlet weak var tableView: UITableView!

    var placesArray: Array<AnyObject> = []
    var searchKeyWord = ""
    let locationManager = LocationManager()
    var searchController: UISearchController?
    var refreshControl: UIRefreshControl?
    var alertController: UIAlertController?
    var isAnimating = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.locationManager.delegate = self
        
        self.title = "Explore Places…"
        
        // Set up SearchController
        self.searchController = UISearchController(searchResultsController: nil)
        self.searchController?.searchBar.frame = CGRect(x: 0, y: 0, width: self.view.frame.width + 8, height: 44.0)
        self.searchController?.searchBar.delegate = self;
        self.tableView.tableHeaderView = self.searchController?.searchBar;
        self.definesPresentationContext = true
        self.searchController?.searchBar.placeholder = "Search (e.g. Korean Food, Breakfast, Lunch, Dinner)"
        
        // Set up Refresh control if need.
        self.refreshControl = UIRefreshControl()
        self.refreshControl?.addTarget(self, action: #selector(PlacesListViewController.reloadResults), for: UIControlEvents.valueChanged)
        
        self.tableView.addSubview(refreshControl!)

        self.reloadResults()
    }

    //Animate view while fetching results.
    func startAnimation(){
        if (self.isAnimating == false){
            self.isAnimating = true
            self.alertController = UIAlertController(title: nil, message: "Fetching Places...", preferredStyle: .alert)
            
            let loadingIndicator = UIActivityIndicatorView(frame: CGRect(x: 10, y: 5, width: 50, height: 50))
            loadingIndicator.hidesWhenStopped = true
            loadingIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.gray
            loadingIndicator.startAnimating();
            
            self.alertController?.view.addSubview(loadingIndicator)
            present(self.alertController!, animated: true, completion: nil)
        }
    }
    
    func stopAnimation(){
        self.alertController?.dismiss(animated: true, completion: nil)
        self.alertController = nil
        self.isAnimating = false
    }
    
    @objc func reloadResults() {
        self.refreshControl?.endRefreshing()
        self.placesArray.removeAll()
        self.tableView?.reloadData()
        self.startAnimation()

        self.locationManager.getUserLocation()
    }
    
    //Found the current location, based on that, fetch the places.
    func foundCurrentLocation() {
        
        let networkManager = NetworkManager()
        let currentCoordinate = self.locationManager.currentCoordinate
        
        networkManager.fetchPlaces(keyWord: self.searchKeyWord, lat: currentCoordinate.latitude, lon: currentCoordinate.longitude) { (resultArray, error) in
            
            self.placesArray = resultArray! as Array<AnyObject>
            
            DispatchQueue.main.async {
                self.stopAnimation()
                self.tableView.reloadData()
            }
        }
    }
    
    func locationFailedWithError(_ error: Error) {
        self.stopAnimation()
        print("Error while fetchin location, display error.")
        
        let alert = UIAlertController(title: "Places Alert", message: "Error while fetching location services.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Default action"), style: .`default`, handler: { _ in
            print("Authorization error for location services.")
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    //Call this when location doesnt have access.
    func locationFailedWithAuthorizationError(){
        self.stopAnimation()
        
        let alert = UIAlertController(title: "Places Alert", message: "Enable location services.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Default action"), style: .`default`, handler: { _ in
            print("Authorization error for location services.")
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    // MARK: - tableView delegate
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return placesArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "PlacesCellID", for: indexPath) as! PlaceTableViewCell
        
        let place = self.placesArray[indexPath.row] as! Locations.Place
        cell.nameLabel?.text = place.name
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let cell: PlaceTableViewCell = cell as! PlaceTableViewCell
        
        let place = self.placesArray[indexPath.row] as! Locations.Place
        
        let placeCordinate = CLLocationCoordinate2DMake(place.geometry.location.lat, place.geometry.location.lng)
        
        cell.distanceLabel?.text = self.formatedDistanceFrom(self.locationManager.currentCoordinate, toCoordinate: placeCordinate)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let place = placesArray[indexPath.row]
        self.performSegue(withIdentifier: "mainToDetailSegue", sender: place)
    }
    
    // MARK: - Search Controller delegate
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        self.searchKeyWord = searchText
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        self.tableView.scrollRectToVisible(CGRect.zero, animated: false)
        searchBar.text = self.searchKeyWord
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        self.reloadResults()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        self.reloadResults()
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if let place = sender as? Locations.Place {
            let detailsView = segue.destination as? DetailsViewController
            detailsView?.view.tag = 0   //Setting the tag as example so that view loads it hierarchy. 
            detailsView?.loadDetailView(place)
        }
    }
    
    //Method to calculate distance between two Locations. 
    func formatedDistanceFrom(_ coordinate: CLLocationCoordinate2D, toCoordinate: CLLocationCoordinate2D) -> String {
        
        let earthRadius = CGFloat(6371009.0)
        let degreesToRadians = Double.pi/180.0
        let meterToMile = CGFloat(0.000621371)
        
        let latitude1: CGFloat = CGFloat(toCoordinate.latitude * degreesToRadians)
        let latitude2: CGFloat = CGFloat(coordinate.latitude * degreesToRadians)
        let dLatitude = latitude1 - latitude2
        
        let longitude1: CGFloat = CGFloat(toCoordinate.longitude * degreesToRadians)
        let longitude2: CGFloat = CGFloat(coordinate.longitude * degreesToRadians)
        let dLongitude = longitude1 - longitude2
        
        let k: CGFloat = CGFloat(pow(sin(0.5*dLatitude), 2.0) + cos(latitude1)*cos(latitude2)*pow(sin(0.5*dLongitude), 2.0))
        let distanceMeters: CGFloat = CGFloat(2.0 * earthRadius * asin(sqrt(k)))
        let distanceMiles = distanceMeters * meterToMile
        return String(format:"%.2fmi", distanceMiles)
    }
}

