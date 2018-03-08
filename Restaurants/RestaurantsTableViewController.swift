//
//  RestaurantsTableViewController.swift
//  Restaurants
//
//  Created by Neha Naik on 12/27/17.
//  Copyright © 2017 Neha Naik. All rights reserved.
//

import UIKit
import MapKit

class RestaurantsTableViewController: UITableViewController, CLLocationManagerDelegate {

    let identifier = "restaurantCell"
    var userLocation:CLLocation?
    var distanceMiles:String?

    var url:String?
    var flag:Int?
   
    var restaurants: [Restaurants] = [Restaurants]()
    var locationManager: CLLocationManager = CLLocationManager()

    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.flag = 0
        addGeolocation()
     
    }




   override func numberOfSections(in tableView: UITableView) -> Int {
         //#warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        print(restaurants.count)
        
    
        return (restaurants.count)
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath)
        let restaurant = restaurants[indexPath.row]

        // Configure the cell...

        cell.textLabel!.text = restaurant.name
        
        if restaurant.priceLevel! == 6{
            cell.detailTextLabel!.text = ""
        }
        
        distanceMiles = calculateDistance(restaurant.lat!, restaurant.lng!) + " miles"
        cell.detailTextLabel!.text = displayPriceLevel(price: restaurant.priceLevel!)
        return cell
    }



    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        
        if segue.identifier == "goToDetails" {
            
            let viewVC = segue.destination as! ViewController
            let indexPath = tableView.indexPathForSelectedRow
            let index = indexPath!.row
            let restaurantSelected = restaurants[index]
            
            viewVC.restaurants = restaurantSelected
            viewVC.distanceMiles = distanceMiles
        }
    }


}

extension RestaurantsTableViewController{
    
    func addGeolocation() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestAlwaysAuthorization()
        locationManager.startUpdatingLocation()
        
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]){
        
        let location = locations[0]
        userLocation = location
        
        let lat = location.coordinate.latitude
        let lng = location.coordinate.longitude
        
        url = "https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=\(lat),\(lng)&radius=2000&type=restaurant&key=AIzaSyCPK6thSBqAMUzfc23xEH7GxsPdhFHAa94"
        
        //
        
        if(flag==0){
        downloadRestaurants(url!) { (array) in
            self.restaurants = array
            self.tableView.reloadData()
            self.flag = 1
            print("downloading called")
        }
        }
    }
    func downloadRestaurants(_ urlString:String, completion: @escaping (_ array : [Restaurants]) -> () ){
            
            var arrayRestaurants: [Restaurants] = [Restaurants]()
        var openNow:Bool = false
            let url = URL(string: urlString)
            let task = URLSession.shared.dataTask(with: url!) { (data, response, error) in
                
                if error == nil{
                    
                    if let dataValid = data{
                        do{
                            let jsonDic = try JSONSerialization.jsonObject(with: dataValid, options: JSONSerialization.ReadingOptions.mutableContainers) as! NSDictionary
                            
                            let list = jsonDic["results"] as! NSArray
                            
                            for restaurant in list{
                                
                                let aRestaurant = restaurant as! NSDictionary
                                let geo = aRestaurant["geometry"] as! NSDictionary
                                    let loc = geo["location"] as! NSDictionary
                                        let lat = loc["lat"] as! Double
                                        let lng = loc["lng"] as! Double
                                
                                if let openingHours = aRestaurant["opening_hours"] as? NSDictionary {
                                     openNow = openingHours["open_now"] as! Bool

                                }
                                
                                        let name = aRestaurant["name"] as! String
                                        let address = aRestaurant["vicinity"] as! String
                                        let rating = aRestaurant["rating"] as? Double ?? 0
                                        let ratingInt = Int(rating)
                                
                                        let priceLevel = aRestaurant["price_level"] as? Int ?? 6
                                
                                let newRestaurant = Restaurants(name: name, latitude: lat, longitude: lng, address: address, rating: rating, priceLevel: priceLevel, open: openNow)
                                
                                arrayRestaurants.append(newRestaurant)
                                
                                DispatchQueue.main.async(execute: {
                                    completion(arrayRestaurants)
                                    //print(ratingInt)

                                })
                            }
                        }
                        catch{
                            print(error.localizedDescription)
                        }
                    }
                }
            }
        task.resume()
    }
    
    func calculateDistance(_ lat: Double, _ lng: Double) -> String {
        
        var distanceLocationStr: String?
        let restaurantLocation = CLLocation(latitude: lat, longitude: lng)
        var distance:CLLocationDistance?
        distance = userLocation?.distance(from: restaurantLocation)
        var distanceMiles = NSString(format: "%.2f", distance! / 1609.344)
        distanceLocationStr = String(distanceMiles)
        
        return distanceLocationStr!
    }
    
    func displayPriceLevel(price: Int) -> String {
        
        var priceLevelStr: String?
        
        switch price {
        case 0:
            priceLevelStr = "free"
        case 1:
            priceLevelStr = "$"
        case 2:
            priceLevelStr = "$$"
        case 3:
            priceLevelStr = "$$$"
        case 4:
            priceLevelStr = "$$$$"

        default:
            priceLevelStr = "Not Available"
        }
        return priceLevelStr!
    }
}
