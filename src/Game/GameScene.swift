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

// MARK: - Key

enum Key: String {
    case addCar = "add_car"
    case addRoadLine = "add_road_line"
    case score = "score"
    case bestScore = "best_score"
    case car = "car"
    case newGame = "new_game_button"
    case newGameLabel = "new_game_label"
    case playVideo = "play_video"
    case playVideoLabel = "play_video_label"
    case singleCoin = "single_coin"
    case multipleCoins = "multiple_coins"
    case coinBag = "coin_bag"
    case addCoin = "add_coin"
}

// MARK: - Category

enum Category: UInt32 {
    case coinCategory = 0x100
    case carCategory = 0x10
    case playerCategory = 0x1
}

// MARK: - SceneDelegate

protocol SceneDelegate: class {
    func scene(_ scene: GameScene, didFinishGameWithScore score: Int)
    func scene(_ scene: GameScene, shouldPresentRewardBasedVideoAd present: Bool)
    func scene(_ scene: GameScene, shouldPresentMenuScene present: Bool)
}

// MARK: - GameScene

class GameScene: SKScene {
    
    weak var sceneDelegate: SceneDelegate?
    lazy var rewardBasedVideoAdPresented: Bool = false
    lazy var safeAreaInsets: UIEdgeInsets = .zero
    
    private let motionManager = CMMotionManager()
    private var player: SKSpriteNode!
    private var road: SKShapeNode!
    private var roadLine: SKShapeNode!
    private var roadCar: SKSpriteNode!
    
    private var singleCoin: SKSpriteNode!
    private var multipleCoins: SKSpriteNode!
    private var coinBag: SKSpriteNode!
    
    lazy var gameOver: Bool = false
    
    var coinSound: SKAction!
    var explosionSound: SKAction!
    var explosionNode: SKEmitterNode!

    var roadLineSize: CGSize {
        return .init(width: 10, height: 40)
    }
    
    private var scoreLabel: SKLabelNode!
    var score: Int = 0 {
        didSet {
            if scoreLabel != nil {
                scoreLabel.text = "Score: \(score)"
            }
        }
    }
    
    var livesArray: [SKSpriteNode] = []
    var carPhysicsBodies: [SKTexture: SKPhysicsBody] = [:]
    
    var cars: [SKTexture] = [
        .init(imageNamed: "taxi"),
        .init(imageNamed: "ambulance"),
        .init(imageNamed: "truck"),
        .init(imageNamed: "mini_truck"),
        .init(imageNamed: "mini_van"),
        .init(imageNamed: "police"),
        .init(imageNamed: "old_car"),
        .init(imageNamed: "audi")
    ]
        
