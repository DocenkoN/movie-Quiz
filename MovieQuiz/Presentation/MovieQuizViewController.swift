import UIKit

final class MovieQuizViewController: UIViewController {
    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet private weak var textLabel: UILabel!
    @IBOutlet private weak var counterLabel: UILabel!
    @IBOutlet private weak var activityIndicator: UIActivityIndicatorView!
    
    private var presenter: MovieQuizPresenter!
    private var alertPresenter: AlertPresenter!
    private let resultAlertPresenter = ResultAlertPresenter()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        activityIndicator.hidesWhenStopped = true
        imageView.layer.cornerRadius = 20
        
        alertPresenter = AlertPresenter(view: self)
        presenter = MovieQuizPresenter(viewController: self)
    }
    
    @IBAction private func yesButtonClicked(_ sender: UIButton) {
        presenter.yesButtonClicked()
    }
    
    @IBAction private func noButtonClicked(_ sender: UIButton) {
        presenter.noButtonClicked()
    }
    
    func show(quiz step: QuizStepViewModel) {
        imageView.isHidden = false
        imageView.image = step.image
        textLabel.text = step.question
        counterLabel.text = step.questionNumber
        imageView.layer.borderWidth = 0
    }
    
    func show(quiz result: QuizResultsViewModel) {
        let alert = UIAlertController(
            title: result.title,
            message: result.text,
            preferredStyle: .alert
        )
        
        let action = UIAlertAction(title: result.buttonText, style: .default) { [weak self] _ in
            self?.presenter.restartGame()
        }
        
        alert.addAction(action)
        present(alert, animated: true)
    }
    
    func highlightImageBorder(isCorrectAnswer: Bool) {
        imageView.layer.masksToBounds = true
        imageView.layer.borderWidth = 8
        imageView.layer.borderColor = (UIColor(named: isCorrectAnswer ? "YP Green (iOS)" : "YP Red (iOS)") ?? UIColor.gray).cgColor
    }
    
    func showLoadingIndicator() {
        activityIndicator.startAnimating()
        imageView.backgroundColor = .clear
    }
    
    func hideLoadingIndicator() {
        activityIndicator.stopAnimating()
    }
    
    func showNetworkError(message: String) {
        hideLoadingIndicator()
        
        let model = AlertModel(
            title: "Что-то пошло не так(",
            message: message,
            buttonText: "Попробовать ещё раз"
        ) { [weak self] in
            self?.presenter.restartGame()
        }
        
        alertPresenter.show(model: model)
    }
}

extension MovieQuizViewController: AlertPresenterProtocol {
    func present(alert: UIAlertController, animated: Bool) {
        present(alert, animated: animated)
    }
}
    
    extension MovieQuizViewController: MovieQuizViewControllerProtocol {
        
    }

    

