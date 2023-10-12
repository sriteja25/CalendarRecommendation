//
//  EditEventViewController.swift
//  CalenderReceommendations
//
//  Created by Sriteja Chilakamarri on 12/10/2023.
//

import EventKit
import EventKitUI
import TinyConstraints
import UIKit

class EventDetailsViewController: UIViewController {
    
    private let header: UILabel = {
        let label = UILabel(frame: .zero)
        label.font = UIFont.boldSystemFont(ofSize: 14)
        label.textAlignment = .center
        return label
    }()
    
    private let startDate: UILabel = {
        let label = UILabel(frame: .zero)
        label.font = UIFont.boldSystemFont(ofSize: 14)
        label.textAlignment = .center
        return label
    }()
    
    private let endDate: UILabel = {
        let label = UILabel(frame: .zero)
        label.font = UIFont.boldSystemFont(ofSize: 14)
        label.textAlignment = .center
        return label
    }()
    
    private let deleteButton: UIButton = {
        let button = UIButton(frame: .zero)
        button.setTitle("Delete Event", for: .normal)
        button.setTitleColor(.blue, for: .normal)
        return button
    }()
    
    private let event: EKEvent
    private let eventStore: EKEventStore
    
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
        title = "Event details"
    }
    
    // MARK: - Setup Navigation
    
    private func setupUI() {
        self.view.backgroundColor = .white
        self.view.addSubview(header)
        header.topToSuperview(offset: 120)
        header.centerXToSuperview()
        header.widthToSuperview()
        
        self.view.addSubview(startDate)
        self.view.addSubview(endDate)
        startDate.topToBottom(of: header, offset: 30)
        endDate.topToBottom(of: startDate, offset: 30)
        startDate.widthToSuperview()
        endDate.widthToSuperview()
        startDate.height(20)
        endDate.height(20)
        
        self.view.addSubview(deleteButton)
        deleteButton.bottomToSuperview(offset: -30)
        deleteButton.widthToSuperview()
        deleteButton.height(40)
        deleteButton.addTarget(self, action: #selector(deleteTapped), for: .touchUpInside)
        
        
        self.setValues()
    }
    
    func setValues() {
        
        header.text = "Event Name: " + event.title
        startDate.text = event.startDate.convertToTime()
        endDate.text = event.endDate.convertToTime()
        
        guard let lat = event.structuredLocation?.geoLocation?.coordinate.latitude else {
            return
        }
        guard let lon = event.structuredLocation?.geoLocation?.coordinate.longitude else {
            return
        }
        
        let weatherService = WeatherService()
        weatherService.fetchWeatherData(latitude: "\(lat)", longitude: "\(lon)") { result in
            switch result {
            case .success(let weatherResponse):
                // Handle the weather response here
                print(weatherResponse.hourly[0].dt, weatherResponse.hourly[0].temp)
            case .failure(let error):
                print("Error: \(error)")
            }
        }
    }
    
    @objc
    func deleteTapped() {
        let delete = UIAlertAction(title: "Delete", style: .destructive) { _ in
            self.navigationController?.popViewController(animated: true)
            do {
                try self.eventStore.remove(self.event, span: .thisEvent)
                print("Event deleted successfully")
                
            } catch {
                print("Error deleting event: \(error.localizedDescription)")
                AlertManager.showAlertWithActions(title: "Error", message: error.localizedDescription, viewController: self, actions: [UIAlertAction(title: "Ok", style: .cancel)], completion: nil)
                // Show Alert of failed event deletion
            }
        }
        
        let cancel = UIAlertAction(title: "Cancel", style: .cancel)
        AlertManager.showAlertWithActions(title: "Confirm?", message: "Event will be permanently deleted", viewController: self, actions: [delete, cancel], completion: nil)
    }
}
