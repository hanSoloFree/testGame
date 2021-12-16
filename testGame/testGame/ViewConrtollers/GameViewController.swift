import UIKit
import SpriteKit
import GameplayKit

class GameViewController: UIViewController, GameOverDelegate {
    
    var coinsCount = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if let view = self.view as! SKView? {
            guard let scene = GameScene(fileNamed: "GameScene") else { return }
            scene.scaleMode = .resizeFill
            scene.gameOverDelegate = self
            let alert = AlertService().alert()
            alert.alertDelegate = scene
            self.present(alert, animated: false, completion: nil)
            view.presentScene(scene)
        }
    }
    
    override var shouldAutorotate: Bool {
        return false
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .landscape
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    func pushGameOverViewController() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let gameOverViewController = storyboard.instantiateViewController(withIdentifier: "GameOverViewController") as? GameOverViewController else { return }
        gameOverViewController.coinsCount = self.coinsCount
        self.navigationController?.pushViewController(gameOverViewController, animated: false)
    }
}
