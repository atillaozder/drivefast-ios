//
//  GameScene.swift
//  Retro
//
//  Created by Atilla Özder on 10.10.2019.
//  Copyright © 2019 Atilla Özder. All rights reserved.
//

import SpriteKit
import GameplayKit
import CoreMotion

// MARK: - Global Variables
public var gameCount: Double = 0
public let scaleRatio: CGFloat = UIDevice.current.isPad ? 6 : 4

// MARK: - SceneDelegate
protocol SceneDelegate: class {
    func scene(_ scene: GameScene, didUpdateScore score: Double)
    func scene(_ scene: GameScene, willUpdateLifeCount count: Int)
    func scene(_ scene: GameScene, didFinishGameWithScore score: Double)
    func scene(_ scene: GameScene, didUpdateGameState state: GameState)
}

// MARK: - GameScene
class GameScene: SKScene {
        
    // MARK: - Properties
    private var stayPaused = false

    override var isPaused: Bool {
        get {
            return super.isPaused
        } set {
            if (!stayPaused) {
                super.isPaused = newValue
                
                newValue ? stopMotionManager() : startMotionManager()
                if let addCarSeq = self.action(forKey: Actions.addCar.rawValue) {
                    addCarSeq.speed = newValue ? 0 : 1
                }
            }
            
            stayPaused = false
        }
    }
    
    var gameStarted: Bool {
        return true
    }
    
    private let motionManager = CMMotionManager()
    let soundManager = SoundManager()
    weak var sceneDelegate: SceneDelegate?
    
    lazy var playerNode: SKSpriteNode = {
        let image = UserDefaults.standard.player
        let texture = SKTexture(imageNamed: image)
        let _ = texture.size()
        
        let car = SKSpriteNode(texture: texture)
        car.zPosition = 1
        car.name = Cars.player.rawValue
                
        if !setCarPhysicsBody(car, from: texture) {
            let aNode = SKShapeNode()
            aNode.fillTexture = SKTexture(imageNamed: image)
            setCarPhysicsBody(car, from: aNode.fillTexture) 
        }
        
        car.physicsBody?.categoryBitMask = Category.player.rawValue
        car.physicsBody?.contactTestBitMask = Category.car.rawValue
        
        let ratio = UIDevice.current.isPad ? scaleRatio + 5.5 : scaleRatio + 2.5
        car.setScale(to: frame.width / ratio)
        return car
    }()
    
    lazy var roadNode: SKShapeNode = {
        let roadSize: CGSize = .init(width: frame.width, height: frame.height * 2)
        let node = SKShapeNode(rectOf: roadSize)
        node.fillColor = .roadColor
        node.strokeColor = .roadColor
        node.position = .init(x: frame.midX, y: frame.minY)
        node.zPosition = -1
        return node
    }()
    
    let roadLineNode: SKSpriteNode = {
        let node = SKSpriteNode(imageNamed: "road-line")
        node.zPosition = -1
        node.size = .init(width: 6, height: 30)
        return node
    }()
    
    private var explosionNode: SKEmitterNode!
    lazy var singleCoin = Coin(frame: frame, type: .single)
    lazy var multipleCoins = Coin(frame: frame, type: .multiple)
    lazy var coinBag = Coin(frame: frame, type: .bag)
    
    var score: Double = 0 {
        willSet (newScore) {
            guard newScore > 0 else { return }
            let diff = abs(newScore - score)
            let divisor: Double = 100
            
            if diff >= 10 {
                // it means a coin has taken
                let division = (newScore / divisor).rounded(.down)
                if score < (divisor * division) && newScore > (divisor * division) {
                    self.setGameDifficulty()
                }
            } else {
                if newScore.truncatingRemainder(dividingBy: divisor) == 0 {
                    self.setGameDifficulty()
                }
            }
        } didSet {
            sceneDelegate?.scene(self, didUpdateScore: score)
        }
    }
        
    /// safe area insets of the game view controller
    lazy var insets: UIEdgeInsets = .zero
    lazy var gotReward: Bool = false
    lazy var gameOver: Bool = false

    var cachedCars = [Car: SKPhysicsBody]()
    var lifeCount: Int = 3 {
        willSet {
            sceneDelegate?.scene(self, willUpdateLifeCount: newValue)
            if newValue == 0 {
                finishGame()
            }
        }
    }
    
    private lazy var roadBoundingBox: RoadBoundingBox = {
        let w = playerNode.size.width / 2
        let h = playerNode.size.height / 2
        
        let minX = self.frame.minX + w
        let maxX = self.frame.maxX - w
        let minY = self.frame.minY + h + 10
        let maxY = self.frame.maxY - h
        
        return .init(minY: minY, minX: minX, maxY: maxY, maxX: maxX)
    }()
    
    private lazy var cars: [Car] = {
        var cars = [Car]()
        let player = UserDefaults.standard.player
        for idx in 0...20 {
            let carName = "car\(idx)"
            if carName != player {
                cars.append(.init(index: idx))
            }
        }
        return cars
    }()
    
