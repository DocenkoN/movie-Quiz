

import UIKit

final class AlertPresenter {
    weak var viewController: UIViewController?
    
    func show(model: AlertModel) {
        let alert = UIAlertController(
            title: model.title,
            message: model.message,
            preferredStyle: .alert
        )
        
        let action = UIAlertAction(title: model.buttonText, style: .default) { _ in
            model.completion()}
        
        alert.addAction(action)
        viewController?.present(alert, animated: true)
    }
}

