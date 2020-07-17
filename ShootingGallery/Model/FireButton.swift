//
//  FireButton.swift
//  ShootingGallery
//
//  Created by 刘皇逊 on 16/3/20.
//  Copyright © 2020 hayden. All rights reserved.
//

import Foundation
import SpriteKit

class FireButton: SKSpriteNode {
    var isReloading = false
    
    var isPressed = false {
        didSet {
            guard !isReloading else { return }
            if isPressed {
                texture = SKTexture(imageNamed: Texture.fireButtonPressed.imageName)
            } else {
                texture = SKTexture(imageNamed: Texture.fireButtonNormal.imageName)
            }
        }
    }
    init() {
        let texture = SKTexture(imageNamed: Texture.fireButtonNormal.imageName)
        super.init(texture: texture, color: .clear, size: texture.size())
        
        name = "fire"
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
