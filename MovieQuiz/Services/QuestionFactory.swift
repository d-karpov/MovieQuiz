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
			
			let rating = Float(movie.rating) ?? 0
			let text = "Рейтинг этого фильма больше, чем \(Int(rating)) ?"
			let correctAnswer = rating > Float(Int(rating))
			let question = QuizQuestion(
				image: imageData,
				text: text,
				correctAnswer: correctAnswer
			)
			
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
}
