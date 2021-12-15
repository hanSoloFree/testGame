import UIKit

class AlertViewController: UIViewController {
    
    var alertDelegate: AlertDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tapped))
        view.addGestureRecognizer(tapGesture)
    }
    
    @objc func tapped() {
        self.dismiss(animated: false) {
            self.alertDelegate?.gameStarted()
        }
    }
    
}


