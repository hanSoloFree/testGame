import UIKit

class GameOverViewController: UIViewController {
    
    @IBOutlet weak var backgroundImageView: UIImageView!
    @IBOutlet weak var tryAgainButton: UIButton!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.isHidden = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let image = UIImage(named: "gameOver")
        backgroundImageView.image = image
        tryAgainButton.layer.cornerRadius = 15
    }
    
    @IBAction func tryAgainButttonPressed(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: false)
    }
}
