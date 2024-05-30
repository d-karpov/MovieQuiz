//
//  GameRecord.swift
//  MovieQuiz
//
//  Created by Денис Карпов on 20.05.2024.
//

import Foundation

struct GameRecord: Codable {
	let correct: Int
	let total: Int
	let date: Date
	
	func isBetterThan(_ another: GameRecord) -> Bool {
		correct > another.correct
	}
}
