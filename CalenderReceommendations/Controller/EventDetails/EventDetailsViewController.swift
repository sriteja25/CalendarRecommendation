//
//  EditEventViewController.swift
//  CalenderReceommendations
//
//  Created by Sriteja Chilakamarri on 12/10/2023.
//

import EventKit
import EventKitUI
import MapKit
import MBProgressHUD
import TinyConstraints
import UIKit

class EventDetailsViewController: UIViewController {
    
    private let header: UILabel = {
        let label = UILabel(frame: .zero)
        label.font = UIFont.boldSystemFont(ofSize: 22)
        label.numberOfLines = 0
        label.textAlignment = .right
        return label
    }()
    
    private let startDateLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.font = UIFont.systemFont(ofSize: 14)
        label.textAlignment = .left
        label.text = "🕒 Start Time: "
        return label
    }()
    
    private let startDate: UILabel = {
        let label = UILabel(frame: .zero)
        label.font = UIFont.boldSystemFont(ofSize: 14)
        label.textAlignment = .left
        return label
    }()
    
    private let endDateLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.font = UIFont.systemFont(ofSize: 14)
        label.textAlignment = .left
        label.text = "🕞 End Time: "
        return label
    }()
    
    private let endDate: UILabel = {
        let label = UILabel(frame: .zero)
        label.font = UIFont.boldSystemFont(ofSize: 14)
        label.textAlignment = .left
        return label
    }()
    
    private let mapView: MKMapView = {
        let mapView = MKMapView(frame: .zero)
        mapView.mapType = .standard
        mapView.showsUserLocation = true
        mapView.accessibilityIdentifier = "MapView"
        return mapView
    }()
    
    private let deleteButton: UIButton = {
        let button = UIButton(frame: .zero)
        button.setTitle("🗑️ Delete Event", for: .normal)
        button.setTitleColor(.red, for: .normal)
        return button
    }()
    
    private let gptLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.font = UIFont.boldSystemFont(ofSize: 16)
        label.numberOfLines = 0
        label.textAlignment = .center
        label.text = "🙌 Recommendations"
        return label
    }()
    
    private let gptValue: UILabel = {
        let label = UILabel(frame: .zero)
        label.font = UIFont.systemFont(ofSize: 13)
        label.numberOfLines = 0
        label.textAlignment = .left
        label.contentMode = .top
        return label
    }()
    
    private let event: EKEvent
    private let eventStore: EKEventStore
    private var locationName: String = ""
    private var hud = MBProgressHUD()
    private var lat:Double = 0
    private var lon:Double = 0
    
    required init(event: EKEvent, eventStore: EKEventStore) {
        self.event = event
        self.eventStore = eventStore
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setupUI()
        title = "🗓️ Event details"
    }
    
    // MARK: - Setup UI
    
    private func setupUI() {
        self.view.backgroundColor = .white
        self.view.addSubview(header)
        header.topToSuperview(offset: 90)
        header.leftToSuperview(offset: 35)
        header.height(84)
        header.widthToSuperview(multiplier: 0.7)
        
        self.view.addSubview(startDateLabel)
        self.view.addSubview(endDateLabel)
        startDateLabel.topToBottom(of: header, offset: 15)
        endDateLabel.topToBottom(of: startDateLabel, offset: 15)
        startDateLabel.width(100)
        endDateLabel.width(100)
        startDateLabel.height(20)
        endDateLabel.height(20)
        startDateLabel.leftToSuperview(offset: 35)
        endDateLabel.leftToSuperview(offset: 35)
        
        self.view.addSubview(startDate)
        self.view.addSubview(endDate)
        startDate.topToBottom(of: header, offset: 15)
        endDate.topToBottom(of: startDate, offset: 15)
        startDate.width(75)
        endDate.width(75)
        startDate.height(20)
        endDate.height(20)
        startDate.leftToRight(of: startDateLabel, offset: 2)
        endDate.leftToRight(of: endDateLabel, offset: 2)
        
        self.view.addSubview(deleteButton)
        deleteButton.bottomToSuperview(offset: -30)
        deleteButton.widthToSuperview()
        deleteButton.height(40)
        deleteButton.addTarget(self, action: #selector(deleteTapped), for: .touchUpInside)
        
        self.view.addSubview(mapView)
        mapView.height(75)
        mapView.widthToSuperview()
        mapView.bottomToTop(of: deleteButton, offset: -20)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        mapView.addGestureRecognizer(tapGesture)
        
        self.view.addSubview(self.gptLabel)
        self.gptLabel.topToBottom(of: self.endDateLabel, offset: 45)
        self.gptLabel.widthToSuperview(multiplier: 0.9)
        self.gptLabel.height(20)
        self.gptLabel.centerXToSuperview()
        self.view.addSubview(self.gptValue)
        self.gptValue.topToBottom(of: self.gptLabel, offset: 5)
        self.gptValue.widthToSuperview(multiplier: 0.9)
        self.gptValue.height(250)
        self.gptValue.centerXToSuperview()
        
        self.setValues()
    }
    // MARK: - Setup Values for the Event
    func setValues() {
        
        let timedifference = self.calculateHoursAndMinutes(startDate: event.startDate, endDate: event.endDate)
        var time = "(\(timedifference.hours)h \(timedifference.minutes) min)"
        if timedifference.minutes == 0 {
            if timedifference.hours > 1 {
                time = "(\(timedifference.hours) hours)"
            } else {
                time = "(\(timedifference.hours) hour)"
            }
            
        } else if timedifference.hours == 0 {
            if timedifference.minutes > 1 {
                time = "(\(timedifference.minutes) mins)"
            } else {
                time = "(\(timedifference.minutes) min)"
            }
        }
        
        header.attributedText = self.attributedText(mainText: event.title + time, eventName: event.title, timeDiff: time)
        startDate.text = event.startDate.convertToTime()
        endDate.text = event.endDate.convertToTime()
        
        self.getWeather()
    }
    // MARK: - Get Weather for the event location
    func getWeather() {
        if let lat = event.structuredLocation?.geoLocation?.coordinate.latitude, let lon = event.structuredLocation?.geoLocation?.coordinate.longitude  {
            self.reverseGeocoding(lat: lat, lon: lon)
        } else {
            // No location added to event. User's current location will be used to fetch weather data
            let locationManager = CLLocationManager()
            locationManager.delegate = self
            locationManager.requestWhenInUseAuthorization()
            locationManager.requestLocation()
        }
    }
    // MARK: - Show event location on a map
    func showMap(lat: Double, lon: Double) {
        DispatchQueue.main.async {
            self.lat = lat
            self.lon = lon
            let placeTitle = self.event.title ?? "Event place"
            LocationManager().loadPlaceOnMap(latitude: lat, longitude: lon, title: placeTitle, subtitle: "", mapView: self.mapView)
        }
    }
    // MARK: - Redirect to map
    @objc
    func handleTap(_ gesture: UITapGestureRecognizer) {
        
        let placeTitle = self.event.title ?? "Event place"
        let locationManager = LocationManager()
        let controller = UIAlertController(title: "Choose", message: "Select preferred maps to view the event location", preferredStyle: .actionSheet)
        controller.addAction(UIAlertAction(title: "Apple Maps", style: .default, handler: { _ in
            locationManager.openLocationInAppleMaps(latitude: self.lat, longitude: self.lon, placeName: placeTitle)
        }))
        controller.addAction(UIAlertAction(title: "Google Maps", style: .default, handler: { _ in
            locationManager.openLocationInGoogleMaps(latitude: self.lat, longitude: self.lon, placeName: placeTitle)
        }))
        controller.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { _ in
            controller.dismiss(animated: true)
        }))
        self.navigationController?.present(controller, animated: true)
    }
    // MARK: - Fetch hourly weather
    func fetchWeather(lat: Double, lon: Double) {
        self.showMap(lat: lat, lon: lon)
        let weatherService = WeatherService()
        weatherService.fetchWeatherData(latitude: "\(lat)", longitude: "\(lon)") { result in
            switch result {
            case .success(let weatherResponse):
                // Handle the weather response here
                let eventStartTime = Int(self.event.startDate.timeIntervalSince1970)
                let eventEndTime = Int(self.event.endDate.timeIntervalSince1970)
                let hourlyData = weatherResponse.hourly.map { $0.dt }
                let closestTimeStampStart = hourlyData.min(by: { abs($0 - eventStartTime) < abs($1 - eventStartTime) })
                let closestTimeStampEnd = hourlyData.min(by: { abs($0 - eventEndTime) < abs($1 - eventEndTime) })
                let startIndex = weatherResponse.hourly.firstIndex{ $0.dt == closestTimeStampStart } ?? 0
                let endIndex = weatherResponse.hourly.firstIndex{ $0.dt == closestTimeStampEnd } ?? 1
                let start = weatherResponse.hourly[startIndex]
                let end = weatherResponse.hourly[endIndex]
                self.gptRecommendation(startWeather: start, endWeather: end)
            case .failure(let error):
                // Failed to fetch data, update GPT with error message
                print("Error: \(error)")
                let response = "No recommendations available at this moment. Please try again after sometime or select another event from Calendar."
                self.addGPTText(response: response)
            }
        }
        
        
    }
    // MARK: - Get address from event location
    func reverseGeocoding (lat: Double, lon: Double) {
        
        let locationManager = LocationManager()
        
        locationManager.reverseGeocode(latitude: lat, longitude: lon) { address, city, state, postalCode, country in
            if let address = address, let city = city, let state = state, let postalCode = postalCode, let country = country {
                print("Address: \(address)")
                print("City: \(city)")
                print("State: \(state)")
                print("Postal Code: \(postalCode)")
                print("Country: \(country)")
                self.locationName = "\(address) \(city) \(state) \(postalCode) \(country)"
                self.fetchWeather(lat: lat, lon: lon)
            } else {
                self.fetchWeather(lat: lat, lon: lon)
                print("Reverse geocoding failed.")
            }
        }
    }
    // MARK: - Get Event specific recommendations
    func gptRecommendation(startWeather: HourlyData, endWeather: HourlyData) {
        
        DispatchQueue.main.async {
            self.hud = MBProgressHUD.showAdded(to: self.gptValue, animated: true)
            self.hud.mode = .indeterminate
            self.hud.label.text = "Generating..."
        }
        
        let gpt = GPTService()
        gpt.getResponse(event: self.event, startWeather: startWeather, endWeather: endWeather, locationName: locationName) { response, error in
            
            if error != nil {
                print(error?.localizedDescription as Any)
                let response = "No recommendations available at this moment. Please try again after sometime or select another event from Calendar."
                self.addGPTText(response: response)
            } else {
                guard let response = response else {
                    return
                }
                self.addGPTText(response: response)
            }
        }
    }
    
    func addGPTText(response: String) {
        
        DispatchQueue.main.async {
            self.gptValue.text = response
            self.hud.hide(animated: true)
        }
    }
    // MARK: - Delete event
    @objc
    func deleteTapped() {
        let delete = UIAlertAction(title: "Delete", style: .destructive) { _ in
            self.navigationController?.popViewController(animated: true)
            do {
                try self.eventStore.remove(self.event, span: .thisEvent)
                print("Event deleted successfully")
                
            } catch {
                print("Error deleting event: \(error.localizedDescription)")
                AlertManager.showAlert(title: "Error", message: error.localizedDescription, viewController: self)
                // Show Alert of failed event deletion
            }
        }
        
        let cancel = UIAlertAction(title: "Cancel", style: .cancel)
        AlertManager.showAlertWithActions(title: "Confirm?", message: "Event will be permanently deleted", viewController: self, actions: [delete, cancel], completion: nil)
    }
}

