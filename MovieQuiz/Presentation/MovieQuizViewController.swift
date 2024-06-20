import UIKit

final class MovieQuizViewController: UIViewController {
//MARK: - IBOutlets
	@IBOutlet weak private var counterLabel: UILabel!
	@IBOutlet weak private var questionLabel: UILabel!
	@IBOutlet weak private var coverImageView: UIImageView!
	@IBOutlet weak private var noButton: UIButton!
	@IBOutlet weak private var yesButton: UIButton!
	@IBOutlet weak var activityIndicator: UIActivityIndicatorView!
	@IBOutlet weak var mainStackView: UIStackView!
	
//MARK: - Private variables
	private var correctAnswers: Int = 0
	private var questionFactory: QuestionFactoryProtocol?
	private var currentQuestion: QuizQuestion?
	private var alertPresenter: AlertPresenterProtocol?
	private let statisticService: StatisticServiceProtocol = StatisticService.shared
	private lazy var presenter = MovieQuizPresenter(viewController: self)

// MARK: - Lifecycle
	override var preferredStatusBarStyle: UIStatusBarStyle {
		.lightContent
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		showLoadingIndicator()
		
		questionFactory = QuestionFactory(
			moviesLoader: MoviesLoader(),
			delegate: self
		)
		questionFactory?.loadData()
		
		let alertPresenter = AlertPresenter()
		alertPresenter.view = self
		self.alertPresenter = alertPresenter
		
		yesButton.isExclusiveTouch = true
		noButton.isExclusiveTouch = true
	}
	
//MARK: - Private methods
	private func show(quiz step: QuizStepViewModel) {
		coverImageView.layer.borderWidth = 0
		
		coverImageView.image = step.image
		counterLabel.text = step.questionNumber
		questionLabel.text = step.question
	}
	
	func showAnswerResult(isCorrect: Bool) {
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
		if presenter.isLastQuestion() {
			statisticService.store(correct: correctAnswers, total: presenter.questionsAmount)
			let message = "Ваш результат: \(correctAnswers)/\(presenter.questionsAmount)\n"
			let result = QuizResultsViewModel(
				title: "Этот раунд окончен!",
				message: message + statisticService.getStatisticMessage(),
				buttonText: "Сыграть ещё раз",
				completion: showFirstQuestion
			)
			alertPresenter?.show(with: result)
		} else {
			presenter.switchToNextQuestion()
			questionFactory?.requestNextQuestion()
		}
	}
	
	private func showFirstQuestion() {
		correctAnswers = 0
		presenter.resetQuestionIndex()
		questionFactory?.requestNextQuestion()
	}
	
	private func showLoadingIndicator() {
		mainStackView.isHidden = true
		activityIndicator.startAnimating()
	}
	
	private func hideLoadingIndicator() {
		activityIndicator.stopAnimating()
	}
	
	private func showNetworkError(with message: String) {
		hideLoadingIndicator()

		let networkAlert = AlertModel(
			title: "Ошибка",
			message: message,
			buttonText: "Попробовать ещё раз",
			completion: {
				self.showLoadingIndicator()
				self.questionFactory?.loadData()
			}
		)
		
		alertPresenter?.show(with: networkAlert)
	}

//MARK: - IBActions
	@IBAction private func yesButtonClicked(_ sender: UIButton) {
		presenter.yesButtonClicked()
	}
	
	@IBAction private func noButtonClicked(_ sender: UIButton) {
		presenter.noButtonClicked()
	}
}

//MARK: - QuestionFactoryDelegate
extension MovieQuizViewController: QuestionFactoryDelegate {
	func didReceiveNextQuestion(question: QuizQuestion?) {
		guard let question = question else { return }
		
		currentQuestion = question
		let viewModel = presenter.convert(model: question)
		
		DispatchQueue.main.async { [weak self] in
			self?.mainStackView.isHidden = false
			self?.show(quiz: viewModel)
		}
	}
	
	func didLoadDataFromServer() {
		hideLoadingIndicator()
		showFirstQuestion()
	}
	
	func didFailToLoadData(with error: Error) {
		showNetworkError(with: error.localizedDescription)
	}
}
