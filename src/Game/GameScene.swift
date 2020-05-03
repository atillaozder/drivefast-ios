//
//  GameScene.swift
//  DriveFast
//
//  Created by Atilla Özder on 10.10.2019.
//  Copyright © 2019 Atilla Özder. All rights reserved.
//

import SpriteKit
import GameplayKit
import CoreMotion

// MARK: - SceneDelegate
protocol SceneDelegate: AnyObject {
    func scene(_ scene: GameScene, didUpdateScore score: Double)
    func scene(_ scene: GameScene, willUpdateLifeCount count: Int)
    func scene(_ scene: GameScene, didFinishGameWithScore score: Double)
    func scene(_ scene: GameScene, didUpdateGameState state: GameState)
    func scene(_ scene: GameScene, didUpdateRemainingFuel fuel: Float)
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
        let player = UserDefaults.standard.playerCar
        let element = GameManager.shared.getDictElement(value: player)
        let car = element.key.copy() as! SKSpriteNode
        car.name = Cars.player.rawValue
        car.physicsBody?.categoryBitMask = Category.player.rawValue
        car.physicsBody?.contactTestBitMask = Category.car.rawValue
        car.setScale(to: self.frame.width / element.value.ratio)
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
    
    private lazy var singleCoin = Coin(frame: frame, type: .single)
    private lazy var multipleCoins = Coin(frame: frame, type: .multiple)
    private lazy var coinBag = Coin(frame: frame, type: .bag)
    private lazy var fuel = Fuel(frame: frame)

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
    
    var remainingFuel: Float = 100 {
        didSet {
            DispatchQueue.main.async {
//                if self.remainingFuel == 0 {
//                    self.finishGame()
//                }
                self.sceneDelegate?.scene(
                    self, didUpdateRemainingFuel: self.remainingFuel)
            }
        }
    }
    
    /// safe area insets of the game view controller
    lazy var insets: UIEdgeInsets = .zero
    lazy var gotReward: Bool = false
    lazy var gameOver: Bool = false
    
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
        
    func resetPlayerPosition() {
        playerNode.position = .init(x: self.frame.midX, y: roadBoundingBox.minY)
    }
    
    func initiateGame() {
        GameManager.shared.gameCount += 1
        resetPlayerPosition()
        addChild(playerNode)
        
        startMotionManager()
        
        let addCoinSq: SKAction = .sequence([
            .wait(forDuration: Coin.waitForDuration),
            .run(addCoin, queue: .init(label: "com.atillaozder.DriveFast.addCoin.serialQueue"))
        ])
        
        run(.repeatForever(addCoinSq))
        
        let addFuelSq: SKAction = .sequence([
            .wait(forDuration: Fuel.waitForDuration),
            .run(addFuel, queue: .init(label: "com.atillaozder.DriveFast.addFuel.serialQueue"))
        ])
        
        run(.repeatForever(addFuelSq))
        
        let setFuelSq: SKAction = .sequence([
            .wait(forDuration: 1),
            .run(setFuel, queue: .global())
        ])
        
        run(.repeatForever(setFuelSq))
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
        
        let explosionEffect = GameManager.shared.explosionEffect
        explosionEffect.position = playerNode.position
        self.addChild(explosionEffect)
        
        soundManager.playEffect(.crash, in: self)
        playerNode.removeFromParent()
        self.sceneDelegate?.scene(self, didFinishGameWithScore: score)
        
        self.run(.wait(forDuration: 1)) { [weak self] in
            guard let `self` = self else { return }
            explosionEffect.removeFromParent()
            self.stopGame()
        }
    }
    
    func didChangePauseState() {
        isPaused ? stopMotionManager() : startMotionManager()
        if let addCarSeq = self.action(forKey: Actions.addCar.rawValue) {
            addCarSeq.speed = isPaused ? 0 : 1
        }
    }
    
