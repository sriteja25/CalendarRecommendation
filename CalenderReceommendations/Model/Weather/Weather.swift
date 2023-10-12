//
//  Weather.swift
//  CalenderReceommendations
//
//  Created by Sriteja Chilakamarri on 12/10/2023.
//

import Foundation

struct WeatherData: Codable {
    let name: String
    let main: Main
    let weather: [Weather]
}

struct Main: Codable {
    let temp: Double
}

struct Weather: Codable {
    let description: String
    let id: Int
}
