//
//  GameOver.swift
//  Pong
//
//  Created by Miroslav Mali on 20.7.21..
//

import Foundation
import SpriteKit


class GameOver: SKScene {
    
    let playAgain = SKLabelNode(fontNamed: "8-bit-pusab")
    
    override func didMove(to view: SKView) {
        
        let background = SKSpriteNode(imageNamed: "grey_bg")
        background.size = self.size
        background.position = CGPoint(x: self.size.width / 2, y: self.size.height / 2)
        background.zPosition = 0
        background.name = "Background"
        addChild(background)
        
        let gameOver = SKLabelNode(fontNamed: "8-bit-pusab")
        gameOver.text = "Game Over"
        gameOver.fontSize = 100
        gameOver.fontColor = SKColor.white
        gameOver.position = CGPoint(x: self.size.width * 0.5, y: self.size.height * 0.65)
        gameOver.zPosition = 1
        gameOver.name = "gameOverButton"
        addChild(gameOver)
        
        playAgain.text = "Play Again"
        playAgain.fontSize = 80
        playAgain.fontColor = SKColor.white
        playAgain.position = CGPoint(x: self.size.width * 0.5, y: self.size.height * 0.45)
        playAgain.zPosition = 1
        playAgain.name = "playAgainButton"
        addChild(playAgain)
    }
    
    func moveToMainMenu() {
        
        let sceneToMoveTo = MainMenu(size: size)
        sceneToMoveTo.scaleMode = self.scaleMode
        let myTransition = SKTransition.fade(withDuration: 1)
        view!.presentScene(sceneToMoveTo, transition: myTransition)
    }
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        for touch: AnyObject in touches {
            
            let touchLocation = touch.location(in: self)
            for nodeIPressed in nodes(at: touchLocation) {
                
                if nodeIPressed.name == "playAgainButton" {
                    
                    let scaleUp = SKAction.scale(to: 1.2, duration: 0.15)
                    let scaleDown = SKAction.scale(to: 1, duration: 0.15)
                    let scaleSequence = SKAction.sequence([scaleUp, scaleDown])
                    playAgain.run(scaleSequence, completion: moveToMainMenu)
                }
            }
        }
    }
}