extension EventDetailsViewController {
    
    func calculateHoursAndMinutes(startDate: Date, endDate: Date) -> (hours: Int, minutes: Int) {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.hour, .minute], from: startDate, to: endDate)
        
        if let hours = components.hour, let minutes = components.minute {
            return (hours, minutes)
        } else {
            return (0, 0)
        }
    }
    
    func attributedText(mainText: String, eventName: String, timeDiff: String) -> NSMutableAttributedString {
        
        let attributedText = NSMutableAttributedString(string: mainText)
        let boldRange = (mainText as NSString).range(of: eventName)
        let lightRange = (mainText as NSString).range(of: timeDiff)
        attributedText.addAttribute(.font, value: UIFont.boldSystemFont(ofSize: 22), range: boldRange)
        attributedText.addAttribute(.foregroundColor, value: UIColor.black, range: boldRange)
        attributedText.addAttribute(.font, value: UIFont.systemFont(ofSize: 20), range: lightRange)
        attributedText.addAttribute(.foregroundColor, value: UIColor.gray, range: lightRange)
        return attributedText
    }
}

extension EventDetailsViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
            // Use the current location
            self.reverseGeocoding(lat: location.coordinate.latitude, lon: location.coordinate.longitude)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        // Handle location error
        print("Location error: \(error)")
    }
}
