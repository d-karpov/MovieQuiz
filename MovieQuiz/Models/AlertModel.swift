//
//  AlertModel.swift
//  MovieQuiz
//
//  Created by Денис Карпов on 19.05.2024.
//

import Foundation

struct AlertModel {
	let title: String
	let message: String
	let buttonText: String
	let completion: () -> Void
}
