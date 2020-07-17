//
//  magazine.swift
//  ShootingGallery
//
//  Created by 刘皇逊 on 16/3/20.
//  Copyright © 2020 hayden. All rights reserved.
//

import Foundation
import SpriteKit

class Magazine {
    var bullets: [Bullet]!
    var capacity: Int!
    
    init(bullets:[Bullet]){
        self.bullets = bullets
        self.capacity = bullets.count
    }
    
    func shoot() {
        bullets.first {(bullet) -> Bool in
            bullet.wasShot() == false
            }?.shoot()
    }
    func needToReload() -> Bool {
        return bullets.allSatisfy{$0.wasShot() == true}
        }
    func reloadIfNeeded() {
        if needToReload(){
            for bullet in bullets {
                bullet.reloadIfNeeded()
            }
        }
    }
    }

