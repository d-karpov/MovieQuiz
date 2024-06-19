//
//  NetworkService.swift
//  MovieQuiz
//
//  Created by Денис Карпов on 01.06.2024.
//

import Foundation

protocol NetworkServiceProtocol {
	func fetch(url: URL, handler: @escaping(Result<Data,Error>) -> Void)
}

struct NetworkService: NetworkServiceProtocol {
	
	private enum NetworkError: Error {
		case codeError
	}
	
	func fetch(url: URL, handler: @escaping(Result<Data, Error>) -> Void) {
		let request = URLRequest(url: url)
		
		let task = URLSession.shared.dataTask(with: request) { data, response, error in
			if let error = error {
				handler(.failure(error))
				return
			}
			
			if let response = response as? HTTPURLResponse, response.statusCode < 200 || response.statusCode >= 300 {
				handler(.failure(NetworkError.codeError))
				return
			}
			
			guard let data = data else { return }
			handler(.success(data))
		}
		
		task.resume()
	}
}
