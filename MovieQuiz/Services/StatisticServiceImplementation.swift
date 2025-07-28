import Foundation

final class StatisticServiceImplementation: StatisticServiceProtocol {
    private enum Keys: String {
        case correct, total, date, gamesCount, totalCorrect, totalQuestions
    }
    
    private let storage = UserDefaults.standard
    
    init() {
        if storage.object(forKey: Keys.totalCorrect.rawValue) == nil {
            storage.set(0, forKey: Keys.totalCorrect.rawValue)
            storage.set(0, forKey: Keys.totalQuestions.rawValue)
            storage.set(0, forKey: Keys.gamesCount.rawValue)
        }
    }
    
    var gamesCount: Int {
        get { storage.integer(forKey: Keys.gamesCount.rawValue) }
        set { storage.set(newValue, forKey: Keys.gamesCount.rawValue) }
    }
    
    var bestGame: GameResult {
        get {
            let correct = storage.integer(forKey: Keys.correct.rawValue)
            let total = storage.integer(forKey: Keys.total.rawValue)
            let date = storage.object(forKey: Keys.date.rawValue) as? Date ?? Date()
            return GameResult(correct: correct, total: total, date: date)
        }
        set {
            storage.set(newValue.correct, forKey: Keys.correct.rawValue)
            storage.set(newValue.total, forKey: Keys.total.rawValue)
            storage.set(newValue.date, forKey: Keys.date.rawValue)
        }
    }
    
    var totalAccuracy: Double {
        let totalCorrect = storage.integer(forKey: Keys.totalCorrect.rawValue)
        let totalQuestions = storage.integer(forKey: Keys.totalQuestions.rawValue)
        guard totalQuestions > 0 else { return 0 }
        return Double(totalCorrect) / Double(totalQuestions) * 100
    }
    
    func store(correct count: Int, total amount: Int) {
        gamesCount += 1
        
        let newCorrect = storage.integer(forKey: Keys.totalCorrect.rawValue) + count
        let newTotal = storage.integer(forKey: Keys.totalQuestions.rawValue) + amount
        
        storage.set(newCorrect, forKey: Keys.totalCorrect.rawValue)
        storage.set(newTotal, forKey: Keys.totalQuestions.rawValue)
        
        let newGame = GameResult(correct: count, total: amount, date: Date())
        if newGame.isBetterThan(bestGame) {
            bestGame = newGame
        }
    }
}
