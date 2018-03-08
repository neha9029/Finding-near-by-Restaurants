//
//  ViewController.swift
//  Restaurants
//
//  Created by Neha Naik on 12/25/17.
//  Copyright © 2017 Neha Naik. All rights reserved.
//

import UIKit
import MapKit

class ViewController: UIViewController, CLLocationManagerDelegate {

    @IBOutlet weak var map: MKMapView!
    var restaurants:Restaurants?
    var userLocation:CLLocation?
    var locationManager: CLLocationManager = CLLocationManager()
    var distanceMiles:String?
    
    @IBOutlet weak var nameLabel: UILabel!
    
    @IBOutlet weak var distanceLabel: UILabel!
    
    @IBOutlet weak var openLabel: UILabel!
    
    @IBOutlet weak var ratingLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        self.title = restaurants!.name!
        addMap()
        displayDetails()
        addGeolocation()
    }

    func addGeolocation() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestAlwaysAuthorization()
        locationManager.startUpdatingLocation()
        map.showsUserLocation = true
        
        
    }
    func addMap() {
        let lat = restaurants!.lat!
        let lng = restaurants!.lng!
        let span: MKCoordinateSpan = MKCoordinateSpanMake(0.01, 0.01)
        let location: CLLocationCoordinate2D = CLLocationCoordinate2DMake(lat, lng)
        let region: MKCoordinateRegion = MKCoordinateRegionMake(location, span)
        map.setRegion(region, animated: true)
        
        let annotation = MKPointAnnotation()
        annotation.coordinate = location
        annotation.title = restaurants!.name!
        annotation.subtitle = restaurants!.address!
        
        map.addAnnotation(annotation)
    }
    
    func displayDetails(){
        
        nameLabel.text = restaurants!.name!
        distanceLabel.text = distanceMiles
        displayOpenLabel(open: restaurants!.open!)
        ratingLabel.text = displayRatingStars(ratingInt: Int(restaurants!.rating!))

    }
    
    func displayOpenLabel(open: Bool)  {
        
        if open {
            openLabel.text = "Open"
            openLabel.textColor = UIColor.green
        }else{
            openLabel.text = "Closed"
            openLabel.textColor = UIColor.red
        }
        
    }
    
    func displayRatingStars(ratingInt :Int) -> String {

        var ratingStars:String?
        
        switch ratingInt {
        case 0:
            ratingStars = "No ratings"
        case 1:
            ratingStars = "⭐"
        case 2:
            ratingStars = "⭐⭐"
        case 3:
            ratingStars = "⭐⭐⭐"
        case 4:
            ratingStars = "⭐⭐⭐⭐"
        case 5:
            ratingStars = "⭐⭐⭐⭐⭐"
        default:
            ratingStars = "Not Available"
        }
        
        return ratingStars!
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

extension ViewController: MKMapViewDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        userLocation = locations.first
        
        displayRoutes()
    }
    
    @objc(locationManager:didChangeAuthorizationStatus:) func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        
        if status == .authorizedAlways || status == . authorizedWhenInUse {
            locationManager.startUpdatingLocation()
            
            
        }
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let renderer = MKPolylineRenderer(overlay: overlay)
        renderer.strokeColor = UIColor.blue
        renderer.lineWidth = 4.0
        
        return renderer
        
    }
    
    func displayRoutes(){
        if userLocation != nil {
            
            let sourceLocation = CLLocation(latitude: userLocation!.coordinate.latitude, longitude: userLocation!.coordinate.longitude)
            
            let destLocation = CLLocation(latitude: restaurants!.lat!, longitude: restaurants!.lng!)
            
            let sourcePlacemark = MKPlacemark(coordinate: sourceLocation.coordinate, addressDictionary: nil)
            
            let destPlacemark = MKPlacemark(coordinate: destLocation.coordinate, addressDictionary: nil)
            
            let region = MKCoordinateRegionMakeWithDistance(sourceLocation.coordinate, 15000, 15000)
            
            map.delegate = self
            let requests = MKDirectionsRequest()
            requests.source = MKMapItem(placemark: sourcePlacemark)
            requests.destination = MKMapItem(placemark: destPlacemark)
            requests.requestsAlternateRoutes = false
            requests.transportType = .automobile
            
            let directions = MKDirections(request : requests)
            directions.calculate(completionHandler: { (response, error) in
                if error == nil {
                    
                    for route in response!.routes{
                        self.map.add(route.polyline)
                    }
                    
                }
                else{
                    print("error in displaying routes")
                    print(error!.localizedDescription)
                }
            })
            
            
        }
    }
    
}
