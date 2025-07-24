import UIKit

final class MovieQuizViewController: UIViewController, QuestionFactoryDelegate {
    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet private weak var textLabel: UILabel!
    @IBOutlet private weak var counterLabel: UILabel!
    
    @IBOutlet private weak var activityIndicator: UIActivityIndicatorView!
    
    private var currentQuestionIndex = 0
    private var correctAnswers = 0
    private let questionsAmount = 10
    
    private var questionFactory: QuestionFactoryProtocol?
    private var currentQuestion: QuizQuestion?
    
    private var alertPresenter: AlertPresenter!
   
    private var isButtonEnabled = true
    
    private var statisticService: StatisticServiceProtocol = StatisticServiceImplementation()
    private let resultAlertPresenter = ResultAlertPresenter()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        activityIndicator.hidesWhenStopped = true
        
        
        imageView.layer.cornerRadius = 20
        alertPresenter = AlertPresenter(view: self)
        
        questionFactory = QuestionFactory(moviesLoader: MoviesLoader(), delegate: self)
        
        showLoadingIndicator()
        questionFactory?.loadData()
    }
    
    @IBAction private func yesButtonClicked(_ sender: UIButton) {
        guard isButtonEnabled, let question = currentQuestion else { return }
        showAnswerResult(isCorrect: question.correctAnswer == true)
    }
    
    @IBAction private func noButtonClicked(_ sender: UIButton) {
        guard isButtonEnabled, let question = currentQuestion else { return }
        showAnswerResult(isCorrect: question.correctAnswer == false)
    }
    
    func didReceiveNextQuestion(question: QuizQuestion?) {
        guard let question = question else { return }
        
        currentQuestion = question
        let viewModel = QuizStepViewModel(
            image: UIImage(data: question.image) ?? UIImage(),
            question: question.text,
            questionNumber: "\(currentQuestionIndex + 1)/\(questionsAmount)"
        )
        show(quiz: viewModel)
        
    }
    
    private func show(quiz step: QuizStepViewModel) {
        isButtonEnabled = true
        imageView.isHidden = false
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
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            self?.showNextQuestionOrResults()
        }
        
    }
    
    private func showNextQuestionOrResults() {
        isButtonEnabled = false
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
                self.questionFactory = QuestionFactory(moviesLoader: MoviesLoader(), delegate: self)
                self.showLoadingIndicator()
                self.questionFactory?.loadData()
                
            }
            
            alertPresenter.show(model: model)
        } else {
            currentQuestionIndex += 1
            questionFactory?.requestNextQuestion()
        }
    }
    
    private func showLoadingIndicator() {
        isButtonEnabled = false
        activityIndicator.startAnimating()
        
        imageView.backgroundColor = .clear
    }
    
    private func hideLoadingIndicator() {
        activityIndicator.stopAnimating()
    }
    
    private func showNetworkError(message: String) {
        hideLoadingIndicator()
        
        let model = AlertModel(title: "Что-то пошло не так(",
                               message: message,
                               buttonText: "Попробовать еще раз") { [weak self] in
            guard let self = self else { return }
            
            self.isButtonEnabled = false
            self.questionFactory?.loadData()
            
        }
        
        alertPresenter.show(model: model)
    }
    
    private func convert(model: QuizQuestion) -> QuizStepViewModel {
        return QuizStepViewModel(
            image: UIImage(data: model.image) ?? UIImage(),
            question: model.text,
            questionNumber: "\(currentQuestionIndex + 1)/\(questionsAmount)")
    }
    
    func didLoadDataFromServer() {
        activityIndicator.stopAnimating()
        questionFactory?.requestNextQuestion()
    }
    
    func didFailToLoadData(with error: Error) {
        showNetworkError(message: error.localizedDescription)
    }
    
    func didFailToLoadQuestion(with error: Error) {
        showNetworkError(message: error.localizedDescription)
    }
}

extension MovieQuizViewController: AlertPresenterProtocol {
    func present(alert: UIAlertController, animated: Bool) {
        present(alert, animated: animated)
    }
}
