//
//  MovieQuizPresenter.swift
//  MovieQuiz
//
//  Created by Денис Карпов on 20.06.2024.
//

import UIKit


final class MovieQuizPresenter {
	
	private var currentQuestionIndex: Int = 0
	private var currentQuestion: QuizQuestion?
	private weak var viewController: MovieQuizViewController?
	
	let questionsAmount: Int = 10
	
	init(viewController: MovieQuizViewController) {
		self.viewController = viewController
	}
	
	func convert(model: QuizQuestion) -> QuizStepViewModel {
		QuizStepViewModel(
			image: UIImage(data: model.image) ?? UIImage(),
			question: model.text,
			questionNumber: "\(currentQuestionIndex + 1)/\(questionsAmount)"
		)
	}
	
	func isLastQuestion() -> Bool {
		currentQuestionIndex == questionsAmount - 1
	}
	
	func resetQuestionIndex() {
		currentQuestionIndex = 0
	}
	
	func switchToNextQuestion() {
		currentQuestionIndex += 1
	}
	
	func yesButtonClicked() {
		guard let currentQuestion = currentQuestion else { return }
		viewController?.showAnswerResult(isCorrect: currentQuestion.correctAnswer == true)
	}
	
	func noButtonClicked() {
		guard let currentQuestion = currentQuestion else { return }
		viewController?.showAnswerResult(isCorrect: currentQuestion.correctAnswer == false)
	}
}
