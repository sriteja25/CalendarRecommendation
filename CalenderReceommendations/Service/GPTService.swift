//
//  GPTManager.swift
//  CalenderReceommendations
//
//  Created by Sriteja Chilakamarri on 13/10/2023.
//

import ChatGPTSwift
import EventKit
import Foundation


class GPTService {
    
    func getResponse(event: EKEvent, startWeather: HourlyData, endWeather: HourlyData, locationName: String , completionHandler: @escaping (String?, Error?) -> Void) {
        
        let prompt = "I am attending an event named \(event.title) at \(locationName). It starts at \(event.startDate) and ends at \(event.endDate). The weather is likely to be \(startWeather.temp) degrees centigrade at the start of event with \(startWeather.weather[0].description) and \(endWeather.temp) degrees centigrade at the end of event with \(endWeather.weather[0].description). First recommendation: Give me a very very specific clothing recommendation (Shirt, pant, short, frock, saree, cotton, wool, nylon etc) for weather Second Receommndation: if an umbrella or jacket are necessary in 5 words. Third Recommendation: Anything based on event title \(event.title) a small random fact about the event city. Give the output properly numbered without side headings ready to display on UILabel."
        print(prompt)
        let apiKey = "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"
        let api = ChatGPTAPI(apiKey: apiKey)
        Task {
            do {
                let response = try await api.sendMessage(text: prompt)
                print(response)
                completionHandler(response, nil)
            } catch {
                print(error.localizedDescription)
                completionHandler("", error)
            }
        }
    }
}
