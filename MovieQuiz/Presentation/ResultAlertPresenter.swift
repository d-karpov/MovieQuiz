//
//  AlertPresenter.swift
//  MovieQuiz
//
//  Created by Денис Карпов on 19.05.2024.
//

import UIKit

protocol ResultAlertPresenterProtocol {
	func show(with model: QuizResultsViewModel)
}

final class ResultAlertPresenter: ResultAlertPresenterProtocol {
	weak var view: UIViewController?
	
	func show(with model: QuizResultsViewModel) {
		let alert = UIAlertController(
			title: model.title,
			message: model.message,
			preferredStyle: .alert
		)
		
		let action = UIAlertAction(title: model.buttonText, style: .default) { _ in
			model.completion()
		}
		
		alert.addAction(action)
		
		guard let view = view else { return }
		view.present(alert, animated: true)
	}
}
