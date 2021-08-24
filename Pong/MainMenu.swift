//
//  MainMenu.swift
//  Pong
//
//  Created by Miroslav Mali on 19.7.21..
//

import Foundation
import SpriteKit
import AVFoundation


class MainMenu: SKScene {
    
    let gameScene = GameScene.self // ACCESS TO OTHER SCENES
    
    let startGame = SKLabelNode(fontNamed: "8-bit-pusab")
    
    let paddle = SKSpriteNode(imageNamed: "paddle")
    let paddleAI = SKSpriteNode(imageNamed: "paddle")
    
    let ball = SKSpriteNode(imageNamed: "ball")
    var ball_speed_x: CGFloat = 8
    var ball_speed_y: CGFloat = 8
    
    var audioPlayer: AVAudioPlayer?
    
    //let mainMenuMusic = SKAction.playSoundFileNamed("main_menu_music.mp3", waitForCompletion: false)
    
    override func didMove(to view: SKView) {
        
        playBackgroundMusic()
         
        let background = SKSpriteNode(imageNamed: "grey_bg")
        background.size = self.size
        background.position = CGPoint(x: self.size.width / 2, y: self.size.height / 2)
        background.zPosition = 0
        background.name = "Background"
        addChild(background)
        
        let gameBy = SKLabelNode(fontNamed: "8-bit-pusab")
        gameBy.text = ""
        gameBy.fontSize = 50
        gameBy.fontColor = SKColor.white
        gameBy.position = CGPoint(x: self.size.width * 0.5, y: self.size.height * 0.78)
        gameBy.zPosition = 1
        addChild(gameBy)
        
        let gameName1 = SKLabelNode(fontNamed: "8-bit-pusab")
        gameName1.text = "The Pong Project"
        gameName1.fontSize = 80
        gameName1.fontColor = SKColor.white
        gameName1.position = CGPoint(x: self.size.width * 0.5, y: self.size.height * 0.65)
        gameName1.zPosition = 1
        addChild(gameName1)
        
        startGame.text = "Start Game"
        startGame.fontSize = 80
        startGame.fontColor = SKColor.white
        startGame.position = CGPoint(x: self.size.width * 0.5, y: self.size.height * 0.4)
        startGame.zPosition = 1
        startGame.name = "startButton"
        addChild(startGame)
        
        paddle.position = CGPoint(x: self.size.width - paddle.size.height, y: self.size.height / 2)
        paddle.zPosition = 2
        paddle.alpha = 0.15
        addChild(paddle)
        
        paddleAI.position = CGPoint(x: 0 + paddle.size.height, y: self.size.height / 2)
        paddleAI.zPosition = 2
        paddleAI.alpha = 0.15
        addChild(paddleAI)
        
        ball.position = CGPoint(x: self.size.width / 2, y: self.size.height / 2)
        ball.setScale(0.5)
        ball.zPosition = 2
        ball.alpha = 0.15
        addChild(ball)
    }
    
    
    func moveToScene() {
        
        let sceneToMoveTo = GameScene(size: self.size)
        sceneToMoveTo.scaleMode = self.scaleMode
        let myTransition = SKTransition.fade(withDuration: 1)
        view!.presentScene(sceneToMoveTo, transition: myTransition)
    }
    
    
    override func update(_ currentTime: TimeInterval) {
        
        moveBall()
        movePaddles()
        wallBounce()
    }
    
    func moveBall() {
        
        ball.position.y += ball_speed_y
        ball.position.x += ball_speed_x
        
        if ball.position.x >= self.size.width - paddle.size.height - 65 {
            ball_speed_x *= -1
        }
        else if ball.position.x <= 65 + paddle.size.height {
            ball_speed_x *= -1
        }
    }
    
    func movePaddles() {
        
        paddle.position.y = ball.position.y
        paddleAI.position.y = ball.position.y
    }
    
    func wallBounce() {
        // Change y direction of ball after top and bottom wall contact
        
        if ball.position.y >= self.size.height - 100 {
            ball_speed_y *= -1
        }
        else if ball.position.y <= 100 {
            ball_speed_y *= -1
        }
    }
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        for touch: AnyObject in touches {
            
            let touchPosition = touch.location(in: self)
            for nodeITapped in nodes(at: touchPosition) {
                
                if nodeITapped.name == "startButton" {
                    
                    let scaleUp = SKAction.scale(to: 1.2, duration: 0.15)
                    let scaleDown = SKAction.scale(to: 1, duration: 0.15)
                    let scaleSequence = SKAction.sequence([scaleUp, scaleDown])
                    startGame.run(scaleSequence, completion: moveToScene)
                }
            }
        }
    }
    
    
    func playBackgroundMusic() {
        
        let aSound = NSURL(fileURLWithPath: Bundle.main.path(forResource: "main_menu_music", ofType: "mp3")!)
                do {
                    audioPlayer = try AVAudioPlayer(contentsOf:aSound as URL)
                    audioPlayer!.numberOfLoops = -1
                    audioPlayer!.prepareToPlay()
                    audioPlayer!.play()
                } catch {
                    print("Cannot play the file")
                }
        
    }
}
