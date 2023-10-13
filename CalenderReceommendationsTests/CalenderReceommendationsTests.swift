//
//  CalenderReceommendationsTests.swift
//  CalenderReceommendationsTests
//
//  Created by Sriteja Chilakamarri on 10/10/2023.
//

import XCTest
import EventKit
import EventKitUI
@testable import CalenderReceommendations

final class CalenderReceommendationsTests: XCTestCase {
    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func testFetchWeatherData() {
        let expectation = XCTestExpectation(description: "Fetch Weather Data")
        
        // Test Cordinates
        let latitude = "37.7749"
        let longitude = "-122.4194"
        let weatherService = WeatherService()
        weatherService.fetchWeatherData(latitude: latitude, longitude: longitude) { result in
            switch result {
            case .success(let weatherResponse):
                // Assert that you received a valid response
                XCTAssertNotNil(weatherResponse)
                expectation.fulfill()
                
            case .failure(let error):
                // Assert that there was no error
                XCTFail("Weather data request failed with error: \(error)")
            }
        }
        wait(for: [expectation], timeout: 10.0)
    }
    
    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
}
