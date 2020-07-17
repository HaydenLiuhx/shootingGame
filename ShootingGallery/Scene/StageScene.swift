//
//  StageScene.swift
//  ShootingGallery
//
//  Created by 刘皇逊 on 16/3/20.
//  Copyright © 2020 hayden. All rights reserved.
//

import Foundation
import SpriteKit
import GameplayKit

class StageScene: SKScene {
    //刚被加载时触发这个方法
    // Nodes
    var rifle: SKSpriteNode?
    var crossHair: SKSpriteNode?
    var fire = FireButton()
    
    var duckScoreNode: SKNode!
    var targetScoreNode:SKNode!
    
    var magazine: Magazine!
    //Touches
    var selectedNodes: [UITouch : SKSpriteNode] = [:]
    var duckMoveDuration: TimeInterval!
    // Score
    var totalScore = 0
    let targetScore = 10
    let duckScore = 10
    // Count
    var duckCount = 0
    var targetCount = 0
    
    let targetXPosition: [Int] = [160,240,320,400,480,560,640]
    var usingTargetXPosition = Array<Int>()
    //var gameStateMachine: GKStateMachine!
    let amountQuantity = 5
    var zPositionDecimal = 0.001 {
        didSet{
            if zPositionDecimal == 1{
                zPositionDecimal = 0.001
            }
        }
    }
    var gameStateMachine: GKStateMachine!
    var touchDifferent: (CGFloat,CGFloat)?
    override func didMove(to view: SKView) {
//        let node = generateDuck(hasTarget: false)
//        node.position = CGPoint(x: 240, y: 100)
//        node.zPosition = 6
//        addChild(node)
        loadUI()
        
        gameStateMachine = GKStateMachine(states: [ReadyState(fire: fire, magazine: magazine),
        ShootingState(fire: fire, magazine: magazine),
        ReloadingState(fire: fire, magazine: magazine)])
        
        gameStateMachine.enter(ReadyState.self)
        
        activeDuck()
        activeTarget()
    }
}
// MARK: - GameLoop
extension StageScene {
    override func update(_ currentTime: TimeInterval) {
        syncRiflePosition()
        setBoundary()
    }
}

// MARK: - Touches
extension StageScene {
    //Touches Began
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let crossHair = crossHair else { return }
        //guard let touch = touches.first else { return }
        //便利每一个touch
        for touch in touches {
            let location = touch.location(in: self)
            if let node = self.atPoint(location) as? SKSpriteNode {
                if !selectedNodes.values.contains(crossHair) && !(node is FireButton){
                    selectedNodes[touch] = crossHair
                    let xDifference = touch.location(in: self).x - crossHair.position.x
                    let yDifference = touch.location(in: self).y - crossHair.position.y
                    touchDifferent = (xDifference,yDifference)
                }
                //Actual shooting
                if node is FireButton {
                    selectedNodes[touch] = fire
                    
                    // Check if is reloading
                    if !fire.isReloading {
                        fire.isPressed = true
                        magazine.shoot()
                        
                        if magazine.needToReload(){
                            gameStateMachine.enter(ReloadingState.self)
                        }
                        // Find Shot node
                        let shootNode = findShootNode(at: crossHair.position)
                        guard let (scoreText, shotImageName) = findTextAndImageName(for: shootNode.name) else { return }
                        // Add shot image
                        addShot(imageNamed: "shot_blue", to: shootNode, on: crossHair.position)
                        // Add score text
                        addTextNode(on: crossHair.position, from: scoreText)
                        // Update score node   inout要加符号
                        update(text: String(duckCount * duckScore), node: &duckScoreNode)
                        update(text: String(targetCount * targetScore), node: &targetScoreNode)
                        // Animate shoot node
                        shootNode.physicsBody = nil
                                       
                        if let node = shootNode.parent {
                        node.run(.sequence([
                                .wait(forDuration: 0.2),
                                .scale(to: 0.0, duration: 0.2)]))
                    }
                    
                }
               
                }
            }
        }
        
    }
    
    //Touches Moved
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let crossHair = crossHair else { return }
        //guard let touch = touches.first else { return }
        guard let touchDifferent = touchDifferent else { return }
        for touch in touches {
            let location = touch.location(in: self)
            if let node = selectedNodes[touch] {
                if node.name == "fire" {
                } else {
                    let newCrossHairPosition = CGPoint(x: location.x - touchDifferent.0, y: location.y - touchDifferent.1)
                    crossHair.position = newCrossHairPosition
                }
            }
        }
        //let location = touch.location(in: self)
        
    }
    
    //Touches Ended
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            if selectedNodes[touch] != nil {
                if let fire = selectedNodes[touch] as? FireButton {
                    fire.isPressed = false
                }
                selectedNodes[touch] = nil
            }
        }
    }
}

