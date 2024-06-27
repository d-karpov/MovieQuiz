//
//  MovieQuizUITests.swift
//  MovieQuizUITests
//
//  Created by Денис Карпов on 19.06.2024.
//

import XCTest

final class MovieQuizUITests: XCTestCase {
	
	var app: XCUIApplication!
	
	override func setUpWithError() throws {
		try super.setUpWithError()
		
		app = XCUIApplication()
		app.launch()
		
		continueAfterFailure = false
	}
	
	override func tearDownWithError() throws {
		try super.tearDownWithError()
		
		app.terminate()
		app = nil
	}
	
	func testYesButton() throws {
		sleep(3)
		let firstPoster = app.images["Poster"]
		let firstPosterData = firstPoster.screenshot().pngRepresentation
		
		app.buttons["Yes"].tap()
		sleep(3)
		let indexLabel = app.staticTexts["Index"].label
		let secondPoster = app.images["Poster"]
		let secondPosterData = secondPoster.screenshot().pngRepresentation
		
		XCTAssertNotEqual(firstPosterData, secondPosterData)
		XCTAssertEqual(indexLabel, "2/10")
	}
	
	func testNoButton() throws {
		sleep(3)
		let firstPoster = app.images["Poster"]
		let firstPosterData = firstPoster.screenshot().pngRepresentation
		
		app.buttons["No"].tap()
		sleep(3)
		let indexLabel = app.staticTexts["Index"].label
		let secondPoster = app.images["Poster"]
		let secondPosterData = secondPoster.screenshot().pngRepresentation
		
		XCTAssertNotEqual(firstPosterData, secondPosterData)
		XCTAssertEqual(indexLabel, "2/10")
	}
	
	func testAlertPresent() throws {
		(1...10).forEach { _ in
			app.buttons["Yes"].tap()
			sleep(2)
		}
		let alert = app.alerts["Alert"]
		let alertTitle = alert.label
		let alertButtonText = alert.buttons.firstMatch.label
		
		XCTAssertTrue(alert.exists)
		XCTAssertEqual(alertTitle, "Этот раунд окончен!")
		XCTAssertEqual(alertButtonText, "Сыграть ещё раз")
	}
	
	func testAlertDismiss() throws {
		(1...10).forEach { _ in
			app.buttons["No"].tap()
			sleep(2)
		}
		let alert = app.alerts["Alert"]
		let alertButton = alert.buttons.firstMatch
		
		alertButton.tap()
		sleep(1)
		let indexLabel = app.staticTexts["Index"].label
		
		XCTAssertFalse(alert.exists)
		XCTAssertEqual(indexLabel, "1/10")
	}
}
