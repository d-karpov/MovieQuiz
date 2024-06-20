//
//  QuestionFactory.swift
//  MovieQuiz
//
//  Created by Денис Карпов on 19.05.2024.
//

import Foundation

final class QuestionFactory: QuestionFactoryProtocol {
	
	//MARK: - Public Variable
	weak var delegate: QuestionFactoryDelegate?
	
	//MARK: - Private Variable
	private let moviesLoader: MoviesLoaderProtocol
	private var movies: [MostPopularMovie] = []
	private enum MoreOrLess: String, CaseIterable {
		case more = "больше"
		case less = "меньше"
	}
	
	//MARK: - Initialiser
	init(moviesLoader: MoviesLoaderProtocol, delegate: QuestionFactoryDelegate?) {
		self.moviesLoader = moviesLoader
		self.delegate = delegate
	}
	
	//MARK: - Public Methods
	func requestNextQuestion() {
		DispatchQueue.global().async { [weak self] in
			guard let self = self else { return }
			
			let index = (0..<self.movies.count).randomElement() ?? 0
			guard let movie = self.movies[safe: index] else { return }
			var imageData: Data?
			
			do {
				imageData = try Data(contentsOf: movie.resizedImageURL)
			} catch {
				DispatchQueue.main.async {
					self.delegate?.didFailToLoadData(with: error)
				}
			}
			guard let imageData = imageData else { return }
			
			let question = prepareQuestion(rating: movie.rating, imageData: imageData)
			
			DispatchQueue.main.async { [weak self] in
				guard let self = self else { return }
				self.delegate?.didReceiveNextQuestion(question: question)
			}
		}
	}
	
	func loadData() {
		moviesLoader.loadMovies { [weak self] result in
			DispatchQueue.main.async {
				guard let self = self else { return }
				switch result {
				case .success(let mostPopularMovies):
					self.movies = mostPopularMovies.items
					self.delegate?.didLoadDataFromServer()
					
				case .failure(let error):
					self.delegate?.didFailToLoadData(with: error)
				}
			}
		}
	}
	
	private func prepareQuestion(rating: String, imageData: Data) -> QuizQuestion {
		var correctAnswer: Bool
		var text: String
		
		let rating = Float(rating) ?? 0.0
		let questionRating = roundf(Float.random(in: (8...9.5)) * 10) / 10.0
		
		switch MoreOrLess.allCases.randomElement() ?? .more {
		case .more:
			correctAnswer = rating > questionRating
			text = "Рейтинг этого фильма \(MoreOrLess.more.rawValue), чем \(questionRating) ?"
		case .less:
			correctAnswer = rating < Float(questionRating)
			text = "Рейтинг этого фильма \(MoreOrLess.less.rawValue), чем \(questionRating) ?"
		}
		
		return QuizQuestion(
			image: imageData,
			text: text,
			correctAnswer: correctAnswer
		)
		
	}
}
