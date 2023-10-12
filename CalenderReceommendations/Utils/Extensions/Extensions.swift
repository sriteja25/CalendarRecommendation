//
//  Extensions.swift
//  CalenderReceommendations
//
//  Created by Sriteja Chilakamarri on 12/10/2023.
//

import Foundation

extension Date {
    
    func convertToTime() -> String {

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "h:mm a" // Use the desired time format

        let timeString = dateFormatter.string(from: self)
        return timeString
    }
}