    /// game difficulty algorithm properties
    private var appearanceDuration: TimeInterval = 3
    private var waitingDuration: TimeInterval = 1
    private var appearanceThreshold: TimeInterval = 1.5
    private var waitingThreshold: TimeInterval = 0.5

    // MARK: - Game Life Cycle
    override func willMove(from view: SKView) {
        super.willMove(from: view)
        clearGame()
    }
    
    override func didMove(to view: SKView) {
        super.didMove(to: view)
        self.backgroundColor = .roadColor
        initiateGame()
                
        self.addChild(roadNode)
        self.physicsWorld.gravity = CGVector(dx: 0, dy: 0)
        self.physicsWorld.contactDelegate = self
        
        if UIDevice.current.isPad {
            addFlatRoadLine()
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            if !UIDevice.current.isPad {
                let addRoadLineSq: SKAction = .sequence([
                    .wait(forDuration: 0.05),
                    .run(self.addRoadLine, queue: .global())
                ])
                self.run(.repeatForever(addRoadLineSq))
            }
            
            self.initiateCarSequence()
        }
    }
    
    private func initiateCarSequence() {
        self.removeAction(forKey: Actions.addCar.rawValue)
        let addCarQueue = DispatchQueue(
            label: "com.retro2d.ios.concurrent.addCar", qos: .default, attributes: .concurrent)
        
        let addCarSq: SKAction = .sequence([
            .wait(forDuration: waitingDuration),
            .run(self.addRandomCar, queue: addCarQueue)
        ])
        
        let action: SKAction = .repeatForever(addCarSq)
        self.run(action, withKey: Actions.addCar.rawValue)
    }
    
    private func setGameDifficulty() {
        if appearanceDuration > appearanceThreshold ||
            waitingDuration > waitingThreshold {
            appearanceDuration = max(appearanceThreshold, appearanceDuration - 0.5)
            waitingDuration = max(waitingThreshold, waitingDuration - 0.1)
            initiateCarSequence()
        }
    }
    
    private func clearGame() {
        stopMotionManager()
        self.removeAllActions()
        self.removeAllChildren()
        movePlayerToMiddle()
    }
    
    func movePlayerToMiddle() {
        playerNode.position = .init(x: self.frame.midX, y: roadBoundingBox.minY)
    }
    
    func initiateGame() {
        gameCount += 1
        movePlayerToMiddle()
        addChild(playerNode)
        
        startMotionManager()
        
        DispatchQueue.global().async {
            self.explosionNode = SKEmitterNode(fileNamed: "Explosion")!
        }
        
        let addCoinSq: SKAction = .sequence([
            .wait(forDuration: 5),
            .run(addCoin, queue: .init(label: "com.retro2d.ios.serial.addCoin"))
        ])

        run(.repeatForever(addCoinSq))
    }
        
    fileprivate func stopGame() {
        if !gotReward {
            self.isPaused = true
            self.sceneDelegate?.scene(self, didUpdateGameState: .advertisement)
        } else {
            self.sceneDelegate?.scene(self, didUpdateGameState: .home)
        }
    }
    
    func finishGame() {
        self.gameOver = true
        
        let explosion = self.explosionNode.copy() as! SKEmitterNode
        explosion.position = playerNode.position
        self.addChild(explosion)
        
        soundManager.playEffect(.crash, in: self)
        playerNode.removeFromParent()
        self.sceneDelegate?.scene(self, didFinishGameWithScore: score)

        self.run(.wait(forDuration: 1)) { [weak self] in
            guard let strongSelf = self else { return }
            explosion.removeFromParent()
            strongSelf.stopGame()
        }
    }
    
    func didGetReward() {
        movePlayerToMiddle()
        addChild(playerNode)
        
        self.lifeCount = 1
        self.gameOver = false
        self.isPaused = false
    }
    