// MARK: - Action
extension StageScene {
    func loadUI()  {
        //rifle and crossHair
        if let scene = scene {
        rifle = childNode(withName: "rifle") as? SKSpriteNode
        crossHair = childNode(withName: "crosshair") as? SKSpriteNode
        crossHair?.position = CGPoint(x: scene.frame.midX, y: scene.frame.midY)
        }
        //Add firebutton
        fire.position = CGPoint(x: 720, y: 80)
        fire.xScale = 1.7
        fire.yScale = 1.7
        fire.zPosition = 11
        
        addChild(fire)
        
        //Add Icon
        let duckIcon = SKSpriteNode(imageNamed: Texture.duckIcon.imageName)
        duckIcon.position = CGPoint(x: 36, y: 365)
        duckIcon.zPosition = 11
        addChild(duckIcon)
        
        let targetIcon = SKSpriteNode(imageNamed: Texture.targetIcon.imageName)
        targetIcon.position = CGPoint(x: 36, y: 325)
        targetIcon.zPosition = 11
        addChild(targetIcon)
        
        //Add ScoreNode
        duckScoreNode = generateTextNode(from: "0")
        duckScoreNode.position = CGPoint(x: 60, y: 365)
        duckScoreNode.zPosition = 11
        duckScoreNode.xScale = 0.5
        duckScoreNode.yScale = 0.5
        addChild(duckScoreNode)
        
        targetScoreNode = generateTextNode(from: "0")
        targetScoreNode.position = CGPoint(x: 60, y: 325)
        targetScoreNode.zPosition = 11
        targetScoreNode.xScale = 0.5
        targetScoreNode.yScale = 0.5
        addChild(targetScoreNode)
        
        //Add empty magazine
        let magazineNode = SKNode()
        magazineNode.position = CGPoint(x: 760, y: 20)
        magazineNode.zPosition = 11
        var bullets = Array<Bullet>()
        for i in 0...amountQuantity-1{
            let bullet = Bullet()
            bullet.position = CGPoint(x: -30*i, y: 0)
            bullets.append(bullet)
            magazineNode.addChild(bullet)
        }
        magazine = Magazine(bullets: bullets)
        addChild(magazineNode)
    }
    
    func generateDuck(hasTarget: Bool = false) -> Duck {
        var duck: SKSpriteNode
        var stick: SKSpriteNode
        let node = Duck(hasTarget: hasTarget)
        var duckImageName: String
        var duckNodeName: String
        var texture = SKTexture()
        if hasTarget {
            duckImageName = "duck_target/\(Int.random(in: 1...3))"
            texture = SKTexture(imageNamed: duckImageName)
            duckNodeName = "duck_target"
            //node = Duck(hasTarget: true)
        } else {
            duckImageName = "duck/\(Int.random(in: 1...3))"
            texture = SKTexture(imageNamed: duckImageName)
            duckNodeName = "duck"
            //node = Duck(hasTarget: false)
        }
        duck = SKSpriteNode(texture: texture)
        duck.name = duckNodeName
        duck.position = CGPoint(x: 0, y: 144)
        duck.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        
        //创建物理模型
        let physicsBody = SKPhysicsBody(texture: texture, alphaThreshold: 0.5, size: texture.size())
        physicsBody.affectedByGravity = false
        physicsBody.isDynamic = false
        duck.physicsBody = physicsBody
        
        stick = SKSpriteNode(imageNamed: "stick/\(Int.random(in: 1...2))")
        stick.anchorPoint = CGPoint(x: 1, y: 0.5)
        stick.position = CGPoint(x: 13.6, y: 51.2)
        
        duck.xScale = 0.8//缩放
        duck.yScale = 0.8
        stick.xScale = 0.8
        stick.yScale = 0.8
        
        node.addChild(stick)
        node.addChild(duck)
        return node
    }
    
