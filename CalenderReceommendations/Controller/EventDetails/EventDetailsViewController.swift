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
        label.font = UIFont.boldSystemFont(ofSize: 20)
        label.numberOfLines = 0
        label.textAlignment = .center
        return label
    }()
    
    private let startDateLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.font = UIFont.systemFont(ofSize: 14)
        label.textAlignment = .center
        label.text = "Start Time: "
        return label
    }()
    
    private let startDate: UILabel = {
        let label = UILabel(frame: .zero)
        label.font = UIFont.boldSystemFont(ofSize: 14)
        label.textAlignment = .center
        return label
    }()
    
    private let endDateLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.font = UIFont.systemFont(ofSize: 14)
        label.textAlignment = .center
        label.text = "End Time: "
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
        button.setTitleColor(.red, for: .normal)
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
        header.leftToSuperview(offset: 35)
        header.height(46)
        header.widthToSuperview(multiplier: 0.7)
        
        self.view.addSubview(startDateLabel)
        self.view.addSubview(endDateLabel)
        startDateLabel.topToBottom(of: header, offset: 30)
        endDateLabel.topToBottom(of: startDateLabel, offset: 30)
        startDateLabel.width(75)
        endDateLabel.width(75)
        startDateLabel.height(20)
        endDateLabel.height(20)
        startDateLabel.leftToSuperview(offset: 35)
        endDateLabel.leftToSuperview(offset: 35)
        
        self.view.addSubview(startDate)
        self.view.addSubview(endDate)
        startDate.topToBottom(of: header, offset: 30)
        endDate.topToBottom(of: startDate, offset: 30)
        startDate.width(75)
        endDate.width(75)
        startDate.height(20)
        endDate.height(20)
        startDate.leftToRight(of: startDateLabel, offset: 10)
        endDate.leftToRight(of: endDateLabel, offset: 10)
        
        self.view.addSubview(deleteButton)
        deleteButton.bottomToSuperview(offset: -30)
        deleteButton.widthToSuperview()
        deleteButton.height(40)
        deleteButton.addTarget(self, action: #selector(deleteTapped), for: .touchUpInside)
        self.setValues()
    }
    
    func setValues() {
        
        let timedifference = self.calculateHoursAndMinutes(startDate: event.startDate, endDate: event.endDate)
        var time = "(\(timedifference.hours)h \(timedifference.minutes) min)"
        if timedifference.minutes == 0 {
           time = "(\(timedifference.hours)hour)"
        } else if timedifference.hours == 0 {
            time = "(\(timedifference.minutes) min)"
        }
    
        header.attributedText = self.attributedText(mainText: event.title + time, eventName: event.title, timeDiff: time)
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
