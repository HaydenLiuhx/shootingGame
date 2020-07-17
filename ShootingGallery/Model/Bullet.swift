//
//  Bullet.swift
//  ShootingGallery
//
//  Created by 刘皇逊 on 16/3/20.
//  Copyright © 2020 hayden. All rights reserved.
//

import Foundation
import SpriteKit

class Bullet: SKSpriteNode {
    private var isEmpty = true
    init() {
        let texture = SKTexture(imageNamed: Texture.bulletEmptyTexture.imageName)
        super.init(texture: texture, color: .clear, size: texture.size())
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:)has not been implemented")
    }
    func reloaded() {
        isEmpty = false
    }
    func shoot() {
        isEmpty = true
        texture = SKTexture(imageNamed: Texture.bulletEmptyTexture.imageName)
    }
    func wasShot() -> Bool {
        return isEmpty
    }
    func reloadIfNeeded() {
        if isEmpty {
            texture = SKTexture(imageNamed: Texture.bulletTexture.imageName)
            isEmpty = false
        }
    }
}
