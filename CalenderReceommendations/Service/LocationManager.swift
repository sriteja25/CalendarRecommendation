//
//  LocationService.swift
//  CalenderReceommendations
//
//  Created by Sriteja Chilakamarri on 13/10/2023.
//

import CoreLocation
import MapKit
import UIKit

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
    
    func loadPlaceOnMap(latitude: Double, longitude: Double, title: String, subtitle: String, mapView: MKMapView) {
        // Create a coordinate for the place
        let locationCoordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        
        // Create a region that is centered on the locationCoordinate
        let region = MKCoordinateRegion(center: locationCoordinate, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
        
        // Set the region on the map view
        mapView.setRegion(region, animated: true)
        
        // Create an annotation for the place
        let placeAnnotation = MKPointAnnotation()
        placeAnnotation.coordinate = locationCoordinate
        placeAnnotation.title = title
        placeAnnotation.subtitle = subtitle
        
        // Add the annotation to the map view
        mapView.addAnnotation(placeAnnotation)
    }
    
    func openLocationInAppleMaps(latitude: Double, longitude: Double, placeName: String) {
        let locationCoordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        let placemark = MKPlacemark(coordinate: locationCoordinate, addressDictionary: nil)
        let mapItem = MKMapItem(placemark: placemark)
        mapItem.name = placeName // Set the name of the location

        // Launch Apple Maps with the specified location
        mapItem.openInMaps(launchOptions: nil)
    }
    
    func openLocationInGoogleMaps(latitude: Double, longitude: Double, placeName: String) {
        let coordinates = "\(latitude),\(longitude)"
        let query = placeName.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        let urlString = "comgooglemaps://?q=\(query)&center=\(coordinates)&zoom=15"

        if let url = URL(string: urlString) {
            if UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            } else {
                // If Google Maps app is not installed, you can open it in a web browser
                let webUrl = URL(string: "https://www.google.com/maps/search/?api=1&query=\(query)&center=\(coordinates)&zoom=15")!
                UIApplication.shared.open(webUrl, options: [:], completionHandler: nil)
            }
        }
    }
}
