//
//  Restaurants.swift
//  Restaurants
//
//  Created by Neha Naik on 1/6/18.
//  Copyright © 2018 Neha Naik. All rights reserved.
//

import UIKit

class Restaurants: NSObject {
    
    var name:String?
    var lat:Double?
    var lng:Double?
    var open:Bool?
    var address:String?
    var rating:Double?
    var priceLevel:Int?
    var webUrl:URL?
    
    init(name:String, latitude:Double, longitude:Double, address:String, rating:Double, priceLevel:Int, open:Bool){
        
        self.name = name
        self.lat = latitude
        self.lng = longitude
        self.address = address
        self.rating = rating
        self.priceLevel = priceLevel
        self.webUrl = URL(string:"")
        self.open = open
    }

}
