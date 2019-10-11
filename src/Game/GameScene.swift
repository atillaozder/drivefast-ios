//
//  GameScene.swift
//  Retro Car Racing
//
//  Created by Atilla Özder on 10.10.2019.
//  Copyright © 2019 Atilla Özder. All rights reserved.
//

import SpriteKit
import GameplayKit
import CoreMotion

let fontName = "AmericanTypewriter-semibold"
var gameCount: Double = 0

protocol SceneDelegate: class {
    func scene(_ scene: GameScene, didFinishGameWithScore score: Int)
    func scene(_ scene: GameScene, shouldPresentRewardBasedVideoAd present: Bool)
}

class GameScene: SKScene {
    
    weak var sceneDelegate: SceneDelegate?
    lazy var rewardBasedVideoAdPresented: Bool = false
    lazy var safeAreaInsets: UIEdgeInsets = .zero
    
    var player: SKSpriteNode!
    var road: SKShapeNode!
    var roadLine: SKShapeNode!
    var roadCar: SKSpriteNode!
    
    var roadLineSize: CGSize {
        return .init(width: 10, height: 40)
    }

    var scoreLabel: SKLabelNode!
    var score: Int = 0 {
        didSet {
            if scoreLabel != nil {
                scoreLabel.text = "Score: \(score)"
            }
        }
    }
    
    var livesArray: [SKSpriteNode] = []
    
    var possibleCars: [String] = [
        "taxi",
        "ambulance",
        "truck",
        "mini_truck",
        "mini_van",
        "police",
        "old_car",
        "audi"
    ]
    
    let carCategory: UInt32 = 0x1 << 1
    let playerCategory: UInt32 = 0x1 << 0
    
    let motionManager = CMMotionManager()
    var xAcceleration: CGFloat = 0
    
    var animationDuration: TimeInterval = 6
    
    var roadLineDuration: TimeInterval = 1 {
        didSet {
            setRoadLineSequence()
        }
    }
    
    var carDuration: TimeInterval = 3 {
        didSet {
            setCarSequence()
        }
    }
    
