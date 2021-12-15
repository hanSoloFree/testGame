import SpriteKit
import GameplayKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    private var healthNodes = [SKSpriteNode]()
    private var heroHealth = 3

    private var background: SKSpriteNode!
    private var player: SKSpriteNode!
    private var monster: SKSpriteNode!
    private var floor: SKSpriteNode!
    private let doubleTapGesture = UITapGestureRecognizer()
    
    private var isInTheAir: Bool = false
    private var isForced: Bool = false
    
    private let playerCategory: UInt32 = 0x1 << 0
    private let groundCategory: UInt32 = 0x1 << 1
    private let monsterCategory: UInt32 = 0x1 << 2
    
    override func didMove(to view: SKView) {
        physicsWorld.contactDelegate = self
        physicsWorld.gravity.dy = -8

        
        createBackground()
        createPlayer()
        createHealthPoints()
        
        
        doubleTapGesture.addTarget(self, action: #selector(playerJump))
        doubleTapGesture.numberOfTapsRequired = 2
        self.view?.addGestureRecognizer(doubleTapGesture)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        if monster == nil {
            createMonster()
        }
        
        if let touch = touches.first {
            let touchLocation = touch.location(in: self)
//            if !isInTheAir  {
                if touchLocation.x < player.position.x {
                    player.texture = SKTexture(imageNamed: "mirroredPlayer")
                } else {
                    player.texture = SKTexture(imageNamed: "player")
                }
            
            let distance = distanceCalculation(a: player.position, b: touchLocation)
            let time = TimeInterval(distance / 150.0)
            
            let playerMoveAction = SKAction.moveTo(x: touchLocation.x, duration: time)
            
            player.run(playerMoveAction, withKey: "playerMoveAction")
//            }
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if player.hasActions() {
            player.removeAction(forKey: "playerMoveAction")
        }
    }
    
    override func update(_ currentTime: TimeInterval) {
        if isForced {
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1.5) {
                self.isForced = false
                self.moveMonster()
            }
        }
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        let bodyACategory = contact.bodyA.categoryBitMask
        let bodyBCategory = contact.bodyB.categoryBitMask
        
        if (bodyACategory == playerCategory && bodyBCategory == groundCategory) || (bodyACategory == groundCategory && bodyBCategory == playerCategory) {
            self.isInTheAir = false
        }
        
        if (bodyACategory == playerCategory && bodyBCategory == monsterCategory) || (bodyACategory == monsterCategory && bodyBCategory == playerCategory) {
            let redColorAciton = SKAction.colorize(with: .red,
                                                   colorBlendFactor: 1,
                                                   duration: 0.5)
            let whiteColorAction = SKAction.colorize(with: .white,
                                                     colorBlendFactor: 0,
                                                     duration: 0.5)
            let colorActionSequence  = SKAction.sequence([redColorAciton, whiteColorAction])
            let repeatColorAction =  SKAction.repeat(colorActionSequence, count: 4)
            
            if healthNodes.isEmpty {
                isPaused = true
            }

            
            if monster.hasActions() {
                monster.removeAction(forKey: "repeateAction")
                player.run(repeatColorAction)
                let lostHp = healthNodes.removeLast()
                lostHp.isHidden = true
            }
            
            if !isForced {
                isForced = true
                if monster.position.x < player.position.x {
                    let impulse = CGVector(dx: 10, dy: 10)
                    player.physicsBody?.applyImpulse(impulse)
                }
                if monster.position.x > player.position.x {
                    let impulse = CGVector(dx: -10, dy: 10)
                    player.physicsBody?.applyImpulse(impulse)
                }
            }
        }
    }

    
    @objc func playerJump() {
        if !isInTheAir {
            let jumpImpulse = CGVector(dx: 0, dy: 35)
            player.physicsBody?.applyImpulse(jumpImpulse)
            isInTheAir = true
        }
    }
    
    
    private func distanceCalculation(a: CGPoint, b: CGPoint) -> CGFloat {
        return sqrt((b.x - a.x)*(b.x - a.x))
    }
    
    private func createPlayerPhysicsBody() {
        // MARK: свойства физического тела для персонажа
        
        player.physicsBody = SKPhysicsBody(texture: player.texture!, size: player.size)
        player.physicsBody?.affectedByGravity = true
        player.physicsBody?.allowsRotation = false
        player.physicsBody?.pinned = false
        player.physicsBody?.isDynamic = true
        
        player.physicsBody?.categoryBitMask = playerCategory
        //        player.physicsBody?.collisionBitMask = groundCategory /*|   monsterCategory */
        player.physicsBody?.contactTestBitMask = groundCategory |  monsterCategory
    }
    
    private func createPlayer() {
        player = SKSpriteNode(imageNamed: "player")
        player.position = CGPoint(x: 0, y: 100)
        player.zPosition = 10
        let playerHeight = self.frame.height / 4
        player.size = CGSize(width: playerHeight, height: playerHeight)
        
        createPlayerPhysicsBody()
        
        addChild(player)
    }
    
    private func createMonster() {
        monster = SKSpriteNode(imageNamed: "monster")
        let monsterHeight = self.frame.height / 5
        monster.size = CGSize(width: monsterHeight, height: monsterHeight)
        let monsterPositionX = -(self.frame.width / 2) + monsterHeight
        let monsterPosiitonY = player.position.y - (player.size.height - monster.size.height) / 2
        monster.position = CGPoint(x: monsterPositionX, y: monsterPosiitonY)
        monster.zPosition = 10
        
        monster.physicsBody = SKPhysicsBody(texture: monster.texture!, size: monster.size)
        monster.physicsBody?.affectedByGravity = true
        monster.physicsBody?.allowsRotation  = false
        monster.physicsBody?.pinned = false
        monster.physicsBody?.isDynamic = false
        
        monster.physicsBody?.categoryBitMask = monsterCategory
        //        monster.physicsBody?.collisionBitMask = playerCategory | groundCategory
        monster.physicsBody?.contactTestBitMask = playerCategory
        
        addChild(monster)
        moveMonster()
    }
    
    
    private func moveMonster() {
        let moveTo = (self.frame.width / 2) - (monster.size.width / 2)
        
        let moveRightAction = SKAction.moveTo(x: moveTo, duration: 5)
        let moveRightTexture = SKAction.setTexture(SKTexture(imageNamed: "monster"))
        
        let moveLeftAction = SKAction.moveTo(x: -moveTo, duration: 5)
        let moveLeftTexture = SKAction.setTexture(SKTexture(imageNamed: "mirroredMonster"))
        
        let actionSequence = SKAction.sequence([moveRightTexture,moveRightAction, moveLeftTexture, moveLeftAction])
        let repeateAction = SKAction.repeatForever(actionSequence)
        monster.run(repeateAction, withKey: "repeateAction")
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
        //        floor.physicsBody?.collisionBitMask = playerCategory /*| monsterCategory */
        //        floor.physicsBody?.contactTestBitMask = playerCategory
        
        addChild(floor)
    }
    
    private func createHealthPoints() {
        var width = 30
        for _ in 1...heroHealth {
            let hp = SKSpriteNode(imageNamed: "hp")
            hp.size = CGSize(width: 30, height: 30)
            hp.zPosition = 15
            let x = -(self.frame.width / 2) + (CGFloat(width) * 1.5)
            let y = (self.frame.height / 2) - (hp.size.height)
            hp.position = CGPoint(x: x , y: y)
            width +=  Int(hp.size.width)
            healthNodes.append(hp)
            addChild(hp)
        }
    }
}
