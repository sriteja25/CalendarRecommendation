//
//  WeatherViewController.swift
//  CalenderReceommendations
//
//  Created by Sriteja Chilakamarri on 12/10/2023.
//

import UIKit
import CoreLocation

class WeatherViewController: UIViewController {
    
    var weatherManager = WeatherManager()
    let locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = .red
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.requestLocation()
        
        weatherManager.delegate = self
        locationManager.requestLocation()
    }
    
}

//MARK: - WeatherManagerDelegate


extension WeatherViewController: WeatherManagerDelegate {
    
    func didUpdateWeather(_ weatherManager: WeatherManager, weather: WeatherModel) {
        DispatchQueue.main.async {
            print(weather.temperatureString)
            print(weather.conditionName)
            print(weather.cityName)
        }
    }
    
    func didFailWithError(error: Error) {
        print(error)
    }
}

//MARK: - CLLocationManagerDelegate


extension WeatherViewController: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
            locationManager.stopUpdatingLocation()
            let lat = location.coordinate.latitude
            let lon = location.coordinate.longitude
            weatherManager.fetchWeather(latitude: lat, longitude: lon)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        if let clError = error as? CLError {
            switch clError.code {
            case .locationUnknown:
                // Location is currently unknown, retrying...
                print("Location is currently unknown.")
            case .denied:
                // Location services are denied by the user.
                print("Location services are denied by the user.")
            case .network:
                // A network error occurred.
                print("A network error occurred.")
            case .headingFailure:
                // The device is unable to retrieve heading information.
                print("The device is unable to retrieve heading information.")
            default:
                // Handle other error cases.
                print("Error: \(error.localizedDescription)")
            }
        } else {
            // Handle non-CLError errors, if any.
            print("Error: \(error.localizedDescription)")
        }
    }
    
    func promptLocationPermission() {
        let alert = UIAlertController(
            title: "Location Services Disabled",
            message: "To provide accurate weather information, please enable location services for this app.",
            preferredStyle: .alert
        )
        
        let settingsAction = UIAlertAction(title: "Open Settings", style: .default) { (action) in
            if let url = URL(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        alert.addAction(settingsAction)
        alert.addAction(cancelAction)
        
        present(alert, animated: true, completion: nil)
    }
}
