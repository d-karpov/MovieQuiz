import UIKit

final class MovieQuizViewController: UIViewController {
//MARK: - IBOutlets
	@IBOutlet weak private var counterLabel: UILabel!
	@IBOutlet weak private var questionLabel: UILabel!
	@IBOutlet weak private var coverImageView: UIImageView!
	@IBOutlet weak private var noButton: UIButton!
	@IBOutlet weak private var yesButton: UIButton!
	@IBOutlet weak private var activityIndicator: UIActivityIndicatorView!
	@IBOutlet weak private var mainStackView: UIStackView!
	
//MARK: - Private variables
	private lazy var alertPresenter: AlertPresenterProtocol = AlertPresenter(view: self)
	private lazy var presenter: MovieQuizPresenter = .init(viewController: self)

//MARK: - Lifecycle
	override var preferredStatusBarStyle: UIStatusBarStyle {
		.lightContent
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		presenter.startInitialLoading()
		
		yesButton.isExclusiveTouch = true
		noButton.isExclusiveTouch = true
	}
	
//MARK: - Public methods
	func show(quiz step: QuizStepViewModel) {
		coverImageView.layer.borderWidth = 0
		
		coverImageView.image = UIImage(data: step.imageData) ?? UIImage(systemName: "photo")
		counterLabel.text = step.questionNumber
		questionLabel.text = step.question
	}
	
	func show(quiz result: QuizResultsViewModel) {
		alertPresenter.show(with: result)
	}
	
	func enableButtons(isEnable: Bool) {
		yesButton.isEnabled = isEnable
		noButton.isEnabled = isEnable
	}
	
	func highlightCoverBorder(isCorrectAnswer: Bool) {
		coverImageView.layer.masksToBounds = true
		coverImageView.layer.borderWidth = 8
		coverImageView.layer.borderColor = isCorrectAnswer ? UIColor(.ypGreen).cgColor : UIColor(.ypRed).cgColor
	}
	
	func showLoadingIndicator() {
		activityIndicator.startAnimating()
	}
	
	func hideLoadingIndicator() {
		activityIndicator.stopAnimating()
	}
	
	func hideMainStackView() {
		mainStackView.isHidden = true
	}
	
	func showMainStackView() {
		mainStackView.isHidden = false
	}
	
	func showNetworkError(with message: String) {
		hideLoadingIndicator()

		let networkAlert = AlertModel(
			title: "Ошибка",
			message: message,
			buttonText: "Попробовать ещё раз",
			completion: {
				self.presenter.startInitialLoading()
			}
		)
		
		alertPresenter.show(with: networkAlert)
	}

//MARK: - IBActions
	@IBAction private func yesButtonClicked(_ sender: UIButton) {
		presenter.yesButtonClicked()
	}
	
	@IBAction private func noButtonClicked(_ sender: UIButton) {
		presenter.noButtonClicked()
	}
}
