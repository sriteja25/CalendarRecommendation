//
//  Weather.swift
//  CalenderReceommendations
//
//  Created by Sriteja Chilakamarri on 11/10/2023.
//

import Combine
import CoreLocation
import Foundation

class WeatherService {
    private let baseURL = "https://api.openweathermap.org/data/2.5/onecall" // Weather map API end point for hourly forecast
    private let units = "metric"
    func fetchWeatherData(latitude: String, longitude: String, completion: @escaping (Result<WeatherResponse, Error>) -> Void) {
        
        if let path = Bundle.main.path(forResource: "Keys", ofType: "plist"),
           let keys = NSDictionary(contentsOfFile: path) as? [String: String] {
            if let apiKey = keys["OpenWeatherMap_Key"] {
                // Use apiKey1 for your API calls
                let apiKey = apiKey
                let urlString = "\(baseURL)?lat=\(latitude)&lon=\(longitude)&appid=\(apiKey)&units=\(units)"
                
                guard let url = URL(string: urlString) else {
                    completion(.failure(URLError(.badURL)))
                    return
                }
                
                URLSession.shared.dataTask(with: url) { data, response, error in
                    if let error = error {
                        completion(.failure(error))
                        return
                    }
                    
                    guard let data = data else {
                        completion(.failure(URLError(.unknown)))
                        return
                    }
                    
                    do {
                        let decoder = JSONDecoder()
                        let weatherResponse = try decoder.decode(WeatherResponse.self, from: data)
                        completion(.success(weatherResponse))
                    } catch {
                        completion(.failure(error))
                    }
                }.resume()
                
            } else {
                completion(.failure(CustomError.genericError(message: "Something went wrong.")))
            }
        } else {
            completion(.failure(CustomError.genericError(message: "Something went wrong.")))
        }
    }
}



