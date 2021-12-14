import SpriteKit
import GameplayKit

class GameScene: SKScene {
    
    private var background: SKSpriteNode!
    private var player: SKSpriteNode!
    private var floor: SKSpriteNode!
    private let doubleTapGesture = UITapGestureRecognizer()
    
    override func didMove(to view: SKView) {
        
        createBackground()
        createPlayer()
        
        
        doubleTapGesture.addTarget(self, action: #selector(playerJump))
        doubleTapGesture.numberOfTapsRequired = 2
        self.view?.addGestureRecognizer(doubleTapGesture)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            let touchLocation = touch.location(in: self)
            let movePoint = CGPoint(x: touchLocation.x, y: player.position.y)
            if touchLocation.x < player.position.x {
                player.texture = SKTexture(imageNamed: "mirroredPlayer")
            } else {
                player.texture = SKTexture(imageNamed: "player")
            }
            let playerMoveAction = SKAction.move(to: movePoint, duration: 2)
            player.run(playerMoveAction, withKey: "playerMoveAction")
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if player.hasActions() {
            player.removeAction(forKey: "playerMoveAction")
        }
    }
    
    @objc func playerJump() {
        let moveTo = player.position.y + 100
        let jumpAction =  SKAction.moveTo(y: moveTo, duration: 1)
        player.run(jumpAction)
    }
    
    //  MARK: создавал невидимый пол, на который приземлялись после прыжка под гравитацией, но галимо работало
    
    
//    private func createFloor() {
//        let floorWidth = self.frame.width
//        floor = SKSpriteNode(texture: nil, size: CGSize(width: floorWidth, height: 1))
//        let y = player.position.y - player.size.height - 1
//        floor.position = CGPoint(x: 0, y: y)
//        floor.zPosition = 1
//        floor.physicsBody = SKPhysicsBody(rectangleOf: floor.size)
//        floor.physicsBody?.affectedByGravity = false
//        floor.physicsBody?.isDynamic = false
//        floor.physicsBody?.pinned = false
//        floor.physicsBody?.allowsRotation = false
//        addChild(floor)
//    }
    
    
    private func createPlayer() {
        player = SKSpriteNode(imageNamed: "player")
        player.position = CGPoint(x: 0, y: 100)
        player.zPosition = 10
        let playerHeight = self.frame.height / 2.5
        player.size = CGSize(width: playerHeight, height: playerHeight)
        
        // MARK: свойства физического тела для персонажа
        
        player.physicsBody = SKPhysicsBody(texture: player.texture!, size: player.size)
        player.physicsBody?.affectedByGravity = true
        player.physicsBody?.allowsRotation = false
        player.physicsBody?.pinned = false
        player.physicsBody?.isDynamic = true
        
        addChild(player)
    }
    
    private func createBackground() {
        // Небо
        background = SKSpriteNode(imageNamed: "background")
        background.size = self.size
        addChild(background)
        
        
        
        // Земля
        floor = SKSpriteNode(imageNamed: "floor")
        floor.size = CGSize(width: self.frame.width, height: self.frame.height / 3.5)
        let y = -(self.frame.height / 2) + (floor.size.height / 2)
        floor.position = CGPoint(x: 0, y: y)
        floor.zPosition = 5
        
        floor.physicsBody = SKPhysicsBody(texture: floor.texture!, size: floor.size)
        floor.physicsBody?.isDynamic = false
        floor.physicsBody?.pinned = false
        floor.physicsBody?.allowsRotation = false
        floor.physicsBody?.affectedByGravity = false
        
        addChild(floor)
    }
}
