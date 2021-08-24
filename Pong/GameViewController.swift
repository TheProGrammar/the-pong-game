//
//  GameViewController.swift
//  Pong
//
//  Created by Miroslav Mali on 4.7.21..
//

import UIKit
import SpriteKit
import GameplayKit

class GameViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let scene = MainMenu(size: CGSize(width: 2340, height: 1080))
        let view = self.view as! SKView
        view.showsFPS = true
        view.showsNodeCount = true
        view.ignoresSiblingOrder = true
        scene.scaleMode = .aspectFill
        
        view.presentScene(scene)
    }

    override var shouldAutorotate: Bool {
        return true
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return .allButUpsideDown
        } else {
            return .all
        }
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }
}
