//
//  QuizResultsViewModel.swift
//  MovieQuiz
//
//  Created by Денис Карпов on 19.05.2024.
//

import Foundation

struct QuizResultsViewModel: AlertModelProtocol {
	let title: String
	let message: String
	let buttonText: String
	let completion: () -> Void
}