    func didGetReward() {
        resetPlayerPosition()
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
    
    // MARK: - Private Helper Methods
    
    private func addFlatRoadLine() {
        var posX = self.roadNode.frame.minX
        for _ in 1..<Int(Car.scaleRatio) {
            let node = self.roadLineNode.copy() as! SKSpriteNode
            node.size.height = self.frame.height * 2
            
            posX += (frame.width / Car.scaleRatio)
            node.position = .init(x: posX, y: self.frame.maxY)
            
            DispatchQueue.main.async {
                self.addChild(node)
            }
        }
    }
    
    private func getRandomPosX() -> CGFloat {
        let roadMinX = Int(self.frame.minX + 30)
        let roadMaxX = Int(self.frame.maxX - 30)
        let randomDist = GKRandomDistribution(lowestValue: roadMinX, highestValue: roadMaxX)
        return CGFloat(randomDist.nextInt())
    }
    
    private func stopMotionManager() {
        motionManager.stopAccelerometerUpdates()
    }
    
    private func startMotionManager() {
        stopMotionManager()
        motionManager.accelerometerUpdateInterval = 0.01
        motionManager.startAccelerometerUpdates(to: .init()) { [weak self] (data, error) in
            guard let `self` = self, let data = data else { return }
            let player = self.playerNode
            let position = player.position
            var x = position.x + CGFloat(data.acceleration.x * 10)
            var y = position.y + CGFloat(data.acceleration.y * 10)
            
            let road = self.roadBoundingBox
            x = max(x, road.minX)
            x = min(x, road.maxX)
            y = max(y, road.minY)
            y = min(y, road.maxY)
            
            player.position = .init(x: x, y: y)
        }
    }
    
    private func initiateCarSequence() {
        self.removeAction(forKey: Actions.addCar.rawValue)
        let addCarQueue = DispatchQueue(
            label: "com.atillaozder.DriveFast.addCar.concurrentQueue",
            qos: .default, attributes: .concurrent)
        
        let addCarSq: SKAction = .sequence([
            .wait(forDuration: waitingDuration),
            .run(self.addRandomCar, queue: addCarQueue)
        ])
        
        let action: SKAction = .repeatForever(addCarSq)
        self.run(action, withKey: Actions.addCar.rawValue)
    }
    
    private func setGameDifficulty() {
        if appearanceDuration > appearanceThreshold
            || waitingDuration > waitingThreshold {
            appearanceDuration = max(appearanceThreshold, appearanceDuration - 0.5)
            waitingDuration = max(waitingThreshold, waitingDuration - 0.1)
            initiateCarSequence()
        }
    }
    
    private func clearGame() {
        stopMotionManager()
        self.removeAllActions()
        self.removeAllChildren()
        resetPlayerPosition()
    }
    
    // MARK: - RepeatForever Actions
    private func addRoadLine() {
        let height = roadLineNode.size.height + 20
        let posY: CGFloat = self.frame.maxY + height
        
        var actions = [SKAction]()
        actions.append(.moveTo(y: -height, duration: 0.5))
        actions.append(.removeFromParent())
        
        var posX = self.roadNode.frame.minX
        for _ in 1..<Int(Car.scaleRatio) {
            guard let node = self.roadLineNode.copy() as? SKSpriteNode else { return }
            
            posX += (frame.width / Car.scaleRatio)
            node.position = .init(x: posX, y: posY)
            
            DispatchQueue.main.async {
                self.addChild(node)
                node.run(.sequence(actions))
            }
        }
    }
        
    private func addRandomCar() {
        let addCarClosure: () -> Void = { [weak self] in
            guard let `self` = self else { return }
            
            var cars = GameManager.shared.cars
            cars.shuffle()
            
            let randomCar = cars[0]
            let obj = GameManager.shared.getObjRepresentation(of: randomCar)
            let car = randomCar.copy() as! SKSpriteNode
            if car.physicsBody == nil {
                #if DEBUG
                // Debug mode is on, continue
                #else
                // Physics body is empty, if game is started dont add car to screen
                if self.gameStarted {
                    return
                }
                #endif
            }
            
            car.setScale(to: self.frame.width / obj.ratio)
            car.position = CGPoint(
                x: self.getRandomPosX(), y: self.frame.maxY + car.size.height)
            
            let move = SKAction.moveTo(y: -car.size.height / 2, duration: self.appearanceDuration)
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
                car.run(.sequence(actions))
                self.addChild(car)
            }
        }
        
        addCarClosure()
        if UIDevice.current.isPad {
            addCarClosure()
        }
    }
    
    private func setFuel() {
        let newValue = remainingFuel - 1
        remainingFuel = max(0, newValue)
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
    
        addSprite(coin)
    }
        
    private func addFuel() {
        let sprite = self.fuel.copy() as! Fuel
        addSprite(sprite)
    }
    
    private func addSprite(_ sprite: SKSpriteNode) {
        sprite.position.x = getRandomPosX()
        var actions = [SKAction]()
        actions.append(.moveTo(y: -sprite.size.height / 2, duration: appearanceDuration))
        actions.append(.removeFromParent())
        
        DispatchQueue.main.async {
            self.addChild(sprite)
            sprite.run(.sequence(actions))
        }
    }
}