    override func didMove(to view: SKView) {
        player = SKSpriteNode(imageNamed: "black_viper")
        player.aspectFill(width: frame.width / 3)
        
        setupGame()
        preloadCars()
        
        let roadSize: CGSize = .init(width: frame.width, height: frame.height * 2)
        road = SKShapeNode(rectOf: roadSize)
        road.fillColor = SKColor(red: 105/255, green: 105/255, blue: 105/255, alpha: 1)
        road.strokeColor = .darkGray
        road.position = .init(x: frame.midX, y: frame.minY)
        road.zPosition = -1
        self.addChild(road)
        
        roadLine = SKShapeNode(rectOf: roadLineSize)
        roadLine.zPosition = -1
        roadLine.fillColor = .lightGray
        roadLine.strokeColor = .lightGray
        
        roadCar = SKSpriteNode(texture: cars[0])
        roadCar.position = CGPoint(x: 0, y: frame.size.height + roadCar.size.height)
        roadCar.zPosition = 1
        roadCar.name = Key.car.rawValue
        roadCar.aspectFill(width: frame.width / 3)
        
        coinSound = SKAction.playSoundFileNamed("coin.wav", waitForCompletion: false)
        explosionSound = SKAction.playSoundFileNamed("explosion.wav", waitForCompletion: false)
        explosionNode = SKEmitterNode(fileNamed: "Explosion")!
        
        self.backgroundColor = .dark
        self.physicsWorld.gravity = CGVector(dx: 0, dy: 0)
        self.physicsWorld.contactDelegate = self
        
        let roadActions: [SKAction] = [
            .wait(forDuration: 0.25),
            .run(addRoadLine)
        ]
        
        run(.repeatForever(.sequence(roadActions)))
        
        let addCar: [SKAction] = [
            .wait(forDuration: 1),
            .run(addRandomCar)
        ]
        
        run(.repeatForever(.sequence(addCar)),
            withKey: Key.addCar.rawValue)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            
            let location = touch.location(in: self)
            let node = self.atPoint(location)
            
            if node.name == Key.newGame.rawValue
                || node.name == Key.newGameLabel.rawValue {
                newGameTapped()
            } else if node.name == Key.playVideo.rawValue
                || node.name == Key.playVideoLabel.rawValue {
                playVideoTapped()
            }
        }
    }
    
    private func preloadCars() {
        cars.forEach { (texture) in
            texture.preload { [weak self] in
                guard let strongSelf = self else { return }
                let physicsBody = SKPhysicsBody(texture: texture, size: texture.size())
                physicsBody.isDynamic = false
                physicsBody.categoryBitMask = Category.carCategory.rawValue
                physicsBody.contactTestBitMask = Category.playerCategory.rawValue
                physicsBody.collisionBitMask = 0
                strongSelf.carPhysicsBodies[texture] = physicsBody
            }
        }
    }
    
    func setupGame() {
        gameCount += 1
        setupPlayer()
        setupGameScore()
        setupLives(count: 3)
        setupMotionManager()
        setupCoins()
    }
    
    func continueGame() {
        self.setupPlayer()
        self.setupLives(count: 1)
        self.gameOver = false
        self.isPaused = false
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            self.action(forKey: Key.addCar.rawValue)?.speed = 1
        }
    }
    
    func stopGame() {
        self.sceneDelegate?.scene(self, didFinishGameWithScore: score)
        
        if !rewardBasedVideoAdPresented {
            self.isPaused = true
            self.action(forKey: Key.addCar.rawValue)?.speed = 0
            setupNewGameButton()
            setupPlayVideoButton()
        } else {
            self.sceneDelegate?.scene(self, shouldPresentMenuScene: true)
        }
    }
    
    func setupNewGameButton() {
        let btn = SKShapeNode.buildButton(name: Key.newGame.rawValue)
        let posY = frame.midY
        btn.position = .init(x: frame.midX, y: posY)
        addChild(btn)
        
        let lbl = SKLabelNode.buildLabel(
            text: "New Game",
            name: Key.newGameLabel.rawValue,
            fontName: fontName)
        lbl.position = .init(x: frame.midX, y: posY - 8)
        addChild(lbl)
    }
    
    func setupPlayVideoButton() {
        let btn = SKShapeNode.buildButton(name: Key.playVideo.rawValue)
        let posY = frame.midY - 68
        btn.position = .init(x: frame.midX, y: posY)
        addChild(btn)
        
        let lbl = SKLabelNode.buildLabel(
            text: "Continue Game",
            name: Key.playVideoLabel.rawValue,
            fontName: fontName)
        lbl.position = .init(x: frame.midX, y: posY - 8)
        addChild(lbl)
    }
    
    func newGameTapped() {
        let gameScene = GameScene(size: self.size)
        gameScene.safeAreaInsets = safeAreaInsets
        gameScene.sceneDelegate = sceneDelegate
        gameScene.scaleMode = .aspectFit
        self.view?.presentScene(gameScene)
    }
    
    func playVideoTapped() {
        self.rewardBasedVideoAdPresented = true
        self.sceneDelegate?.scene(self, shouldPresentRewardBasedVideoAd: true)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            let keys: [Key] = [.newGame, .newGameLabel, .playVideo, .playVideoLabel]
            keys.forEach { self.childNode(withName: $0.rawValue)?.removeFromParent() }
            
            self.enumerateChildNodes(withName: Key.car.rawValue) { (node, _) in
                node.removeFromParent()
            }
        }
    }
    
    private func setupCoins() {
        
        func buildCoin(withKey key: Key) -> SKSpriteNode {
            let node = SKSpriteNode(imageNamed: key.rawValue)
            node.size = CGSize(width: 10, height: 10)
            node.position = CGPoint(x: 0, y: frame.size.height + node.size.height)
            node.zPosition = 0
            node.name = key.rawValue
            node.aspectFill(width: frame.width / 3)
            return node
        }
        
        singleCoin = buildCoin(withKey: .singleCoin)
        multipleCoins = buildCoin(withKey: .multipleCoins)
        coinBag = buildCoin(withKey: .coinBag)
        
        let actions: [SKAction] = [
            .wait(forDuration: 5),
            .run(addCoin)
        ]
        
        run(.repeatForever(.sequence(actions)),
            withKey: Key.addCoin.rawValue)
    }
    
    private func addRoadLine() {
        if let copy = roadLine.copy() as? SKShapeNode {
            let posX = road.frame.minX + player.size.width
            copy.position = .init(x: posX, y: frame.maxY + roadLineSize.height)
            
            addChild(copy)
            var actions = [SKAction]()
            actions.append(.moveTo(
                y: -roadLineSize.height,
                duration: 2))
            actions.append(.removeFromParent())
            copy.run(.sequence(actions))
        }
        
        if let copy = roadLine.copy() as? SKShapeNode {
            let posX = road.frame.maxX - player.size.width
            copy.position = .init(x: posX, y: frame.maxY + roadLineSize.height)
            
            addChild(copy)
            var actions = [SKAction]()
            actions.append(.moveTo(
                y: -roadLineSize.height,
                duration: 2))
            actions.append(.removeFromParent())
            copy.run(.sequence(actions))
        }
    }
    
    private func addRandomCar() {
        if let copy = self.roadCar.copy() as? SKSpriteNode {
            self.cars = GKRandomSource.sharedRandom()
                .arrayByShufflingObjects(in: self.cars) as! [SKTexture]
            
            let texture = self.cars[0]
            copy.texture = texture
            
            let roadMinX = self.frame.minX + 30
            let roadMaxX = self.frame.maxX - 20
            
            let randomDist = GKRandomDistribution(
                lowestValue: Int(roadMinX),
                highestValue: Int(roadMaxX))
            copy.position.x = CGFloat(randomDist.nextInt())
            
            if let copyBody = carPhysicsBodies[texture]?.copy() as? SKPhysicsBody {
                copy.physicsBody = copyBody
            }
            
            self.addChild(copy)
            
            var actions = [SKAction]()
            actions.append(.moveTo(
                y: -copy.texture!.size().height / 2,
                duration: 3))
            
            let increaseScore = SKAction.run {
                if !self.gameOver {
                    self.score += 1
                }
            }
            
            actions.append(increaseScore)
            actions.append(.removeFromParent())
            copy.run(.sequence(actions))
        }
    }
    
    private func addCoin() {
        let random = Int.random(in: 0...10)
        var randomCoin: SKSpriteNode?
        
        if random >= 0 && random <= 5 {
            randomCoin = singleCoin.copy() as? SKSpriteNode
        } else if random > 5 && random <= 8 {
            randomCoin = multipleCoins.copy() as? SKSpriteNode
        } else {
            randomCoin = coinBag.copy() as? SKSpriteNode
        }
        
        if let copy = randomCoin {
            let roadMinX = self.frame.minX + 30
            let roadMaxX = self.frame.maxX - 20
            
            let randomDist = GKRandomDistribution(
                lowestValue: Int(roadMinX),
                highestValue: Int(roadMaxX))
            
            copy.position.x = CGFloat(randomDist.nextInt())
            
            let physicsBody = SKPhysicsBody(circleOfRadius: copy.size.width / 2)
            physicsBody.isDynamic = false
            physicsBody.categoryBitMask = Category.coinCategory.rawValue
            physicsBody.contactTestBitMask = Category.playerCategory.rawValue
            physicsBody.collisionBitMask = 0
            
            copy.physicsBody = physicsBody
            
            self.addChild(copy)
            
            var actions = [SKAction]()
            actions.append(.moveTo(
                y: -copy.texture!.size().height / 2,
                duration: 3))
            
            actions.append(.removeFromParent())
            copy.run(.sequence(actions))
        }
    }
    
    private func setupPlayer() {
        let playerPosY = player.size.height / 2 + 20 + safeAreaInsets.bottom
        player.position = CGPoint(x: frame.width / 2, y: playerPosY)
        player.zPosition = 1
        player.name = "player"
        
        player.physicsBody = SKPhysicsBody(
            texture: player.texture!,
            size: player.texture!.size())
        
        player.physicsBody?.isDynamic = true
        player.physicsBody?.categoryBitMask = Category.playerCategory.rawValue
        player.physicsBody?.contactTestBitMask = Category.carCategory.rawValue
        player.physicsBody?.collisionBitMask = 0
        
        self.addChild(player)
    }
    
    private func setupGameScore() {
        scoreLabel = SKLabelNode(text: "Score: 0")
        scoreLabel.position = CGPoint(x: 70, y: frame.size.height - 40 - safeAreaInsets.top)
        scoreLabel.fontName = fontName
        scoreLabel.fontSize = 28
        scoreLabel.fontColor = UIColor.white
        scoreLabel.zPosition = -1
        score = 0
        self.addChild(scoreLabel)
    }
    
    private func setupLives(count: Int) {
        let size = CGSize(width: 40, height: 50)
        var posX = frame.maxX - 6 - (size.width / 2)
        let posY = frame.maxY - 30 - safeAreaInsets.top
        for _ in 0..<count {
            let texture = SKTexture(imageNamed: "black_viper")
            let node = SKSpriteNode(texture: texture)
            node.size = size
            node.position = CGPoint(x: posX, y: posY)
            node.zPosition = -1
            node.aspectFill(to: size)
            
            let physicsBody = SKPhysicsBody(texture: texture, size: size)
            physicsBody.collisionBitMask = 0
            node.physicsBody = physicsBody
            
            livesArray.append(node)
            addChild(node)
            posX -= ((size.width / 2) + 6)
        }
    }
    
    private func setupMotionManager() {
        motionManager.startAccelerometerUpdates(to: .main) { [weak self] (data, error) in
            guard let strongSelf = self, let data = data else { return }
            
            var posX = strongSelf.player.position.x + CGFloat(data.acceleration.x * 20)
            let roadMinX = strongSelf.frame.minX + 30
            let roadMaxX = strongSelf.frame.maxX - 20
            
            if posX < roadMinX { posX = roadMinX }
            if posX > roadMaxX { posX = roadMaxX }
            
            strongSelf.player.run(.moveTo(x: posX, duration: 0))
        }
    }
}