    override func didMove(to view: SKView) {
        gameCount += 1
        player = SKSpriteNode(imageNamed: "black_viper")
        addPlayer()
        
        road = SKShapeNode(rectOf: .init(width: (player.size.width * 2) - 20, height: frame.size.height * 2))
        road.fillColor = SKColor(red: 105/255, green: 105/255, blue: 105/255, alpha: 1)
        road.strokeColor = .darkGray
        road.position = .init(x: frame.midX, y: frame.minY)
        road.zPosition = -1
        self.addChild(road)
        
        roadLine = SKShapeNode(rectOf: roadLineSize)
        roadLine.position = .init(x: frame.midX, y: frame.maxY + roadLineSize.height)
        roadLine.zPosition = -1
        roadLine.fillColor = .white
        
        let texture = SKTexture(imageNamed: possibleCars[0])
        roadCar = SKSpriteNode(texture: texture)
        roadCar.position = CGPoint(x: 0, y: frame.size.height + roadCar.size.height)
        roadCar.zPosition = 1
        roadCar.name = "road_car"
        
        self.backgroundColor = .dark
        self.physicsWorld.gravity = CGVector(dx: 0, dy: 0)
        self.physicsWorld.contactDelegate = self
        
        self.addGameScore()
        self.addLives()
        
        self.setCarSequence()
        self.setRoadLineSequence()
        
        let _ = Timer.scheduledTimer(timeInterval: 30, target: self, selector: #selector(speedUpGame), userInfo: nil, repeats: true)
        
        motionManager.accelerometerUpdateInterval = 0.2
        motionManager.startAccelerometerUpdates(to: OperationQueue.current!) { [weak self] (data, error) in
            guard let `self` = self else { return }
            if let aData = data {
                self.xAcceleration = CGFloat(aData.acceleration.x) * 0.75 + self.xAcceleration * 0.25
            }
        }
    }
    
    func addPlayer() {
        let playerPosY = player.size.height / 2 + 20 + safeAreaInsets.bottom
        player.position = CGPoint(x: self.frame.size.width / 2, y: playerPosY)
        player.zPosition = 1
        player.name = "player"
        
        player.physicsBody = SKPhysicsBody(
            texture: player.texture!,
            size: player.texture!.size())
        
        player.physicsBody?.isDynamic = true
        player.physicsBody?.categoryBitMask = playerCategory
        player.physicsBody?.contactTestBitMask = carCategory
        player.physicsBody?.collisionBitMask = 0
        player.physicsBody?.usesPreciseCollisionDetection = true
        
        self.addChild(player)
    }
    
    func addGameScore() {
        scoreLabel = SKLabelNode(text: "Score: 0")
        scoreLabel.position = CGPoint(x: 70, y: frame.size.height - 40 - safeAreaInsets.top)
        scoreLabel.fontName = fontName
        scoreLabel.fontSize = 28
        scoreLabel.fontColor = UIColor.white
        scoreLabel.zPosition = -1
        score = 0
        self.addChild(scoreLabel)
    }
    
    @objc
    func speedUpGame() {
        if animationDuration != 2 {
            let newValue = animationDuration - 0.5
            animationDuration = max(newValue, 2)
        }
        
        if carDuration != 0.5 {
            let newValue = carDuration - 0.5
            carDuration = max(newValue, 0.5)
        }
        
        if roadLineDuration != 0.5 {
            let newValue = roadLineDuration - 0.1
            roadLineDuration = max(newValue, 0.5)
        }
    }
    
    func setCarSequence() {
        let key = "add_car_key"
        removeAction(forKey: key)
        let seq = SKAction.sequence([
            .wait(forDuration: carDuration),
            .run(addRandomCar)
        ])
        run(.repeatForever(seq), withKey: key)
    }
    
    func setRoadLineSequence() {
        let key = "add_road_line"
        removeAction(forKey: key)
        let seq = SKAction.sequence([
            .wait(forDuration: roadLineDuration),
            .run(addRoadLine)
        ])
        run(.repeatForever(seq), withKey: key)
    }
    
    func addRoadLine() {
        if let copy = roadLine.copy() as? SKShapeNode {
            addChild(copy)
            var actions = [SKAction]()
            actions.append(.moveTo(
                y: -roadLineSize.height,
                duration: roadLineDuration * 5))
            actions.append(.removeFromParent())
            copy.run(.sequence(actions))
        }
    }
    
    func addRandomCar() {
        if let copy = roadCar.copy() as? SKSpriteNode {
            possibleCars = GKRandomSource.sharedRandom()
                .arrayByShufflingObjects(in: possibleCars) as! [String]
            
            let texture = SKTexture(imageNamed: possibleCars[0])
            copy.texture = texture

            let roadMinX = frame.midX - (player.size.width) + (texture.size().width / 2)
            let roadMaxX = frame.midX + (player.size.width) - (texture.size().width / 2)
                    
            let randomDist = GKRandomDistribution(lowestValue: Int(roadMinX), highestValue: Int(roadMaxX))
            copy.position.x = CGFloat(randomDist.nextInt())
            //            copy.position.x = Int.random(in: 0...1) == 0 ? roadMinX : roadMaxX

            let body = SKPhysicsBody(texture: texture, size: texture.size())
            body.isDynamic = true
            body.categoryBitMask = carCategory
            body.contactTestBitMask = playerCategory
            body.collisionBitMask = 0
            
            copy.physicsBody = body
            
            self.addChild(copy)
            
            var actions = [SKAction]()
            actions.append(.moveTo(
                y: -copy.size.height,
                duration: animationDuration))
            actions.append(.removeFromParent())
            
            let increaseScore = SKAction.run {
                self.score += 1
            }
            
            actions.append(increaseScore)
            copy.run(.sequence(actions))
        }
    }
    
    func playerDidCollide(with car: SKSpriteNode) {
        car.removeFromParent()
        
        if let live = livesArray.last {
            live.removeFromParent()
            livesArray.removeLast()
        }
        
        if livesArray.isEmpty {
            let explosion = SKEmitterNode(fileNamed: "Explosion")!
            explosion.position = player.position
            self.addChild(explosion)

            self.run(.playSoundFileNamed("explosion.wav", waitForCompletion: false))
            player.removeFromParent()
            car.removeFromParent()

            self.run(.wait(forDuration: 2)) {
                explosion.removeFromParent()
                self.sceneDelegate?.scene(self, didFinishGameWithScore: self.score)
            }
        }
    }
    
    func addLives() {
        let size = CGSize(width: 40, height: 50)
        var posX = frame.maxX - 6 - (size.width / 2)
        let posY = frame.maxY - 30 - safeAreaInsets.top
        for _ in 0..<3 {
            let texture = SKTexture(imageNamed: "black_viper")
            let node = SKSpriteNode(texture: texture)
            node.size = size
            node.position = CGPoint(x: posX, y: posY)
            node.aspectFill(to: size)
            
            let physicsBody = SKPhysicsBody(texture: texture, size: size)
            physicsBody.collisionBitMask = 0
            node.physicsBody = physicsBody
            
            livesArray.append(node)
            addChild(node)
            
            posX -= ((size.width / 2) + 6)
        }
    }
}

extension GameScene: SKPhysicsContactDelegate {
    func didBegin(_ contact: SKPhysicsContact) {
        var fBody: SKPhysicsBody
        var sBody: SKPhysicsBody
        
        if contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask {
            fBody = contact.bodyA
            sBody = contact.bodyB
        } else {
            fBody = contact.bodyB
            sBody = contact.bodyA
        }
        
        if (fBody.categoryBitMask & playerCategory) != 0 && (sBody.categoryBitMask & carCategory) != 0 {
            if let car = sBody.node as? SKSpriteNode {
                playerDidCollide(with: car)
            }
        }
    }
}

extension SKSpriteNode {
    func aspectFill(to size: CGSize) {
        if texture != nil {
            self.size = texture!.size()
            let vRatio = size.height / self.texture!.size().height
            let hRatio = size.width /  self.texture!.size().width
            let ratio = hRatio > vRatio ? hRatio : vRatio
            self.setScale(ratio)
        }
    }
}

extension UIColor {
    class var dark: UIColor {
        return .init(red: 18/255, green: 18/255, blue: 18/255, alpha: 1)
    }
}
