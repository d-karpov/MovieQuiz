//
//  AlertModel.swift
//  MovieQuiz
//
//  Created by Денис Карпов on 01.06.2024.
//

import Foundation

protocol AlertModelProtocol {
	var title: String { get }
	var message: String { get }
	var buttonText: String { get }
	var completion: () -> Void { get }
}

struct AlertModel: AlertModelProtocol {
	let title: String
	let message: String
	let buttonText: String
	let completion: () -> Void
}
