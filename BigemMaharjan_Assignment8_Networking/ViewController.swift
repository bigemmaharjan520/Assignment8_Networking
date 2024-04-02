//
//  ViewController.swift
//  BigemMaharjan_Assignment8_Networking
//
//  Created by user240741 on 3/26/24.
//

import UIKit
import CoreLocation

class ViewController: UIViewController , CLLocationManagerDelegate{
    
    //City Name interms of location
    @IBOutlet weak var CityName: UILabel!
    
    //Weather Description
    @IBOutlet weak var weatherDesc: UILabel!
    
    //Weather Icon
    @IBOutlet weak var weatherIcon: UIImageView!
    
    //Weather Temperature
    @IBOutlet weak var weatherTemp: UILabel!
    
    //Humidity
    @IBOutlet weak var humidity: UILabel!
    
    //Wind
    @IBOutlet weak var wind: UILabel!
    
    //Location
    let locationManager = CLLocationManager()
    
    var currentLocation: CLLocation?
    
    //creating models to access the weather description
    var models = [WeatherDescription]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        setupLocation() //Calling function
    }
    
    //Settup of Location function
    func setupLocation(){
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }
    
    //Location Manager
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if !locations.isEmpty, currentLocation == nil {
            currentLocation = locations.first
            locationManager.stopUpdatingLocation()
            requestWeatherForLocation()
        }
    }

    //Requesting or Retrieving the Location Weather
    func requestWeatherForLocation(){
        guard let currentLocation = currentLocation else{
            return
        }
        let long = currentLocation.coordinate.longitude
        let lat = currentLocation.coordinate.latitude
        
//        print("\(long) | \(lat)")l
        
        //URL Session
        let weatherApiUrl = "https://api.openweathermap.org/data/2.5/weather?lat=\(lat)&lon=\(long)&appid=fe6e61fc470bfd4e136f083cef57e09c"
        
        //Using urlSession to make a request
        URLSession.shared.dataTask(with: URL(string: weatherApiUrl)!, completionHandler: {data, response, error in
            //Validation
            guard let data = data, error == nil else {
                print("Seems some error")
                return
            }
            
            //Converting data to models/ some object
            var json: WeatherResponse?
            do{
                json = try JSONDecoder().decode(WeatherResponse.self, from: data)
            }
            catch{
                print("error: \(error)")
            }
            
            //If no error is found in do catch below code is run
            guard let result = json else {
                return
            }
            
            
            //Updating user interface
            //Using Dispatch
            DispatchQueue.main.async {
                //Changing city name according to location
                self.CityName.text = result.name
                
                //Changing weather description according to location
                self.weatherDesc.text = result.weather[0].main
                
                //Changing weather temp according to location
                self.weatherTemp.text = "\(String((result.main.temp - 273.15).rounded())) °C"
                
                //Changing weather humidity according to location
                self.humidity.text = "\(String(result.main.humidity)) %"
                
                //Changing weather wind speed according to location
                self.wind.text = "\(String(result.wind.speed)) km/h"

                //Changing weather icon according to location
                let getWeatherAPIIcon = "https://openweathermap.org/img/w/\(result.weather[0].icon).png"
                URLSession.shared.dataTask(with: URL(string: getWeatherAPIIcon)!, completionHandler: {data, response, error in
                    //Validation
                    guard let data = data, error == nil else {
                        print("Seems some error")
                        return
                    }
                    //Using Dispatch
                    DispatchQueue.main.async {
                        self.weatherIcon.image = UIImage(data: data)
                    }
                }).resume()
            }
        }).resume()
    }
}


//Parsing JSON
struct WeatherResponse: Codable{
    let coord : WeatherCoor
    let weather: [WeatherDescription]
    let base: String
    let main: WeatherMain
    let visibility: Double
    let wind: WeatherWind
    let clouds: WeatherCloud
    let dt: Double
    let sys: WeatherSys
    let id: Int
    let name: String
    let cod: Double
}

//coord
struct WeatherCoor: Codable {
    let lon: Float
    let lat: Float
}

//weather
struct WeatherDescription: Codable {
    let id: Int
    let main: String
    let description: String
    let icon: String
}

//main
struct WeatherMain: Codable{
    let temp: Double
    let feels_like: Double
    let temp_min: Double
    let temp_max: Double
    let pressure: Double
    let humidity: Int
}

//wind
struct WeatherWind: Codable{
    let speed: Double
    let deg: Double
}

//clouds
struct WeatherCloud: Codable{
    let all: Double
}

//sys
struct WeatherSys: Codable {
    let type: Int
    let id: Int
    let country: String
    let sunrise: Double
    let sunset: Double
}
