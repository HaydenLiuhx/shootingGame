//
//  GameStateMachine.swift
//  ShootingGallery
//
//  Created by 刘皇逊 on 17/3/20.
//  Copyright © 2020 hayden. All rights reserved.
//

import Foundation
import GameplayKit

class GameState: GKState {
    unowned var fire: FireButton
    unowned var magazine: Magazine
    
    init(fire: FireButton, magazine: Magazine) {
        self.fire = fire
        self.magazine = magazine
        
        super.init()
    }
}
class ReadyState: GameState {
    //ReadyState之后只能是ShootingState
    override func isValidNextState(_ stateClass: AnyClass) -> Bool {
        if stateClass is ShootingState.Type && !magazine.needToReload(){
            return true
        }
        return false
    }
    //进入下一个State
    override func didEnter(from previousState: GKState?) {
        magazine.reloadIfNeeded()
        stateMachine?.enter(ShootingState.self)
    }
}

class ShootingState: GameState {
    override func isValidNextState(_ stateClass: AnyClass) -> Bool {
        if stateClass is ReloadingState.Type && magazine.needToReload() {
            return true
        }
        return false
    }
    
    override func didEnter(from previousState: GKState?) {
        fire.removeAction(forKey: ActionKey.reloading.key)
        fire.run(.animate(with: [SKTexture.init(imageNamed: Texture.fireButtonNormal.imageName)], timePerFrame: 0.1),
                 withKey: ActionKey.reloading.key)
    }
}

class ReloadingState: GameState {
    //添装时间
    let reloadingTime:Double = 0.25
    override func isValidNextState(_ stateClass: AnyClass) -> Bool {
        if stateClass is ShootingState.Type && !magazine.needToReload() {
            return true
        }
        return false
    }
    
    let reloadingTexture = SKTexture(imageNamed: Texture.fireButtonReloading.imageName)
    lazy var fireButtonReloadingAction = {
        SKAction.sequence([
            SKAction.animate(with: [reloadingTexture], timePerFrame: 0.1),
            SKAction.rotate(byAngle: 360, duration: 30)])
    }()
    let bulletTexture = SKTexture(imageNamed: Texture.bulletTexture.imageName)
    lazy var bulletReloadingAction = {
        SKAction.animate(with: [bulletTexture], timePerFrame: 0.1)
    }()
    
    override func didEnter(from previousState: GKState?) {
        fire.isReloading = true
        fire.removeAction(forKey: ActionKey.reloading.key)
        fire.run(fireButtonReloadingAction, withKey: ActionKey.reloading.key)
        
        for (i , bullet) in magazine.bullets.reversed().enumerated() {
            
            var action = [SKAction]()
            
            let waitAction = SKAction.wait(forDuration: TimeInterval(reloadingTime * Double(i)))
            action.append(waitAction)
            action.append(bulletReloadingAction)
            //把子弹为空转换过来
            action.append(SKAction.run{
                bullet.reloaded()
            })
            if i == magazine.capacity - 1 {
                action.append(SKAction.run { [unowned self] in
                    self.fire.isReloading = false
                    self.stateMachine?.enter(ShootingState.self)
                })
            }
            bullet.run(.sequence(action))
        }
    }
    
}
