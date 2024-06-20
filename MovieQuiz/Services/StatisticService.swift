//
//  StatisticService.swift
//  MovieQuiz
//
//  Created by Денис Карпов on 20.05.2024.
//

import Foundation

//MARK: - StatisticServiceProtocol
protocol StatisticServiceProtocol {
	func store(correct count: Int, total amount: Int)
	func getStatisticMessage() -> String
}

//MARK: - StatisticService
final class StatisticService {

//MARK: - Public Variable
	static let shared = StatisticService()
	
//MARK: - Private Variable
	private enum UserDefaultsKeys: String {
		case correct, total, bestGame, gameCount
	}
	
	private let usersDefaults = UserDefaults.standard
	private let encoder = JSONEncoder()
	private let decoder = JSONDecoder()
	
	private var total: Int {
		get {
			usersDefaults.integer(forKey: UserDefaultsKeys.total.rawValue)
		} set {
			usersDefaults.set(newValue, forKey: UserDefaultsKeys.total.rawValue)
		}
	}
	
	private var correct: Int {
		get {
			usersDefaults.integer(forKey: UserDefaultsKeys.correct.rawValue)
		} set {
			usersDefaults.set(newValue, forKey: UserDefaultsKeys.correct.rawValue)
		}
	}
	
	private var totalAccuracy: Double {
		(Double(correct)/Double(total))*100
	}
	
	private var gamesCount: Int {
		get {
			usersDefaults.integer(forKey: UserDefaultsKeys.gameCount.rawValue)
		} set {
			usersDefaults.set(newValue, forKey: UserDefaultsKeys.gameCount.rawValue)
		}
	}
	
	private var bestGame: GameRecord {
		get {
			guard let data = usersDefaults.data(forKey: UserDefaultsKeys.bestGame.rawValue),
				  let record = try? decoder.decode(GameRecord.self, from: data)
			else {
				return .init(correct: 0, total: 0, date: .now)
			}
			return record
		} set {
			guard let data = try? encoder.encode(newValue) else {
				print("Невозможно сохранить результат - \(newValue)")
				return
			}
			usersDefaults.set(data, forKey: UserDefaultsKeys.bestGame.rawValue)
		}
	}
	
//MARK: - Initialiser
	private init() { }
}

//MARK: - StatisticServiceProtocol Implementation
extension StatisticService: StatisticServiceProtocol {
	
	func store(correct count: Int, total amount: Int) {
		gamesCount += 1
		correct += count
		total += amount
		let current = GameRecord(correct: count, total: amount, date: .now)
		if current.isBetterThan(bestGame) {
			bestGame = current
		}
	}
	
	func getStatisticMessage() -> String {
		let totalGames = "Количество сыгранных квизов: \(gamesCount)\n"
		let bestResult = "Рекод: \(bestGame.correct)/\(bestGame.total) (\(bestGame.date.dateTimeString))\n"
		let averageAccuracy = "Средняя точность: \(String(format: "%.2f", totalAccuracy))%"
		return totalGames + bestResult + averageAccuracy
	}
	
}
