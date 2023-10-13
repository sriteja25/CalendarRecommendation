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
    private let apiKey = "10d83272107b3579bbec3790805f50f1" // API key for the weathermap
    private let units = "metric"
    
    func fetchWeatherData(latitude: String, longitude: String, completion: @escaping (Result<WeatherResponse, Error>) -> Void) {
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
    }
}



