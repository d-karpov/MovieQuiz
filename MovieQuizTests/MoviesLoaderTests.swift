//
//  MoviesLoaderTests.swift
//  MovieQuizTests
//
//  Created by Денис Карпов on 19.06.2024.
//

import XCTest
@testable import MovieQuiz

class MoviesLoaderTests: XCTestCase {
	
	func testSuccessLoading() throws {
		let stubNetworkClient = StubNetworkClient(emulateError: false)
		let loader = MoviesLoader(networkClient: stubNetworkClient)
		
		let expectation = expectation(description: "Loading expectation")
		
		loader.loadMovies { result in
			switch result {
			case .success(let movies):
				XCTAssertEqual(movies.items.count, 2)
				expectation.fulfill()
			case .failure(_):
				XCTFail("Unexpected loader failure")
			}
		}
		waitForExpectations(timeout: 1)
	}
	
	func testFailureLoading() throws {
		let stubNetworkClient = StubNetworkClient(emulateError: true)
		let loader = MoviesLoader(networkClient: stubNetworkClient)
		
		let expectation = expectation(description: "Loading expectation")
		
		loader.loadMovies { result in
			switch result {
			case .success(_):
				XCTFail("Unexpected loader failure")
			case .failure(let error):
				XCTAssertNotNil(error)
				expectation.fulfill()
			}
		}
		waitForExpectations(timeout: 1)
	}
	
}
