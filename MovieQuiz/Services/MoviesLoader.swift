//
//  MoviesLoader.swift
//  MovieQuiz
//
//  Created by Денис Карпов on 01.06.2024.
//

import Foundation

protocol MoviesLoaderProtocol {
	func loadMovies(handler: @escaping (Result<MostPopularMovies, Error>) -> Void)
}


struct MoviesLoader: MoviesLoaderProtocol {
	
//MARK: - Private Variable
	private enum ErrorsOfAPI: Error, LocalizedError {
		case errorFromAPI(String)
		
		var errorDescription: String? {
			switch self {
			case .errorFromAPI(let errorMessage):
				"\(errorMessage)"
			}
		}
	}
	
	private var mostPopularMoviesUrl: URL {
		guard let url = URL(string: "https://tv-api.com/en/API/Top250Movies/k_zcuw1ytf") else {
			preconditionFailure("Unable to construct mostPopularMoviesUrl")
		}
		return url
	}
	
	private let networkClient: NetworkServiceProtocol

//MARK: - Initialiser
	init(networkClient: NetworkServiceProtocol = NetworkService()) {
		self.networkClient = networkClient
	}
	
//MARK: - Public Method
	func loadMovies(handler: @escaping (Result<MostPopularMovies, Error>) -> Void) {
		networkClient.fetch(url: mostPopularMoviesUrl) { result in
			switch result {
			case .success(let data):
				do {
					let mostPopularMovies = try JSONDecoder().decode(MostPopularMovies.self, from: data)
					if !mostPopularMovies.errorMessage.isEmpty {
						handler(.failure(ErrorsOfAPI.errorFromAPI(mostPopularMovies.errorMessage)))
					} else {
						handler(.success(mostPopularMovies))
					}
				} catch {
					handler(.failure(error))
				}
			case .failure(let error):
				handler(.failure(error))
			}
		}
	}
}
