//
//  GameViewController.swift
//  ShootingGallery
//
//  Created by 刘皇逊 on 16/3/20.
//  Copyright © 2020 hayden. All rights reserved.
//

import UIKit
import SpriteKit
import GameplayKit

class GameViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let view = self.view as! SKView? {
            // Load the SKScene from 'GameScene.sks'
            if let scene = SKScene(fileNamed: "StageScene") {
                // Set the scale mode to scale to fit the window
                scene.scaleMode = .aspectFit
                //.aspectfill会填充所有物件
                
                // Present the scene
                view.presentScene(scene)
            }
            
            view.ignoresSiblingOrder = false//true渲染顺序会乱
            
            view.showsFPS = true
            view.showsNodeCount = true
        }
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
