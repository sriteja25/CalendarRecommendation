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
    
    func testCalculateHoursAndMinutes() {
        // Test case 1: Calculate hours and minutes between two valid dates
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        
        if let startDate = dateFormatter.date(from: "2023-10-13 10:00:00"),
           let endDate = dateFormatter.date(from: "2023-10-13 14:30:00") {
            let result = Reusable().calculateHoursAndMinutes(startDate: startDate, endDate: endDate)
            XCTAssertEqual(result.hours, 4, "Hours should be 4")
            XCTAssertEqual(result.minutes, 30, "Minutes should be 30")
        } else {
            XCTFail("Failed to create valid dates for test case 1")
        }
        
        // Test case 2: Calculate hours and minutes when start date is nil
        let endDate = dateFormatter.date(from: "2023-10-13 14:30:00")!
        let result2 = Reusable().calculateHoursAndMinutes(startDate: nil, endDate: endDate)
        XCTAssertEqual(result2.hours, 0, "Hours should be 0 when start date is nil")
        XCTAssertEqual(result2.minutes, 0, "Minutes should be 0 when start date is nil")
        
        // Test case 3: Calculate hours and minutes when end date is nil
        let startDate = dateFormatter.date(from: "2023-10-13 10:00:00")!
        let result3 = Reusable().calculateHoursAndMinutes(startDate: startDate, endDate: nil)
        XCTAssertEqual(result3.hours, 0, "Hours should be 0 when end date is nil")
        XCTAssertEqual(result3.minutes, 0, "Minutes should be 0 when end date is nil")
        
        // Test case 4: Calculate hours and minutes when both dates are nil
        let result4 = Reusable().calculateHoursAndMinutes(startDate: nil, endDate: nil)
        XCTAssertEqual(result4.hours, 0, "Hours should be 0 when both dates are nil")
        XCTAssertEqual(result4.minutes, 0, "Minutes should be 0 when both dates are nil")
    }
    
    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
}
