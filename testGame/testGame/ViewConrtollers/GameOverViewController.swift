import UIKit

class GameOverViewController: UIViewController {
    
    var coinsCount: Int = 0
    var musicStatus: Bool = UserDefaults.standard.bool(forKey: "musicStatus"){
        didSet {
            if musicStatus {
                soundImageView.image = UIImage(named: "soundOn")
            } else {
                soundImageView.image = UIImage(named: "soundOff")
            }
        }
    }
    
    @IBOutlet weak var backgroundImageView: UIImageView!
    @IBOutlet weak var tryAgainButton: UIButton!
    @IBOutlet weak var gameOverLabel: UIImageView!
    @IBOutlet weak var coinsCollectedLabel: UILabel!
    @IBOutlet weak var coinImageView: UIImageView!
    @IBOutlet weak var coinsCollectedLabelBackground: UIView!
    @IBOutlet weak var soundImageView: UIImageView!
    
    

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.isHidden = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tapped))
        tapGesture.numberOfTapsRequired = 1
        soundImageView.addGestureRecognizer(tapGesture)
        
        let background = UIImage(named: "gameOver")
        let label = UIImage(named: "gameOverLabel")
        let coin = UIImage(named: "coin")
        
        backgroundImageView.image = background
        gameOverLabel.image = label
        coinImageView.image = coin
        
        if musicStatus {
            soundImageView.image = UIImage(named: "soundOn")
        } else {
            soundImageView.image = UIImage(named: "soundOff")
        }
        coinsCollectedLabelBackground.layer.cornerRadius = 15
        tryAgainButton.layer.cornerRadius = 15
        
        if coinsCount == 0 {
            coinsCollectedLabel.text = "You collected: \(coinsCount) coins :(\nGood luck next try!"
        } else if coinsCount == 1 {
            coinsCollectedLabel.text = "Congratulations!\nYou collected: \(coinsCount) coin!"
        } else {
            coinsCollectedLabel.text = "Congratulations!\nYou collected: \(coinsCount) coins!"
        }
    }
    
    @objc func tapped() {
        musicStatus = !musicStatus
        UserDefaults.standard.set(musicStatus, forKey: "musicStatus")
        if musicStatus {
            playSound()
        } else {
            player?.stop()
        }
            
    }
    
    @IBAction func tryAgainButttonPressed(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: false)
    }
}
