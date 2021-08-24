//
//  GameScene.swift
//  Pong
//
//  Created by Miroslav Mali on 4.7.21..
//

import SpriteKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    let paddle = SKSpriteNode(imageNamed: "paddle")
    let paddleAI = SKSpriteNode(imageNamed: "paddle")
    let ball = SKSpriteNode(imageNamed: "ball")
    
    let playerScoreLabel = SKLabelNode(fontNamed: "8-bit-pusab")
    var playerScoreNumber = 0
    
    let enemyScoreLabel = SKLabelNode(fontNamed: "8-bit-pusab")
    var enemyScoreNumber = 0
    
    var ball_speed_x: CGFloat = 10
    var ball_speed_y: CGFloat = 10
    let randomXandYDirection = [CGFloat(-10), CGFloat(10)]
    
    var gameDifficulty: Double = 0.2
    
    let paddleContactSounds = ["blip.wav", "blip2.wav", "blip3.wav", "blip4.wav"]
    
    let gameArea: CGRect
    
    enum gameState {
        case preGame
        case inGame
        case afterGame
    }
    
    var currentGameState = gameState.preGame
    
    struct PhysicsCategories {
        static let None: UInt32 = 0
        static let Paddle: UInt32 = 0b1
        static let PaddleAI: UInt32 = 0b10
        static let Ball: UInt32 = 0b100
    }
    
    override init(size: CGSize) {
        
        let maxAspectRatio: CGFloat = 19.5/9.0
        let playableWidth = size.width / maxAspectRatio
        let margin = (size.width - playableWidth) / 2
        gameArea = CGRect(x: margin, y: 0, width: playableWidth, height: size.height)
        
        super.init(size: size)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func didMove(to view: SKView) {
        
        physicsWorld.contactDelegate = self
        
        // Background setup
        let background = SKSpriteNode(imageNamed: "grey_bg")
        background.size = self.size
        background.position = CGPoint(x: self.size.width / 2, y: self.size.height / 2)
        background.zPosition = 0
        background.name = "Background"
        addChild(background)
        
        // Line
        let line = SKShapeNode()
        line.path = UIBezierPath(roundedRect: CGRect(x: 0, y: -500, width: 1, height: self.size.height), cornerRadius: 0).cgPath
        line.position = CGPoint(x: self.size.width / 2, y: self.size.height / 2)
        line.fillColor = .white
        line.lineWidth = 5
        line.zPosition = 3
        addChild(line)
        
        // Scores
        playerScoreLabel.text = "0"
        playerScoreLabel.fontSize = 70
        playerScoreLabel.fontColor = SKColor.white
        playerScoreLabel.position = CGPoint(x: (self.size.width / 2) + 80, y: size.height - 110)
        playerScoreLabel.zPosition = 5
        addChild(playerScoreLabel)
        
        enemyScoreLabel.text = "0"
        enemyScoreLabel.fontSize = 70
        enemyScoreLabel.fontColor = SKColor.white
        enemyScoreLabel.position = CGPoint(x: (self.size.width / 2) - 85, y: size.height - 110)
        enemyScoreLabel.zPosition = 5
        addChild(enemyScoreLabel)
        
        // Player paddle setup
        paddle.position = CGPoint(x: self.size.width - paddle.size.height, y: self.size.height / 2)
        paddle.zPosition = 2
        paddle.physicsBody = SKPhysicsBody(rectangleOf: paddle.size)
        paddle.physicsBody!.affectedByGravity = false
        paddle.physicsBody!.categoryBitMask = PhysicsCategories.Paddle
        paddle.physicsBody!.collisionBitMask = PhysicsCategories.None
        paddle.physicsBody!.contactTestBitMask = PhysicsCategories.Ball
        self.addChild(paddle)
        
        // AI/Enemy paddle setup
        paddleAI.position = CGPoint(x: 0 + paddle.size.height, y: self.size.height / 2)
        paddleAI.zPosition = 2
        paddleAI.physicsBody = SKPhysicsBody(rectangleOf: paddleAI.size)
        paddleAI.physicsBody!.affectedByGravity = false
        paddleAI.physicsBody!.categoryBitMask = PhysicsCategories.PaddleAI
        paddleAI.physicsBody!.collisionBitMask = PhysicsCategories.None
        paddleAI.physicsBody!.contactTestBitMask = PhysicsCategories.Ball
        self.addChild(paddleAI)
        
        // Ball setup
        ball.position = CGPoint(x: self.size.width / 2, y: self.size.height / 2)
        ball.setScale(0.5)
        ball.zPosition = 2
        ball.physicsBody = SKPhysicsBody(rectangleOf: ball.size)
        ball.physicsBody!.affectedByGravity = false
        ball.physicsBody!.categoryBitMask = PhysicsCategories.Ball
        ball.physicsBody!.collisionBitMask = PhysicsCategories.None
        ball.physicsBody!.contactTestBitMask = PhysicsCategories.Paddle | PhysicsCategories.PaddleAI
        self.addChild(ball)
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        // Runs when player touches and moves fingers across the screen
        
        for touch: AnyObject in touches {
            
            let pointOfTouch = touch.location(in: self)
            
            // Move the ball to finger position and limit the paddle movement inside of the screen
            if pointOfTouch.y > 1000 {
                paddle.run(SKAction.moveTo(y: pointOfTouch.y - 100, duration: 0.1))
            }
            else if pointOfTouch.y < 100 {
                paddle.run(SKAction.moveTo(y: pointOfTouch.y + 100, duration: 0.1))
            }
            else {
                paddle.run(SKAction.moveTo(y: pointOfTouch.y, duration: 0.1))
            }
        }
    }
    
    override func update(_ currentTime: TimeInterval) {
        // Runs on every frame
        
        moveBall()
        moveAIPaddle()
        wallBounce()
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        // Runs when two bodies make contact/collide
        
        var body1 = SKPhysicsBody()
        var body2 = SKPhysicsBody()
        
        if contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask {
            body1 = contact.bodyA
            body2 = contact.bodyB
        }
        else {
            body1 = contact.bodyB
            body2 = contact.bodyA
        }
        
        // Accelerate the ball and change it's x direction after paddle contact
        if body1.categoryBitMask == PhysicsCategories.Paddle && body2.categoryBitMask == PhysicsCategories.Ball {
            run(SKAction.playSoundFileNamed(paddleContactSounds.randomElement()!, waitForCompletion: false))
            ball_speed_x *= -1.05
            ball_speed_y *= 1.02
        }
        if body1.categoryBitMask == PhysicsCategories.PaddleAI && body2.categoryBitMask == PhysicsCategories.Ball {
            run(SKAction.playSoundFileNamed(paddleContactSounds.randomElement()!, waitForCompletion: false))
            ball_speed_x *= -1.1
            ball_speed_y *= 1.05
        }
    }
    
    func moveBall() {
        
        ball.position.y += ball_speed_y
        ball.position.x += ball_speed_x
        
        if ball.position.x >= size.width + ball.size.width {
            run(SKAction.playSoundFileNamed("death.wav", waitForCompletion: false))
            enemyScoreUp()
            
        }
        
        else if ball.position.x <= 0 - ball.size.width {
            run(SKAction.playSoundFileNamed("win.wav", waitForCompletion: false))
            playerScoreUp()
        }
    }
    
    func moveAIPaddle() {
        
        if ball.position.y > 1170 {
            paddleAI.run(SKAction.moveTo(y: ball.position.y - 120, duration: gameDifficulty))
        }
        else if ball.position.y < 50 {
            paddleAI.run(SKAction.moveTo(y: ball.position.y + 100, duration: gameDifficulty))
        }
        else {
            paddleAI.run(SKAction.moveTo(y: ball.position.y, duration: gameDifficulty))
        }
    }
    
    func wallBounce() {
        // Change y direction of ball after top and bottom wall contact
        
        if ball.position.y > gameArea.maxY - 50 {
            ball_speed_y *= -1
        }
        else if ball.position.y < gameArea.minY + 80 {
            ball_speed_y *= -1
        }
    }
    
    func enemyScoreUp() {
        
        enemyScoreNumber += 1
        enemyScoreLabel.text = "\(enemyScoreNumber)"
        
        ball.removeFromParent()
        ball.position.x = size.width / 2
        ball.position.y = size.height / 2
        ball_speed_x = randomXandYDirection.randomElement()!
        ball_speed_y = randomXandYDirection.randomElement()!
        addChild(ball)
        
        let scaleUp = SKAction.scale(to: 1.35, duration: 0.2)
        let scaleDown = SKAction.scale(to: 1, duration: 0.2)
        let scaleSequence = SKAction.sequence([scaleUp, scaleDown])
        enemyScoreLabel.run(scaleSequence)
        
        if enemyScoreNumber == 3 {
            
            gameOver()
        }
    }
    
    func playerScoreUp() {
        
        playerScoreNumber += 1
        playerScoreLabel.text = "\(playerScoreNumber)"
        
        ball.removeFromParent()
        ball.position.x = size.width / 2
        ball.position.y = size.height / 2
        ball_speed_x = randomXandYDirection.randomElement()!
        ball_speed_y = randomXandYDirection.randomElement()!
        addChild(ball)
        
        let scaleUp = SKAction.scale(to: 1.35, duration: 0.2)
        let scaleDown = SKAction.scale(to: 1, duration: 0.2)
        let scaleSequence = SKAction.sequence([scaleUp, scaleDown])
        playerScoreLabel.run(scaleSequence)
        
        if playerScoreNumber == 3 {
            
            gameOver()
        }
    }
    
    
    func gameOver() {
            
        let sceneToMoveTo = GameOver(size: size)
        sceneToMoveTo.scaleMode = self.scaleMode
        let myTransition = SKTransition.fade(withDuration: 1)
        view!.presentScene(sceneToMoveTo, transition: myTransition)
    }
}
