import SpriteKit
import GameplayKit

class GameScene: SKScene, SKPhysicsContactDelegate, AlertDelegate {
    
    var gameOverDelegate: GameOverDelegate?
        
    private var healthNodes = [SKSpriteNode]()
    private var heroHealth = 3
    
    private var coinsCollected = 0 {
        didSet {
            coinsCount.text = String(describing: coinsCollected)
        }
    }
    private var coinsCount: SKLabelNode!
    
    private var background: SKSpriteNode!
    private var player: SKSpriteNode!
    private var monster: SKSpriteNode!
    private var floor: SKSpriteNode!
    private let doubleTapGesture = UITapGestureRecognizer()
    
    private var isInTheAir: Bool = false
    private var isForced: Bool = false
    private var coinGenerated: Bool = false
    private var gameIsStarted: Bool = false
    
    private let playerCategory: UInt32 = 0x1 << 0
    private let groundCategory: UInt32 = 0x1 << 1
    private let monsterCategory: UInt32 = 0x1 << 2
    private let coinCategory: UInt32 = 0x1 << 3
    
    override func didMove(to view: SKView) {
        
        physicsWorld.contactDelegate = self
        physicsWorld.gravity.dy = -8
        
        createBackground()
        createPlayer()
        createHealthPoints()
        createCoinsCount()
        
        
        doubleTapGesture.addTarget(self, action: #selector(playerJump))
        doubleTapGesture.numberOfTapsRequired = 2
        self.view?.addGestureRecognizer(doubleTapGesture)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        if let touch = touches.first {
            let touchLocation = touch.location(in: self)
            if touchLocation.x < player.position.x {
                player.texture = SKTexture(imageNamed: "mirroredPlayer")
            } else {
                player.texture = SKTexture(imageNamed: "player")
            }
            
            let distance = distanceCalculation(a: player.position, b: touchLocation)
            let speed: CGFloat = 200.0
            let time = TimeInterval(distance / speed)
            
            let playerMoveAction = SKAction.moveTo(x: touchLocation.x, duration: time)
            
            player.run(playerMoveAction, withKey: "playerMoveAction")
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
        if gameIsStarted {
            if !coinGenerated {
                self.coinGenerated = true
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 7) {
                    self.createCoin()
                    self.coinGenerated = false
                }
            }
        }
        if player.position.y < floor.position.y {
            isPaused = true
            gameOverDelegate?.coinsCount = self.coinsCollected
            gameOverDelegate?.pushGameOverViewController()
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
                if !isPaused {
                    gameOverDelegate?.coinsCount = self.coinsCollected
                    gameOverDelegate?.pushGameOverViewController()
                    isPaused = true
                }
            }
            
            
            if monster.hasActions() {
                monster.removeAction(forKey: "repeatAction")
                player.run(repeatColorAction)
                let lostHp = healthNodes.removeLast()
                lostHp.isHidden = true
            }
            
            if !isForced {
                isForced = true
                if monster.position.x < player.position.x {
                    let impulse = CGVector(dx: 15, dy: 15)
                    player.physicsBody?.applyImpulse(impulse)
                }
                if monster.position.x > player.position.x {
                    let impulse = CGVector(dx: -15, dy: 15)
                    player.physicsBody?.applyImpulse(impulse)
                }
            }
        }
        
        if (bodyACategory == playerCategory && bodyBCategory == coinCategory) || (bodyACategory == coinCategory && bodyBCategory == playerCategory) {
            if bodyACategory == coinCategory {
                if contact.bodyA.node != nil {
                    contact.bodyA.node?.removeFromParent()
                    coinsCollected += 1
                }
            }
            if bodyBCategory == coinCategory {
                if contact.bodyB.node != nil {
                    contact.bodyB.node?.removeFromParent()
                    coinsCollected += 1
                }
            }
        }
    }
    
    
    @objc func playerJump() {
        if !isInTheAir {
            let jumpImpulse = CGVector(dx: 0, dy: 30)
            player.physicsBody?.applyImpulse(jumpImpulse)
            isInTheAir = true
        }
    }
    func gameStarted() {
        if monster == nil {
            createMonster()
            gameIsStarted = true
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
        player.zPosition = 15
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
        
        if monster.position.x < 0 {
            let moveRightSequence = SKAction.sequence([moveRightTexture,moveRightAction, moveLeftTexture, moveLeftAction])
            let repeatAction = SKAction.repeatForever(moveRightSequence)
            monster.run(repeatAction, withKey: "repeatAction")
        }
        if monster.position.x >= 0 {
            let moveLeftSequence = SKAction.sequence([moveLeftTexture,moveLeftAction, moveRightTexture, moveRightAction])
            let repeatAction = SKAction.repeatForever(moveLeftSequence)
            monster.run(repeatAction, withKey: "repeatAction")
        }
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
    private func addMusic() {
        let musicAction = SKAction.playSoundFileNamed("music", waitForCompletion: false)
        run(musicAction)
    }
    
    
    
// MARK: -  COIN CREATION 
    private func createCoin() {
        let coin = SKSpriteNode(imageNamed: "coin")
        coin.size = CGSize(width: 50, height: 50)
        let randomX = CGFloat.random(in: -(self.frame.width / 2 + 60)...(self.frame.width / 2 - 60) )
        let coinY = monster.position.y - (monster.size.height / 2) + (coin.size.height / 2)
        coin.position = CGPoint(x: randomX, y: coinY)
        coin.zPosition = 10
        
        coin.physicsBody = SKPhysicsBody(texture: coin.texture!, size: coin.size)

        coin.physicsBody?.isDynamic = false
        coin.physicsBody?.pinned = false
        coin.physicsBody?.allowsRotation = false
        coin.physicsBody?.affectedByGravity = false
        
        coin.physicsBody?.categoryBitMask = coinCategory
        coin.physicsBody?.contactTestBitMask = playerCategory
        
        
        addChild(coin)
    }
    
    private func createCoinsCount() {
        let coin = SKSpriteNode(imageNamed: "coin")
        coin.size = CGSize(width: 30, height: 30)
        let coinY = (self.frame.height / 2) - (coin.size.height)
        let coinX = (self.frame.width / 2) - coin.size.width * 1.5
        coin.position = CGPoint(x: coinX, y: coinY)
        coin.zPosition = 15
        addChild(coin)
        
        
        coinsCount = SKLabelNode(text: String(describing: coinsCollected))
        coinsCount.fontName = "Arial Rounded MT Bold"
        let coinsCountX = (self.frame.width / 2) - coin.size.width * 2.8
        let coinsCountY = coinY - (coin.size.height / 2.3)
        coinsCount.position = CGPoint(x: coinsCountX, y: coinsCountY)
        coinsCount.zPosition = 15
        addChild(coinsCount)
        
    }
}


