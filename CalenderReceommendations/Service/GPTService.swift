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
        
        let prompt = "I am attending an event named \(event.title) at \(locationName). It starts at \(event.startDate) and ends at \(event.endDate). The weather is likely to be \(startWeather.temp) degrees centigrade at the start of event with \(startWeather.weather[0].description) and \(endWeather.temp) degrees centigrade at the end of event with \(endWeather.weather[0].description). 1. Give me a very very specific clothing recommendation (Shirt, pant, short, frock, saree, cotton, wool, nylon etc) for weather 2. if an umbrella or jacket are necessary in 5 words. 3. Anything based on event \(event.title) 4.small random fact involving \(event.title) and event city. Give the output properly numbered without side headings ready to display on UILabel."
        if let path = Bundle.main.path(forResource: "Keys", ofType: "plist"),
           let keys = NSDictionary(contentsOfFile: path) as? [String: String] {
            if let apiKey = keys["GPT_KEY"] {
                let apiKey = apiKey
                let api = ChatGPTAPI(apiKey: apiKey)
                Task {
                    do {
                        let response = try await api.sendMessage(text: prompt)
                        completionHandler(response, nil)
                    } catch {
                        print(error.localizedDescription)
                        completionHandler("", error)
                    }
                }
            } else {
                completionHandler("", CustomError.genericError(message: "Something went wrong."))
            }
        } else {
            completionHandler("", CustomError.genericError(message: "Something went wrong."))
        }
    }
}

enum CustomError: Error {
    case genericError(message: String)
    case specificError(message: String)
}
