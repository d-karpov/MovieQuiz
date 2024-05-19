import UIKit

final class MovieQuizViewController: UIViewController {
//MARK: - IBOutlets
	@IBOutlet weak private var counterLabel: UILabel!
	@IBOutlet weak private var questionLabel: UILabel!
	@IBOutlet weak private var coverImageView: UIImageView!
	@IBOutlet weak private var noButton: UIButton!
	@IBOutlet weak private var yesButton: UIButton!
	
//MARK: - Private variables
	private var currentQuestionIndex: Int = 0
	private var correctAnswers: Int = 0
	private let questionsAmount = 10
	private var questionFactory: QuestionFactoryProtocol?
	private var currentQuestion: QuizQuestion?
	private var alertPresenter: AlertPresenterProtocol?

// MARK: - Lifecycle
	override var preferredStatusBarStyle: UIStatusBarStyle {
		.lightContent
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		let questionFactory = QuestionFactory()
		questionFactory.delegate = self
		self.questionFactory = questionFactory
		
		let alertPresenter = AlertPresenter()
		alertPresenter.view = self
		self.alertPresenter = alertPresenter
		
		yesButton.isExclusiveTouch = true
		noButton.isExclusiveTouch = true
		showFirstQuestion()
	}
	
//MARK: - Private methods
	private func convert(model: QuizQuestion) -> QuizStepViewModel {
			return QuizStepViewModel(
				image: UIImage(named: model.image) ?? UIImage(),
				question: model.text,
				questionNumber: "\(currentQuestionIndex + 1)/\(questionsAmount)"
			)
		}
	
	private func show(quiz step: QuizStepViewModel) {
		coverImageView.layer.borderWidth = 0
		
		coverImageView.image = step.image
		counterLabel.text = step.questionNumber
		questionLabel.text = step.question
	}
	
	private func showAnswerResult(isCorrect: Bool) {
		coverImageView.layer.masksToBounds = true
		coverImageView.layer.borderWidth = 8
		coverImageView.layer.borderColor = isCorrect ? UIColor(.ypGreen).cgColor : UIColor(.ypRed).cgColor
		if isCorrect {
			correctAnswers += 1
		}
		yesButton.isEnabled = false
		noButton.isEnabled = false
		DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
			guard let self = self else { return }
			self.showNextQuestionOrResult()
			self.yesButton.isEnabled = true
			self.noButton.isEnabled = true
		}
	}
	
	private func showNextQuestionOrResult() {
		if currentQuestionIndex == questionsAmount - 1 {
			let message = correctAnswers == questionsAmount ?
			"Поздравляем, вы ответили на 10 из 10!" : "Вы ответили на \(correctAnswers) из 10, попробуйте ещё раз!"
			let result = AlertModel(
				title: "Этот раунд окончен!",
				message: message,
				buttonText: "Сыграть ещё раз",
				completion: showFirstQuestion
			)
			alertPresenter?.show(with: result)
		} else {
			currentQuestionIndex += 1
			questionFactory?.requestNextQuestion()
		}
	}
	
	private func showFirstQuestion() {
		correctAnswers = 0
		currentQuestionIndex = 0
		questionFactory?.requestNextQuestion()
	}

//MARK: - IBActions
	@IBAction private func yesButtonClicked(_ sender: UIButton) {
		guard let currentQuestion = currentQuestion else { return }
		showAnswerResult(isCorrect: currentQuestion.correctAnswer == true)
	}
	
	@IBAction private func noButtonClicked(_ sender: UIButton) {
		guard let currentQuestion = currentQuestion else { return }
		showAnswerResult(isCorrect: currentQuestion.correctAnswer == false)
	}
}

//MARK: - QuestionFactoryDelegate
extension MovieQuizViewController: QuestionFactoryDelegate {
	func didReceiveNextQuestion(question: QuizQuestion?) {
		guard let question = question else { return }
		
		currentQuestion = question
		let viewModel = convert(model: question)
		
		DispatchQueue.main.async { [weak self] in
			self?.show(quiz: viewModel)
		}
	}
}