    func willPresentRewardBasedVideoAd() {
        self.gotReward = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.enumerateChildNodes(withName: Cars.car.rawValue) { (node, ptr) in
                node.removeFromParent()
            }
        }
    }
    
    func setStayPaused() {
        if (super.isPaused) {
            self.stayPaused = true
        }
    }
    
    private func addFlatRoadLine() {
        var posX = self.roadNode.frame.minX
        
        for _ in 1..<Int(scaleRatio) {
            let lineNode = self.roadLineNode.copy() as! SKSpriteNode
            lineNode.size.height = self.frame.height * 2
            
            posX += (frame.width / scaleRatio)
            lineNode.position = .init(x: posX, y: self.frame.maxY)
            
            DispatchQueue.main.async {
                self.addChild(lineNode)
            }
        }
    }
        
    private func stopMotionManager() {
        motionManager.stopAccelerometerUpdates()
    }
        
    private func startMotionManager() {
        stopMotionManager()
        motionManager.accelerometerUpdateInterval = 0.01
        motionManager.startAccelerometerUpdates(to: .init()) { [weak self] (data, error) in
            guard let strongSelf = self, let data = data else { return }

            let player = strongSelf.playerNode
            let position = player.position
            var x = position.x + CGFloat(data.acceleration.x * 10)
            var y = position.y + CGFloat(data.acceleration.y * 10)

            let road = strongSelf.roadBoundingBox
            x = max(x, road.minX)
            x = min(x, road.maxX)
            y = max(y, road.minY)
            y = min(y, road.maxY)
            
            player.position = .init(x: x, y: y)
        }
    }
    
    @discardableResult
    private func setCarPhysicsBody(_ car: SKSpriteNode, from texture: SKTexture?) -> Bool {
        if car.physicsBody != nil {
            return true
        }
        
        guard let texture = texture else { return false }
        let body = SKPhysicsBody(texture: texture, size: texture.size())
        body.isDynamic = true
        body.categoryBitMask = Category.car.rawValue
        body.contactTestBitMask = Category.player.rawValue | Category.car.rawValue
        body.collisionBitMask = 0
        
        car.physicsBody = body
        return body.area != 0.0
    }
        
    // MARK: - RepeatForever Actions
    private func addRoadLine() {
        let height = roadLineNode.size.height + 20
        let posY: CGFloat = self.frame.maxY + height
        
        var actions = [SKAction]()
        actions.append(.moveTo(y: -height, duration: 0.5))
        actions.append(.removeFromParent())
        
        var posX = self.roadNode.frame.minX
        for _ in 1..<Int(scaleRatio) {
            guard let lineNode = self.roadLineNode.copy() as? SKSpriteNode else { return }

            posX += (frame.width / scaleRatio)
            lineNode.position = .init(x: posX, y: posY)
            
            DispatchQueue.main.async {
                self.addChild(lineNode)
                lineNode.run(.sequence(actions))
            }
        }
    }
    
    private func addRandomCar() {
        let addCarClosure: () -> Void = { [weak self] in
            guard let `self` = self else { return }
            
            self.cars.shuffle()
            let car = self.cars[0]
            
            let texture = SKTexture(imageNamed: car.imageName)
            let roadMinX = Int(self.frame.minX + 30)
            let roadMaxX = Int(self.frame.maxX - 30)
            
            let randomDist = GKRandomDistribution(
                lowestValue: roadMinX, highestValue: roadMaxX)
            
            let carNode = SKSpriteNode(texture: texture)

            carNode.name = Cars.car.rawValue
            carNode.zPosition = 1

            if let body = self.cachedCars[car] {
                carNode.physicsBody = (body.copy() as! SKPhysicsBody)
            } else {
                self.setCarPhysicsBody(carNode, from: texture)
                
                if carNode.physicsBody != nil {
                    self.cachedCars[car] = carNode.physicsBody
                } else {
                    #if DEBUG
                    // Debug mode is on, continue
                    #else
                    // Physics body is empty, if game is started dont add car to screen
                    if self.gameStarted {
                        return
                    }
                    #endif
                }
            }
            
            carNode.setScale(to: self.frame.width / car.ratio)
            carNode.position = CGPoint(
                x: CGFloat(randomDist.nextInt()), y: self.frame.maxY + carNode.size.height)
            
            let move = SKAction.moveTo(y: -carNode.size.height / 2, duration: self.appearanceDuration)
            var actions = [SKAction]()
            actions.append(move)

            let increaseScore = SKAction.run { [unowned self] in
                if !self.gameOver {
                    self.score += 1
                }
            }

            actions.append(increaseScore)
            actions.append(.removeFromParent())
            
            DispatchQueue.main.async {
                self.addChild(carNode)
                carNode.run(.sequence(actions))
            }
        }
        
        addCarClosure()
        if UIDevice.current.isPad {
            addCarClosure()
        }
    }
    
    private func addCoin() {
        let random = Int.random(in: 0...10)
        var coin: Coin
        
        if random >= 0 && random <= 5 {
            coin = self.singleCoin.copy() as! Coin
            coin.type = .single
        } else if random > 5 && random <= 8 {
            coin = self.multipleCoins.copy() as! Coin
            coin.type = .multiple
        } else {
            coin = self.coinBag.copy() as! Coin
            coin.type = .bag
        }
        
        let roadMinX = Int(self.frame.minX + 30)
        let roadMaxX = Int(self.frame.maxX - 30)
        
        let randomDist = GKRandomDistribution(lowestValue: roadMinX, highestValue: roadMaxX)
        coin.position.x = CGFloat(randomDist.nextInt())
        
        let body = SKPhysicsBody(circleOfRadius: coin.size.width / 2)
        body.isDynamic = false
        body.categoryBitMask = Category.coin.rawValue
        body.contactTestBitMask = Category.player.rawValue
        body.collisionBitMask = 0
        coin.physicsBody = body
        
        var actions = [SKAction]()
        actions.append(.moveTo(y: -coin.size.height / 2, duration: appearanceDuration))
        actions.append(.removeFromParent())
        
        DispatchQueue.main.async {
            self.addChild(coin)
            coin.run(.sequence(actions))
        }
    }
}
