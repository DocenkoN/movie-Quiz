import UIKit

final class QuestionFactory: QuestionFactoryProtocol {
    private let moviesLoader: MoviesLoading
    private var movies: [MostPopularMovie] = []
    private var currentIndex = 0
    
    var delegate: QuestionFactoryDelegate?
    
    init(moviesLoader: MoviesLoading, delegate: QuestionFactoryDelegate?) {
        self.moviesLoader = moviesLoader
        self.delegate = delegate
    }
    
    func loadData() {
        moviesLoader.loadMovies { [weak self] result in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                switch result {
                case .success(let mostPopularMovies):
                    self.movies = mostPopularMovies.items
                    self.delegate?.didLoadDataFromServer()
                case .failure(let error):
                    self.delegate?.didFailToLoadData(with: error)
                }
            }
        }
    }
    
    func requestNextQuestion() {
        DispatchQueue.global().async { [weak self] in
            guard let self = self else { return }
            guard !self.movies.isEmpty else {
                DispatchQueue.main.async {
                    self.delegate?.didReceiveNextQuestion(question: nil)
                }
                return
            }
            
            let index = (0..<self.movies.count).randomElement() ?? 0
            let movie = self.movies[index]
            
            let imageData: Data
            do {
                imageData = try Data(contentsOf: movie.resizedImageURL)
            } catch {
                print("Failed to load image")
                DispatchQueue.main.async {
                    self.delegate?.didReceiveNextQuestion(question: nil)
                }
                return
            }
            
            let rating = Float(movie.rating) ?? 0
            let text = "Рейтинг этого фильма больше чем 7?"
            let correctAnswer = rating > 7
            
            let question = QuizQuestion(
                image: imageData,
                text: text,
                correctAnswer: correctAnswer
            )
            
            DispatchQueue.main.async {
                self.delegate?.didReceiveNextQuestion(question: question)
            }
        }
    }
}
