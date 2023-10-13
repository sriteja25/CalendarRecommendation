//
//  CalenderReceommendationsUITests.swift
//  CalenderReceommendationsUITests
//
//  Created by Sriteja Chilakamarri on 10/10/2023.
//

import XCTest

final class CalenderReceommendationsUITests: XCTestCase {
    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false
        
        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }
    
    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func testExample() throws {
        // UI tests must launch the application that they test.
        let app = XCUIApplication()
        app.launch()
        
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }
    
    func testLaunchPerformance() throws {
        if #available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 7.0, *) {
            // This measures how long it takes to launch your application.
            measure(metrics: [XCTApplicationLaunchMetric()]) {
                XCUIApplication().launch()
            }
        }
    }
    
    func testCalendarInteraction() throws {
        let app = XCUIApplication()
        app.launch() // Launch your app
        
        // Will fail because map view is hidden till an event is selected
        let mapView = app.maps["Calendar"]
        XCTAssertTrue(mapView.waitForExistence(timeout: 10), "MKMapView not found")
        
        // Tap on the MKMapView to trigger the tap gesture
        mapView.tap()
        
        // Wait for the alert controller to appear
        let alert = app.alerts.element
        XCTAssertTrue(alert.waitForExistence(timeout: 5), "Alert controller not displayed")
        
        // Verify the alert controller's buttons
        let appleMapsButton = alert.buttons["Apple Maps"]
        let googleMapsButton = alert.buttons["Google Maps"]
        let cancelButton = alert.buttons["Cancel"]
        
        XCTAssertTrue(appleMapsButton.exists, "Apple Maps button not found")
        XCTAssertTrue(googleMapsButton.exists, "Google Maps button not found")
        XCTAssertTrue(cancelButton.exists, "Cancel button not found")
        
        // Simulate tapping the "Apple Maps" button
        appleMapsButton.tap()
    }
    
    func testMapInteraction() throws {
        let app = XCUIApplication()
        app.launch() // Launch your app
        
        // Will fail because map view is hidden till an event is selected
        let mapView = app.maps["MapView"]
        XCTAssertTrue(mapView.waitForExistence(timeout: 10), "MKMapView not found")
        
        // Tap on the MKMapView to trigger the tap gesture
        mapView.tap()
        
        // Wait for the alert controller to appear
        let alert = app.alerts.element
        XCTAssertTrue(alert.waitForExistence(timeout: 5), "Alert controller not displayed")
        
        // Verify the alert controller's buttons
        let appleMapsButton = alert.buttons["Apple Maps"]
        let googleMapsButton = alert.buttons["Google Maps"]
        let cancelButton = alert.buttons["Cancel"]
        
        XCTAssertTrue(appleMapsButton.exists, "Apple Maps button not found")
        XCTAssertTrue(googleMapsButton.exists, "Google Maps button not found")
        XCTAssertTrue(cancelButton.exists, "Cancel button not found")
        
        // Simulate tapping the "Apple Maps" button
        appleMapsButton.tap()
    }
}
