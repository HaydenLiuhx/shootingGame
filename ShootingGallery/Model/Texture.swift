//
//  Texture.swift
//  ShootingGallery
//
//  Created by 刘皇逊 on 16/3/20.
//  Copyright © 2020 hayden. All rights reserved.
//

import Foundation
import SpriteKit

enum Texture: String {
    case fireButtonNormal = "fire_normal"
    case fireButtonPressed = "fire_pressed"
    case fireButtonReloading = "fire_reloading"
    case bulletEmptyTexture = "icon_bullet_empty"
    case bulletTexture = "icon_bullet"
    case shotBlue = "shot_blue"
    case shotBrown = "shot_brown"
    case duckIcon = "icon_duck"
    case targetIcon = "icon_target"
    
    var imageName: String {
        return rawValue
    }
}
