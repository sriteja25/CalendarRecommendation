//
//  LocationService.swift
//  CalenderReceommendations
//
//  Created by Sriteja Chilakamarri on 13/10/2023.
//

import CoreLocation

class LocationManager {
    private let geocoder = CLGeocoder()

    func reverseGeocode(latitude: Double, longitude: Double, completion: @escaping (String?, String?, String?, String?, String?) -> Void) {
        let location = CLLocation(latitude: latitude, longitude: longitude)

        // Perform reverse geocoding on a background thread
        DispatchQueue.global(qos: .background).async {
            self.geocoder.reverseGeocodeLocation(location) { placemarks, error in
                if let error = error {
                    print("Reverse geocoding failed with error: \(error.localizedDescription)")
                    completion(nil, nil, nil, nil, nil)
                    return
                }

                if let placemark = placemarks?.first {
                    let address = placemark.name ?? ""
                    let city = placemark.locality ?? ""
                    let state = placemark.administrativeArea ?? ""
                    let postalCode = placemark.postalCode ?? ""
                    let country = placemark.country ?? ""

                    // Return the results on the main thread
                    DispatchQueue.main.async {
                        completion(address, city, state, postalCode, country)
                    }
                } else {
                    DispatchQueue.main.async {
                        completion(nil, nil, nil, nil, nil)
                    }
                }
            }
        }
    }
}
