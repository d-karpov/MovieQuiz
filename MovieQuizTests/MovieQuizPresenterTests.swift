//
//  MovieQuizPresenterTests.swift
//  MovieQuizTests
//
//  Created by Денис Карпов on 20.06.2024.
//

import XCTest
@testable import MovieQuiz

final class MovieViewControllerMock: MovieQuizViewControllerProtocol {
	func show(quiz step: MovieQuiz.QuizStepViewModel) { }
	func show(quiz result: MovieQuiz.QuizResultsViewModel) { }
	func enableButtons(isEnable: Bool) { }
	func highlightCoverBorder(isCorrectAnswer: Bool) { }
	func showLoadingIndicator() { }
	func hideLoadingIndicator() { }
	func showMainStackView() { }
	func hideMainStackView() { }
	func showNetworkError(with networkAlert: AlertModelProtocol) { }
	func animationOfQuestion() { }
	func setOpacityOfContentTo(value: Float) { }
}

final class MovieQuizPresenterTests: XCTestCase {
	
	func testPresenterConvertModel() throws {
		let viewControllerMock = MovieViewControllerMock()
		let sut = MovieQuizPresenter(viewController: viewControllerMock)
		
		let emptyData = Data()
		let question = QuizQuestion(image: emptyData, text: "Question text", correctAnswer: true)
		let viewModel = sut.convert(model: question)
		
		XCTAssertNotNil(viewModel.imageData)
		XCTAssertEqual(viewModel.question, "Question text")
		XCTAssertEqual(viewModel.questionNumber, "1/10")
	}
}
