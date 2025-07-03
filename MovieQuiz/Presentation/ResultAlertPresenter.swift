import Foundation

final class ResultAlertPresenter {
    func makeAlertModel(correctAnswers: Int, totalQuestions: Int, statisticService: StatisticServiceProtocol, completion: @escaping () -> Void) -> AlertModel {
        statisticService.store(correct: correctAnswers, total: totalQuestions)

        let date = statisticService.bestGame.date
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd.MM.yyyy HH:mm"

        let message = """
        Ваш результат: \(correctAnswers)/\(totalQuestions)
        Кол-во сыгранных квизов: \(statisticService.gamesCount)
        Рекорд: \(statisticService.bestGame.correct)/\(statisticService.bestGame.total) (\(dateFormatter.string(from: date)))
        Средняя точность: \(String(format: "%.2f", statisticService.totalAccuracy))%
        """

        return AlertModel(title: "Раунд завершён", message: message, buttonText: "Сыграть ещё раз", completion: completion)
    }
}

