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

enum Key: String {
    case addCar = "add_car"
    case addRoadLine = "add_road_line"
    case score = "score"
    case bestScore = "best_score"
}

enum Category: UInt32 {
    case carCategory = 0x10
    case playerCategory = 0x1
}

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
    
    var scoreRatioLabel: SKLabelNode!
    var scoreRatio: Int = 3 {
        didSet {
            scoreRatioLabel.text = "x\(scoreRatio)"
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
        
    let motionManager = CMMotionManager()
    lazy var destX: CGFloat = frame.midX
    
    var animationDuration: TimeInterval = 6
    
    var addRoadLineDuration: TimeInterval = 1 {
        didSet {
            let actions: [SKAction] = [
                .wait(forDuration: addRoadLineDuration),
                .run(addRoadLine)
            ]
            
            removeAction(forKey: Key.addRoadLine.rawValue)
            run(.repeatForever(.sequence(actions)), withKey: Key.addRoadLine.rawValue)
        }
    }
    
    var addCarDuration: TimeInterval = 3 {
        didSet {
            let actions: [SKAction] = [
                .wait(forDuration: addCarDuration),
                .run(addRandomCar)
            ]
            
            removeAction(forKey: Key.addCar.rawValue)
            run(.repeatForever(.sequence(actions)), withKey: Key.addCar.rawValue)
        }
    }
    
    override func didMove(to view: SKView) {
        player = SKSpriteNode(imageNamed: "black_viper")
        addPlayer()
        
        let roadSize: CGSize = .init(width: (player.size.width * 2) - 20, height: frame.size.height * 2)
        road = SKShapeNode(rectOf: roadSize)
        road.fillColor = SKColor(red: 105/255, green: 105/255, blue: 105/255, alpha: 1)
        road.strokeColor = .darkGray
        road.position = .init(x: frame.midX, y: frame.minY)
        road.zPosition = -1
        road.physicsBody = SKPhysicsBody(rectangleOf: roadSize)
        road.physicsBody?.friction = 0
        road.physicsBody?.isDynamic = false
        road.physicsBody?.collisionBitMask = 0
        self.addChild(road)
        
        roadLine = SKShapeNode(rectOf: roadLineSize)
        roadLine.position = .init(x: frame.midX, y: frame.maxY + roadLineSize.height)
        roadLine.zPosition = -1
        roadLine.fillColor = .white
        roadLine.physicsBody = SKPhysicsBody(rectangleOf: roadLineSize)
        roadLine.physicsBody?.friction = 0
        roadLine.physicsBody?.isDynamic = false
        roadLine.physicsBody?.collisionBitMask = 0
        
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
        
        addCarDuration = 3
        addRoadLineDuration = 1
                
        let _ = Timer.scheduledTimer(
            timeInterval: 1,
            target: self,
            selector: #selector(speedUpGame),
            userInfo: nil,
            repeats: true)
        
        setupMotionManager()
    }
    
    override func update(_ currentTime: TimeInterval) {
        var posX = destX
        let roadMinX = road.frame.minX + 30
        let roadMaxX = road.frame.maxX - 22

        if posX < roadMinX {
            posX = roadMinX
        }

        if posX > roadMaxX {
            posX = roadMaxX
        }

        player.run(.moveTo(x: posX, duration: 0.1))
    }
    
    func setupMotionManager() {
        motionManager.accelerometerUpdateInterval = 0.1
        motionManager.startAccelerometerUpdates(to: OperationQueue.current!) { [weak self] (data, error) in
            guard
                let `self` = self,
                let data = data
                else { return }
            self.destX = self.player.position.x + CGFloat(data.acceleration.x * 200)
        }
    }
    
    func addPlayer() {
        gameCount += 1

        let playerPosY = player.size.height / 2 + 20 + safeAreaInsets.bottom
        player.position = CGPoint(x: self.frame.size.width / 2, y: playerPosY)
        player.zPosition = 1
        player.name = "player"
        
        player.physicsBody = SKPhysicsBody(
            texture: player.texture!,
            size: player.texture!.size())
        
        player.physicsBody?.isDynamic = true
        player.physicsBody?.categoryBitMask = Category.playerCategory.rawValue
        player.physicsBody?.contactTestBitMask = Category.carCategory.rawValue
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
        
        scoreRatioLabel = SKLabelNode()
        scoreRatioLabel.position = CGPoint(
            x: frame.maxX - 20,
            y: frame.minY + 20 + safeAreaInsets.bottom)
        scoreRatioLabel.fontName = fontName
        scoreRatioLabel.fontSize = 15
        scoreRatioLabel.fontColor = UIColor.white
        scoreRatioLabel.zPosition = -1
        self.addChild(scoreRatioLabel)
    }
    
    @objc
    func speedUpGame() {
        if animationDuration != 2 {
            animationDuration = max(animationDuration - 0.5, 2)
        }
        
        if addCarDuration != 1 {
            addCarDuration = max(addCarDuration - 0.5, 1)
        }
        
        if addRoadLineDuration != 0.5 {
            addRoadLineDuration = max(addRoadLineDuration - 0.1, 0.5)
        }
    }
    
    func addRoadLine() {
        if let copy = roadLine.copy() as? SKShapeNode {
            addChild(copy)
            var actions = [SKAction]()
            actions.append(.moveTo(
                y: -roadLineSize.height,
                duration: addRoadLineDuration * 5))
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
            body.categoryBitMask = Category.carCategory.rawValue
            body.contactTestBitMask = Category.playerCategory.rawValue
            body.collisionBitMask = 0

            copy.physicsBody = body
            
            self.addChild(copy)
            
            var actions = [SKAction]()
            actions.append(.moveTo(
                y: -copy.size.height,
                duration: animationDuration))
            actions.append(.removeFromParent())
            
            let increaseScore = SKAction.run {
                let point = 1 * self.scoreRatio
                self.score += point
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
        
        if (fBody.categoryBitMask & Category.playerCategory.rawValue) != 0
            && (sBody.categoryBitMask & Category.carCategory.rawValue) != 0 {
            if let car = sBody.node as? SKSpriteNode {
                playerDidCollide(with: car)
            }
        }
    }
}