    func generateTarget() -> Target {
        var target: SKSpriteNode
        var stick: SKSpriteNode
        let node = Target()
        let taxture = SKTexture(imageNamed: "target/\(Int.random(in: 1...3))")
        
        target = SKSpriteNode(texture: taxture)
        stick = SKSpriteNode(imageNamed: "stick_metal")
        target.xScale = 0.5
        target.yScale = 0.5
        target.position = CGPoint(x: 0, y: 95)
        target.name = "target"
        stick.xScale = 0.5
        stick.yScale = 0.5
        stick.anchorPoint = CGPoint(x: 0.5, y: 0)
        stick.position = CGPoint(x: 0, y: 0)
        node.addChild(stick)
        node.addChild(target)
        
        return node
    }
    
    func activeDuck() {
        Timer.scheduledTimer(withTimeInterval: 1, repeats: true){
            (timer) in
            let duck = self.generateDuck(hasTarget: Bool.random())
            duck.position = CGPoint(x: -10, y: Int.random(in: 60...90))
            //4，6层,鸭子分层，防止重合
            duck.zPosition = Int.random(in: 0...1) == 0 ? 4:6
            duck.zPosition += CGFloat(self.zPositionDecimal)
            self.zPositionDecimal += 0.001
            self.scene?.addChild(duck)
            if duck.hasTarget {
                self.duckMoveDuration = TimeInterval(Int.random(in: 2...4))
            } else {
                self.duckMoveDuration = TimeInterval(Int.random(in: 5...7))
            }
            //移动鸭子
            duck.run(.sequence([.moveTo(x: 850, duration: self.duckMoveDuration),.removeFromParent()]))
        }
    }
    func activeTarget() {
        Timer.scheduledTimer(withTimeInterval: 3, repeats: true) { (timer) in
            let target = self.generateTarget()
            var xPosition = self.targetXPosition.randomElement()!
            
            while self.usingTargetXPosition.contains(xPosition) {
                xPosition = self.targetXPosition.randomElement()!
            }
            self.usingTargetXPosition.append(xPosition)
            target.position = CGPoint(x: xPosition, y: Int.random(in: 120...145))
            target.zPosition = 1
            target.yScale = 0
            self.scene?.addChild(target)
            
            //算一下,添加一个Scene试一下
            let physicsBody = SKPhysicsBody(circleOfRadius: 71/2)
            physicsBody.affectedByGravity = false
            physicsBody.isDynamic = false
            physicsBody.allowsRotation = false
            
            target.run(.sequence([
                .scaleY(to: 1, duration: 0.25),
                //防止未生成就可以设计
                .run {
                    if let node = target.childNode(withName: "target"){
                        node.physicsBody = physicsBody
                    }
                    },
                .wait(forDuration: TimeInterval(Int.random(in: 3...4))),
                .removeFromParent(),
                .run{
                    self.usingTargetXPosition.remove(at: self.usingTargetXPosition.firstIndex(of: xPosition)!)
                }]))
        }
    }
    func addShot(imageNamed imageName: String, to node: SKSpriteNode, on position: CGPoint){
        let convertedPosition = self.convert(position, to: node)
        let shot = SKSpriteNode(imageNamed: imageName)
        shot.position = convertedPosition
        node.addChild(shot)
        //呆在node上一段时间
        shot.run(.sequence([
            .wait(forDuration: 2),
            .fadeAlpha(to: 0.0, duration: 0.3),
            .removeFromParent()]))
    }
    func findShootNode(at position: CGPoint) -> SKSpriteNode {
        var shootNode = SKSpriteNode()
        var biggestZPosition: CGFloat = 0.0
        
        self.physicsWorld.enumerateBodies(at: position) { (body, pointer) in
            guard let node = body.node as? SKSpriteNode else {return}
            if node.name == "duck" || node.name == "duck_target" || node.name == "target"{
                if let parentNode = node.parent {
                    if parentNode.zPosition > biggestZPosition {
                        biggestZPosition = parentNode.zPosition
                        shootNode = node
                    }
                }
            }
        }
        return shootNode
    }
    func generateTextNode(from text: String, leadingAnchorPoint: Bool = true) -> SKNode {
        let node = SKNode()
        var width: CGFloat = 0.0
        
        for character in text {
            var characterNode = SKSpriteNode()
            
            if character == "0" {
                characterNode = SKSpriteNode(imageNamed: ScoreNumber.zero.textureName)
            } else if character == "1" {
                characterNode = SKSpriteNode(imageNamed: ScoreNumber.one.textureName)
            } else if character == "2" {
                characterNode = SKSpriteNode(imageNamed: ScoreNumber.two.textureName)
            } else if character == "3" {
                characterNode = SKSpriteNode(imageNamed: ScoreNumber.three.textureName)
            } else if character == "4" {
                characterNode = SKSpriteNode(imageNamed: ScoreNumber.four.textureName)
            } else if character == "5" {
                characterNode = SKSpriteNode(imageNamed: ScoreNumber.five.textureName)
            } else if character == "6" {
                characterNode = SKSpriteNode(imageNamed: ScoreNumber.six.textureName)
            } else if character == "7" {
                characterNode = SKSpriteNode(imageNamed: ScoreNumber.seven.textureName)
            } else if character == "8" {
                characterNode = SKSpriteNode(imageNamed: ScoreNumber.eight.textureName)
            } else if character == "9" {
                characterNode = SKSpriteNode(imageNamed: ScoreNumber.nine.textureName)
            } else if character == "+" {
                characterNode = SKSpriteNode(imageNamed: ScoreNumber.plus.textureName)
            } else if character == "*" {
                characterNode = SKSpriteNode(imageNamed: ScoreNumber.multiplication.textureName)
            } else {
                continue
            }
            node.addChild(characterNode)
            characterNode.anchorPoint = CGPoint(x: 0, y: 0.5)
            characterNode.position = CGPoint(x: width, y: 0.0)
            
            width += characterNode.size.width
        }
        if leadingAnchorPoint {
            return node
            } else {
                let anotherNode = SKNode()
                anotherNode.addChild(node)
                node.position = CGPoint(x: -width/2, y: 0)
                return anotherNode
            }
    }
    func addTextNode(on position: CGPoint, from text: String) {
        let scorePosition = CGPoint(x: position.x + 10, y: position.y + 30)
        let scoreNode = generateTextNode(from: text)
        scoreNode.position = scorePosition
        scoreNode.zPosition = 9
        scoreNode.xScale = 0.5
        scoreNode.yScale = 0.5
        addChild(scoreNode)
        
        scoreNode.run(.sequence([
            .wait(forDuration: 0.5),
            .fadeOut(withDuration: 0.2),
            .removeFromParent()]))
    }
    // 得分
    func findTextAndImageName(for nodeName: String?) ->(String,String)? {
        var scoreText = ""
        var shotImageName = ""
        
        switch nodeName {
        case "duck":
            scoreText = "+\(duckScore)"
            duckCount += 1
            totalScore += duckScore
            shotImageName = Texture.shotBlue.imageName
        
        case "duck_target":
            scoreText = "+\(duckScore+targetScore)"
            duckCount += 1
            targetCount += 1
            totalScore += duckScore + targetScore
            shotImageName = Texture.shotBlue.imageName
        
        case "target":
            scoreText = "+\(targetScore)"
            targetCount += 1
            totalScore += duckScore
            shotImageName = Texture.shotBrown.imageName
        
        default:
            return nil
        }
        return (scoreText,shotImageName)
    }
    //删数字在更新
    func update(text: String, node: inout SKNode, leadingAnchorPoint: Bool = true) {
        let position = node.position
        let zPosition = node.zPosition
        let xScale = node.xScale
        let yScale = node.yScale
        
        node.removeFromParent()
        node = generateTextNode(from: text, leadingAnchorPoint: leadingAnchorPoint)
        node.position = position
        node.zPosition = zPosition
        node.xScale = xScale
        node.yScale = yScale
        
        addChild(node)
    }
    
    func syncRiflePosition() {
        guard let rifle = rifle else {return}
        guard let crossHair = crossHair else {return}
        rifle.position.x = crossHair.position.x + 100
        
        
    }
    //只能在scene里面移动
    func setBoundary() {
        guard let scene = scene else {return}
        guard let crossHair = crossHair else {return}
        
        if crossHair.position.x < scene.frame.minX {
            crossHair.position.x = scene.frame.minX
        }
        if crossHair.position.x > scene.frame.maxX {
            crossHair.position.x = scene.frame.maxX
        }
        if crossHair.position.y < scene.frame.minY {
            crossHair.position.y = scene.frame.minY
        }
        if crossHair.position.y > scene.frame.maxY {
            crossHair.position.y = scene.frame.maxY
        }
    }
}