// MARK: - SKPhysicsContactDelegate

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
                playerDidCollide(withCar: car)
            }
        }
        
        if (fBody.categoryBitMask & Category.playerCategory.rawValue) != 0
            && (sBody.categoryBitMask & Category.coinCategory.rawValue) != 0 {
            if let coin = sBody.node as? SKSpriteNode {
                playerDidCollide(withCoin: coin)
            }
        }
    }
    
    fileprivate func playerDidCollide(withCar car: SKSpriteNode) {
        car.removeFromParent()
        
        if let live = livesArray.last {
            live.removeFromParent()
            livesArray.removeLast()
        }
        
        if livesArray.isEmpty {
            self.gameOver = true
            
            explosionNode.position = player.position
            self.addChild(explosionNode)
            
            self.run(explosionSound)
            player.removeFromParent()
            car.removeFromParent()
            
            self.run(.wait(forDuration: 2)) { [weak self] in
                guard let strongSelf = self else { return }
                strongSelf.explosionNode.removeFromParent()
                strongSelf.stopGame()
            }
        }
    }
    
    fileprivate func playerDidCollide(withCoin coin: SKSpriteNode) {
        self.run(coinSound)
        coin.removeFromParent()
        if let key = coin.name {
            switch key {
            case Key.singleCoin.rawValue:
                score += 10
            case Key.multipleCoins.rawValue:
                score += 25
            case Key.coinBag.rawValue:
                score += 50
            default:
                break
            }
        }
    }
}
