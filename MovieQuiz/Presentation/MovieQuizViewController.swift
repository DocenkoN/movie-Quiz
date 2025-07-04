import UIKit

final class MovieQuizViewController: UIViewController, QuestionFactoryDelegate {
    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet private weak var textLabel: UILabel!
    @IBOutlet private weak var counterLabel: UILabel!

    private var currentQuestionIndex = 0
    private var correctAnswers = 0
    private let questionsAmount = 10

    private var questionFactory: QuestionFactoryProtocol?
    private var currentQuestion: QuizQuestion?

    private var alertPresenter: AlertPresenter!
    private let statisticService: StatisticServiceProtocol = StatisticServiceImplementation()
    private let resultAlertPresenter = ResultAlertPresenter()

    override func viewDidLoad() {
        super.viewDidLoad()
        alertPresenter = AlertPresenter(view: self)
        questionFactory = QuestionFactory(delegate: self)
        questionFactory?.requestNextQuestion()
    }

    @IBAction private func yesButtonClicked(_ sender: UIButton) {
        guard let question = currentQuestion else { return }
        showAnswerResult(isCorrect: question.correctAnswer == true)
    }

    @IBAction private func noButtonClicked(_ sender: UIButton) {
        guard let question = currentQuestion else { return }
        showAnswerResult(isCorrect: question.correctAnswer == false)
    }

    func didReceiveNextQuestion(question: QuizQuestion?) {
        guard let question = question else { return }

        currentQuestion = question
        let viewModel = QuizStepViewModel(
            image: UIImage(named: question.image) ?? UIImage(),
            question: question.text,
            questionNumber: "\(currentQuestionIndex + 1)/\(questionsAmount)"
        )
        show(quiz: viewModel)
    }

    private func show(quiz step: QuizStepViewModel) {
        imageView.image = step.image
        textLabel.text = step.question
        counterLabel.text = step.questionNumber
        imageView.layer.borderWidth = 0
    }

    private func showAnswerResult(isCorrect: Bool) {
        if isCorrect { correctAnswers += 1 }

        imageView.layer.masksToBounds = true
        imageView.layer.borderWidth = 8
        imageView.layer.borderColor = (UIColor(named: isCorrect ? "YP Green (iOS)" : "YP Red (iOS)") ?? .gray).cgColor

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.showNextQuestionOrResults()
        }
    }

    private func showNextQuestionOrResults() {
        imageView.layer.borderWidth = 0

        if currentQuestionIndex == questionsAmount - 1 {
            let model = resultAlertPresenter.makeAlertModel(
                correctAnswers: correctAnswers,
                totalQuestions: questionsAmount,
                statisticService: statisticService
            ) { [weak self] in
                guard let self = self else { return }
                
                self.currentQuestionIndex = 0
                self.correctAnswers = 0
                self.questionFactory = QuestionFactory(delegate: self)
                self.questionFactory?.requestNextQuestion()
            }

            alertPresenter.show(model: model)
        } else {
            currentQuestionIndex += 1
            questionFactory?.requestNextQuestion()
        }
    }
}

extension MovieQuizViewController: AlertPresenterProtocol {
    func present(alert: UIAlertController, animated: Bool) {
        present(alert, animated: animated)
    }
}
