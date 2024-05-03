import UIKit

final class MovieQuizViewController: UIViewController {
	//MARK: - IBOutlets
	@IBOutlet weak private var counterLabel: UILabel!
	@IBOutlet weak private var questionLabel: UILabel!
	@IBOutlet weak private var coverImageView: UIImageView!
	
	//MARK: - Private variables
	private var currentQuestionIndex: Int = 0
	private var correctAnswers: Int = 0
	
	private struct QuizQuestion {
		let image: String
		let text: String
		let correctAnswer: Bool
	}
	
	private struct QuizStepViewModel {
		let image: UIImage
		let question: String
		let questionNumber: String
	}
	
	private struct QuizResultViewModel {
		let title: String
		let text: String
		let buttonText: String
	}
	
	// MARK: - Mock data
	private let questions: [QuizQuestion] = [
		QuizQuestion(
			image: "The Godfather",
			text: "Рейтинг этого фильма больше чем 6?",
			correctAnswer: true
		),
		QuizQuestion(
			image: "The Dark Knight",
			text: "Рейтинг этого фильма больше чем 6?",
			correctAnswer: true
		),
		QuizQuestion(
			image: "Kill Bill",
			text: "Рейтинг этого фильма больше чем 6?",
			correctAnswer: true
		),
		QuizQuestion(
			image: "The Avengers",
			text: "Рейтинг этого фильма больше чем 6?",
			correctAnswer: true
		),
		QuizQuestion(
			image: "Deadpool",
			text: "Рейтинг этого фильма больше чем 6?",
			correctAnswer: true
		),
		QuizQuestion(
			image: "The Green Knight",
			text: "Рейтинг этого фильма больше чем 6?",
			correctAnswer: true
		),
		QuizQuestion(
			image: "Old",
			text: "Рейтинг этого фильма больше чем 6?",
			correctAnswer: false
		),
		QuizQuestion(
			image: "The Ice Age Adventures of Buck Wild",
			text: "Рейтинг этого фильма больше чем 6?",
			correctAnswer: false
		),
		QuizQuestion(
			image: "Tesla",
			text: "Рейтинг этого фильма больше чем 6?",
			correctAnswer: false
		),
		QuizQuestion(
			image: "Vivarium",
			text: "Рейтинг этого фильма больше чем 6?",
			correctAnswer: false
		)
	]
	
	// MARK: - Lifecycle
	override func viewDidLoad() {
		super.viewDidLoad()
		showFirstQuestion()
	}
	
	//MARK: - Private methods
	private func convert(model: QuizQuestion) -> QuizStepViewModel {
			return QuizStepViewModel(
				image: UIImage(named: model.image) ?? UIImage(),
				question: model.text,
				questionNumber: "\(currentQuestionIndex + 1)/\(questions.count)"
			)
		}
	
	private func show(quiz step: QuizStepViewModel) {
		//убираем рамку-результат, так как по макету вопрос без ответа не имеет рамки
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
		DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
			self.showNextQuestionOrResult()
		}
	}
	
	private func showNextQuestionOrResult() {
		if currentQuestionIndex == questions.count - 1 {
			let result = QuizResultViewModel(
				title: "Этот раунд окончен!",
				text: "Ваш результат: \(correctAnswers)/\(questions.count)",
				buttonText: "Сыграть ещё раз"
			)
			show(quiz: result)
		} else {
			currentQuestionIndex += 1
			let nextQuestion = questions[currentQuestionIndex]
			let viewModel = convert(model: nextQuestion)
			show(quiz: viewModel)
		}
	}
	
	private func showFirstQuestion() {
		correctAnswers = 0
		currentQuestionIndex = 0
		let fistQuestion = questions[currentQuestionIndex]
		let viewModel = convert(model: fistQuestion)
		show(quiz: viewModel)
	}
	
	private func show(quiz result: QuizResultViewModel) {
		let alert = UIAlertController(
			title: result.title,
			message: result.text,
			preferredStyle: .alert
		)
		
		let action = UIAlertAction(title: result.buttonText, style: .default) { _ in
			self.showFirstQuestion()
		}
		
		alert.addAction(action)
		
		self.present(alert, animated: true)
	}

	//MARK: - IBActions
	@IBAction private func yesButtonClicked(_ sender: UIButton) {
		showAnswerResult(isCorrect: questions[currentQuestionIndex].correctAnswer == true)
	}
	
	@IBAction private func noButtonClicked(_ sender: UIButton) {
		showAnswerResult(isCorrect: questions[currentQuestionIndex].correctAnswer == false)
	}
}
