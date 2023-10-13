//
//  Functions.swift
//  CalenderReceommendations
//
//  Created by Sriteja Chilakamarri on 13/10/2023.
//

import Foundation

class Reusable {
    
    func calculateHoursAndMinutes(startDate: Date?, endDate: Date?) -> (hours: Int, minutes: Int) {
        let calendar = Calendar.current

        if let startDate = startDate, let endDate = endDate {
            let components = calendar.dateComponents([.hour, .minute], from: startDate, to: endDate)
            if let hours = components.hour, let minutes = components.minute {
                return (hours, minutes)
            }
        }
        return (0, 0)
    }
}
