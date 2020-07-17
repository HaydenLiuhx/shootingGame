//
//  Duck.swift
//  ShootingGallery
//
//  Created by 刘皇逊 on 16/3/20.
//  Copyright © 2020 hayden. All rights reserved.
//

import Foundation
import SpriteKit

class Duck: SKNode {
    var hasTarget: Bool!
    
    init(hasTarget: Bool = false) {
        super.init()
        self.hasTarget = hasTarget
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implement!")
    }
}
