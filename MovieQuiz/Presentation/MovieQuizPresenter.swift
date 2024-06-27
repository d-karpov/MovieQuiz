//
//  MovieQuizPresenter.swift
//  MovieQuiz
//
//  Created by Денис Карпов on 20.06.2024.
//

import Foundation

final class MovieQuizPresenter {
	
//MARK: - Private Variables
	private var currentQuestionIndex: Int = 0
	private var correctAnswers: Int = 0
	private var currentQuestion: QuizQuestion?
	private var questionFactory: QuestionFactoryProtocol?
	private let questionsAmount: Int = 10
	private let statisticService: StatisticServiceProtocol = StatisticService.shared
	private weak var viewController: MovieQuizViewControllerProtocol?
	
//MARK: - Initialiser
	init(viewController: MovieQuizViewControllerProtocol) {
		self.viewController = viewController
		questionFactory = QuestionFactory(moviesLoader: MoviesLoader(), delegate: self)
	}
	
//MARK: - Public Methods
	func startInitialLoading() {
		questionFactory?.loadData()
		viewController?.setOpacityOfContentTo(value: 0.0)
		viewController?.hideMainStackView()
		viewController?.showLoadingIndicator()
	}
	
	func yesButtonClicked() {
		didAnswer(isYes: true)
	}
	
	func noButtonClicked() {
		didAnswer(isYes: false)
	}
	
//TODO: Вынесено для тестирования и сдачи, в целом должно быть закрыто как private метод
	func convert(model: QuizQuestion) -> QuizStepViewModel {
		QuizStepViewModel(
			imageData: model.image,
			question: model.text,
			questionNumber: "\(currentQuestionIndex + 1)/\(questionsAmount)"
		)
	}
	
//MARK: - Private Methods
	private func restartGame() {
		correctAnswers = 0
		currentQuestionIndex = 0
		questionFactory?.requestNextQuestion()
	}
	
	private func proceedNextQuestionOrResult() {
		if currentQuestionIndex == questionsAmount - 1 {
			statisticService.store(correct: correctAnswers, total: questionsAmount)
			let message = "Ваш результат: \(correctAnswers)/\(questionsAmount)\n"
			let result = QuizResultsViewModel(
				title: "Этот раунд окончен!",
				message: message + statisticService.getStatisticMessage(),
				buttonText: "Сыграть ещё раз",
				completion: restartGame
			)
			viewController?.show(quiz: result)
		} else {
			currentQuestionIndex += 1
			viewController?.showLoadingIndicator()
			viewController?.setOpacityOfContentTo(value: 0.0)
			questionFactory?.requestNextQuestion()
		}
	}
	
	private func proceedAnswerResult(isCorrect: Bool) {
		viewController?.highlightCoverBorder(isCorrectAnswer: isCorrect)
		didAnswer(isCorrect: isCorrect)
		viewController?.enableButtons(isEnable: false)
		DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
			self?.proceedNextQuestionOrResult()
		}
	}
	
	private func didAnswer(isCorrect: Bool) {
		if isCorrect {
			correctAnswers += 1
		}
	}
	
	private func didAnswer(isYes: Bool) {
		guard let currentQuestion = currentQuestion else { return }
		proceedAnswerResult(isCorrect: currentQuestion.correctAnswer == isYes)
	}
}

//MARK: - QuestionFactoryDelegate
extension MovieQuizPresenter: QuestionFactoryDelegate {
	func didReceiveNextQuestion(question: QuizQuestion?) {
		guard let question = question else { return }
		
		currentQuestion = question
		let viewModel = convert(model: question)
		
		DispatchQueue.main.async { [weak self] in
			self?.viewController?.hideLoadingIndicator()
			self?.viewController?.show(quiz: viewModel)
			self?.viewController?.animationOfQuestion()
			self?.viewController?.setOpacityOfContentTo(value: 1.0)
			self?.viewController?.enableButtons(isEnable: true)
		}
	}
	
	func didLoadDataFromServer() {
		viewController?.hideLoadingIndicator()
		viewController?.showMainStackView()
		restartGame()
	}
	
	func didFailToLoadData(with error: any Error) {
		viewController?.hideMainStackView()
		viewController?.hideLoadingIndicator()
		
		let networkAlert = AlertModel(
			title: "Ошибка",
			message: error.localizedDescription,
			buttonText: "Попробовать ещё раз",
			completion: { [weak self] in
				self?.startInitialLoading()
			}
		)
		
		viewController?.showNetworkError(with: networkAlert)
	}
	
}
