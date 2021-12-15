import SpriteKit
import GameplayKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    private var background: SKSpriteNode!
    private var player: SKSpriteNode!
    private var floor: SKSpriteNode!
    private let doubleTapGesture = UITapGestureRecognizer()
    
    private var isInTheAir: Bool = false
    
    private let playerCategory: UInt32 = 0x1 << 0
    private let groundCategory: UInt32 = 0x1 << 1
    
    override func didMove(to view: SKView) {
        physicsWorld.contactDelegate = self
        
        createBackground()
        createPlayer()
        
        doubleTapGesture.addTarget(self, action: #selector(playerJump))
        doubleTapGesture.numberOfTapsRequired = 2
        self.view?.addGestureRecognizer(doubleTapGesture)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        if let touch = touches.first {
            let touchLocation = touch.location(in: self)
            if !isInTheAir  {
                let movePoint = CGPoint(x: touchLocation.x, y: player.position.y)
                if touchLocation.x < player.position.x {
                    player.texture = SKTexture(imageNamed: "mirroredPlayer")
                } else {
                    player.texture = SKTexture(imageNamed: "player")
                }
                let distance = distanceCalculation(a: player.position, b: touchLocation)
                let time = TimeInterval(distance / 300.0)
                let playerMoveAction = SKAction.move(to: movePoint, duration: time)
                player.run(playerMoveAction, withKey: "playerMoveAction")
            }
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if player.hasActions() {
            player.removeAction(forKey: "playerMoveAction")
        }
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        let collision = contact.bodyA.collisionBitMask | contact.bodyB.collisionBitMask
        if collision == playerCategory | groundCategory {
            isInTheAir = false
        }
    }
    
//    override func update(_ currentTime: TimeInterval) {
//        isInTheAir = checkIfIsInTheAir()
//    }
    
    @objc func playerJump() {
        if !isInTheAir {
            let jumpImpulse = CGVector(dx: 0, dy: 80)
            player.physicsBody?.applyImpulse(jumpImpulse)
            isInTheAir = true
        }
    }
    
    
    
//    func checkIfIsInTheAir() -> Bool {
//        let groundTopPosition = sqrt(floor.position.y * floor.position.y)
//        let playerFootPosiion = sqrt(player.position.y * player.position.y) + groundTopPosition
//        let difference = playerFootPosiion - player.size.height
//
//
//        if difference > 1 {
//            return true
//        } else  {
//            return false
//        }
//    }

    
    private func distanceCalculation(a: CGPoint, b: CGPoint) -> CGFloat {
        return sqrt((b.x - a.x)*(b.x - a.x))
    }
    
    
    private func createPlayer() {
        player = SKSpriteNode(imageNamed: "player")
        player.position = CGPoint(x: 0, y: 250)
        player.zPosition = 10
        let playerHeight = self.frame.height / 2.5
        player.size = CGSize(width: playerHeight, height: playerHeight)
        
        // MARK: свойства физического тела для персонажа
        
        player.physicsBody = SKPhysicsBody(texture: player.texture!, size: player.size)
        player.physicsBody?.affectedByGravity = true
        player.physicsBody?.allowsRotation = false
        player.physicsBody?.pinned = false
        player.physicsBody?.isDynamic = true
        
        player.physicsBody?.categoryBitMask = playerCategory
        player.physicsBody?.collisionBitMask = groundCategory
        player.physicsBody?.contactTestBitMask = groundCategory

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
        
        floor.physicsBody?.categoryBitMask = groundCategory
        floor.physicsBody?.collisionBitMask = playerCategory
        floor.physicsBody?.contactTestBitMask = playerCategory
        
        addChild(floor)
    }
}
