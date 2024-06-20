//
//  MovieQuizViewControllerProtocol.swift
//  MovieQuiz
//
//  Created by Денис Карпов on 20.06.2024.
//

import Foundation

protocol MovieQuizViewControllerProtocol: AnyObject {
	func show(quiz step: QuizStepViewModel)
	func show(quiz result: QuizResultsViewModel)
	func enableButtons(isEnable: Bool)
	func highlightCoverBorder(isCorrectAnswer: Bool)
	func showLoadingIndicator()
	func hideLoadingIndicator()
	func showMainStackView()
	func hideMainStackView()
	func showNetworkError(with message: String)
}
