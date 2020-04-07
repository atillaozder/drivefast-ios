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

// MARK: - SceneDelegate
protocol SceneDelegate: class {
    func scene(_ scene: GameScene, didFinishGameWithScore score: Int)
    func scene(_ scene: GameScene, shouldPresentRewardBasedVideoAd present: Bool)
    func scene(_ scene: GameScene, shouldPresentMenuScene present: Bool)
}

// MARK: - GameScene
class GameScene: SKScene {
    
    // MARK: - Variables
    enum Cars: String {
        case player = "player"
        case car = "car"
    }
    
    enum Actions: String {
        case addCar = "add_car"
        case movePlayer = "move_player"
    }
    
    private let motionManager = CMMotionManager()
    weak var sceneDelegate: SceneDelegate?
    
    var scaleRatio: CGFloat {
        return UIDevice.current.isPad ? 5 : 3
    }
    
    lazy var playerNode: SKSpriteNode = {
        let carName = "car1"
        let texture = SKTexture(imageNamed: carName)
        let _ = texture.size()
        
        let car = SKSpriteNode(texture: texture)
        let posY = (car.size.height / 2) + 20 + insets.bottom
        car.position = CGPoint(x: frame.width / 2, y: posY)
        car.zPosition = 1
        car.name = Cars.player.rawValue
        
        if !setCarPhysicsBody(car, from: texture) {
            let shapeNode = SKShapeNode()
            shapeNode.fillTexture = SKTexture(imageNamed: carName)
            setCarPhysicsBody(car, from: shapeNode.fillTexture)
        }

        car.physicsBody?.isDynamic = true
        car.physicsBody?.categoryBitMask = Category.player.rawValue
        car.physicsBody?.contactTestBitMask = Category.car.rawValue
        car.setScale(to: frame.width / scaleRatio)

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
    
    lazy var roadLineNode: SKSpriteNode = {
        let node = SKSpriteNode(imageNamed: "road-line")
        node.zPosition = -1
        node.size = .init(width: 6, height: 30)
        return node
    }()
    
    lazy var scoreLabel: SKLabelNode = {
        let lbl = SKLabelNode(text: MainStrings.score.localized + ": 0")
        lbl.fontName = SKViewFactory.fontName
        lbl.fontSize = UIDevice.current.isPad ? 36 : 28
        lbl.fontColor = UIColor.white
        lbl.zPosition = 2
        let y = frame.size.height - 40 - insets.top
        lbl.position = UIDevice.current.isPad ? CGPoint(x: 90, y: y - 12) : CGPoint(x: 70, y: y)
        return lbl
    }()
    
    lazy var singleCoin: SKSpriteNode = {
        return SKViewFactory().buildCoin(rect: self.frame, type: .single)
    }()
    
    lazy var multipleCoins: SKSpriteNode = {
        return SKViewFactory().buildCoin(rect: self.frame, type: .multiple)
    }()
    
    lazy var coinBag: SKSpriteNode = {
        return SKViewFactory().buildCoin(rect: self.frame, type: .bag)
    }()
    
    var score: Int = 0 {
        didSet {
            scoreLabel.text = MainStrings.score.localized + ": \(score)"
        }
    }
        
    let explosionNode: SKEmitterNode = {
        return SKEmitterNode(fileNamed: "Explosion")!
    }()
    
    let coinSound = SKAction.playSoundFileNamed("coin.wav", waitForCompletion: false)
    let explosionSound = SKAction.playSoundFileNamed("explosion.wav", waitForCompletion: false)

    /// safe area insets of the game view controller
    lazy var insets: UIEdgeInsets = .zero
    lazy var videoWasPresented: Bool = false
    lazy var gameOver: Bool = false

    private var remainingLives: [SKSpriteNode] = []
    private var cachedCars = [String: SKPhysicsBody]()
    
    private let addRoadLineQueue: DispatchQueue = {
        return DispatchQueue(label: "com.retro2d.ios.serial.addRoadLine",
                             qos: .userInteractive,
                             attributes: .concurrent)
    }()
    
    private let addCarQueue: DispatchQueue = {
        return DispatchQueue(label: "com.retro2d.ios.serial.addCar",
                             qos: .userInteractive,
                             attributes: .concurrent)
    }()
    
    private let addCoinQueue: DispatchQueue = {
        return DispatchQueue(label: "com.retro2d.ios.serial.addCoin",
                             qos: .userInteractive,
                             attributes: .concurrent)
    }()

    // MARK: - Game Life Cycle
    override func didMove(to view: SKView) {
        super.didMove(to: view)
        startGame()
        
        self.addChild(roadNode)
        self.physicsWorld.gravity = CGVector(dx: 0, dy: 0)
        self.physicsWorld.contactDelegate = self

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            let addRoadLineSq: SKAction = .sequence([
                .wait(forDuration: 0.05),
                .run(self.addRoadLine, queue: self.addRoadLineQueue)
            ])
            self.run(.repeatForever(addRoadLineSq))
            
            let addCarSq: SKAction = .sequence([
                .wait(forDuration: 1),
                .run(self.addRandomCar, queue: self.addCarQueue)
            ])
            self.run(.repeatForever(addCarSq), withKey: Actions.addCar.rawValue)
        }
    }
    
    func startGame() {
        gameCount += 1
        addChild(playerNode)

        score = 0
        addChild(scoreLabel)

        setupLives(count: 3)
        setupMotionManager()

        let addCoinSq: SKAction = .sequence([
            .wait(forDuration: 5),
            .run(addCoin, queue: addCoinQueue)
        ])

        run(.repeatForever(addCoinSq))
    }
    
    func continueGame() {
        addChild(playerNode)
        
        self.setupLives(count: 1)
        self.gameOver = false
        self.isPaused = false
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            self.action(forKey: Actions.addCar.rawValue)?.speed = 1
        }
    }
    
    func stopGame() {
        self.sceneDelegate?.scene(self, didFinishGameWithScore: score)
        
        if !videoWasPresented {
            self.isPaused = true
            self.action(forKey: Actions.addCar.rawValue)?.speed = 0
            setupNewGameButton()
            
            let btn = SKViewFactory().buildAdvertisementButton(in: frame)
            addChild(btn)
        } else {
            self.sceneDelegate?.scene(self, shouldPresentMenuScene: true)
        }
    }
    
    // MARK: - View Initialization
    private func setupLives(count: Int) {
        let size = UIDevice.current.isPad ? CGSize(width: 80, height: 100) : CGSize(width: 50, height: 62.5)
        var posX = frame.maxX - (size.width / 2) - 6
        let posY = frame.maxY - insets.top - (size.height / 2) - 16
        for _ in 0..<count {
            let texture = SKTexture(imageNamed: "car1")
            let node = SKSpriteNode(texture: texture)
            node.size = size
            node.position = CGPoint(x: posX, y: posY)
            node.zPosition = 2
            node.aspectFill(to: size)
            
            let body = SKPhysicsBody(texture: texture, size: size)
            body.collisionBitMask = 0
            node.physicsBody = body
            
            remainingLives.append(node)
            addChild(node)
            posX -= ((size.width / 2) + 6)
        }
    }
    
    private func getRoadFrame() -> (minX: CGFloat, maxX: CGFloat, minY: CGFloat, maxY: CGFloat) {
        let playerNodeWidth = playerNode.texture?.size().width ?? playerNode.size.width
        let playerNodeInnerPadding: CGFloat = 10
        
        let w = CGFloat(Int(playerNodeWidth / scaleRatio)) / 2
        let h = (playerNode.size.height / 2)
        
        let minX = self.frame.minX + w + playerNodeInnerPadding
        let maxX = self.frame.maxX - w
        let minY = self.frame.minY + h
        let maxY = self.frame.maxY - h
        
        return (minX: minX, maxX: maxX, minY: minY, maxY: maxY)
    }
        
    private func setupMotionManager() {
        let queue = OperationQueue.current ?? .main
        motionManager.accelerometerUpdateInterval = 0.01
        motionManager.startAccelerometerUpdates(to: queue) { [weak self] (data, error) in
            guard let strongSelf = self, let data = data else { return }

            let player = strongSelf.playerNode
            let position = player.position
            var x = position.x + CGFloat(data.acceleration.x * 10)
            var y = position.y + CGFloat(data.acceleration.y * 10)

            let roadFrame = strongSelf.getRoadFrame()
            x = max(x, roadFrame.minX)
            x = min(x, roadFrame.maxX)
            y = max(y, roadFrame.minY)
            y = min(y, roadFrame.maxY)
            
//            let movePlayer = Actions.movePlayer.rawValue
//            player.removeAction(forKey: movePlayer)
//            let moveAction = SKAction.move(to: .init(x: x, y: y), duration: 0)
//            player.run(moveAction, withKey: movePlayer)
            player.position = .init(x: x, y: y)
        }
    }
    
    func setupNewGameButton() {
        let btn = SKViewFactory().buildNewGameButton(in: frame)
        addChild(btn)
    }
    
    @discardableResult
    private func setCarPhysicsBody(_ car: SKSpriteNode, from texture: SKTexture?) -> Bool {
        if car.physicsBody != nil {
            return true
        }
        
        guard let texture = texture else { return false }
        let body = SKPhysicsBody(texture: texture, size: texture.size())
        body.isDynamic = false
        body.categoryBitMask = Category.car.rawValue
        body.contactTestBitMask = Category.player.rawValue
        body.collisionBitMask = 0
        
        car.physicsBody = body
        return body.area != 0.0
    }
    
    // MARK: - Touch Handlers
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            let location = touch.location(in: self)
            
            if let nodeName = self.atPoint(location).name {
                switch nodeName {
                case ViewKey.newGame.rawValue:
                    didTapNewGame()
                case ViewKey.advertisement.rawValue:
                    playVideo()
                default:
                    break
                }
            }
        }
    }
    
    private func didTapNewGame() {
        let scene = GameScene(size: self.size)
        scene.insets = insets
        scene.sceneDelegate = sceneDelegate
        scene.cachedCars = cachedCars
        
        if playerNode.physicsBody != nil {
            scene.playerNode = playerNode
        }
        
        scene.scaleMode = .aspectFit
        self.view?.presentScene(scene)
    }
    
    private func playVideo() {
        self.videoWasPresented = true
        self.sceneDelegate?.scene(self, shouldPresentRewardBasedVideoAd: true)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.childNode(withName: ViewKey.newGame.rawValue)?.removeFromParent()
            self.childNode(withName: ViewKey.advertisement.rawValue)?.removeFromParent()

            self.enumerateChildNodes(withName: Cars.car.rawValue) { (node, ptr) in
                node.removeFromParent()
            }
        }
    }
        
    // MARK: - RepeatForever Actions
    private func addRoadLine() {
        let size: CGSize = .init(width: 8, height: 50)
        let posY: CGFloat = self.frame.maxY + size.height
        
        var actions = [SKAction]()
        actions.append(.moveTo(
            y: -size.height,
            duration: UIDevice.current.userInterfaceIdiom == .pad ? 1 : 0.5))
        actions.append(.removeFromParent())
        
        var posX = self.roadNode.frame.minX
        for _ in 1..<Int(scaleRatio) {
            if let line = self.roadLineNode.copy() as? SKSpriteNode {
                posX += (frame.width / scaleRatio)
                line.position = .init(x: posX, y: posY)
                DispatchQueue.main.async { [weak self] in
                    guard let strongSelf = self else { return }
                    strongSelf.addChild(line)
                    line.run(.sequence(actions))
                }
            }
        }
    }
    
    private func addRandomCar() {
        var cars = ["car2", "car3", "car4", "car5", "car6", "car7", "car8", "car9"]
        cars.shuffle()
        
        let carName = cars[0]
        let texture = SKTexture(imageNamed: carName)
        let _ = texture.size()
        
        let roadMinX = Int(self.frame.minX + 30)
        let roadMaxX = Int(self.frame.maxX - 30)
        
        var randomPos: Int = Int.random(in: roadMinX..<roadMaxX)
        if #available(iOS 9.0, *) {
            let randomDist = GKRandomDistribution(lowestValue: roadMinX, highestValue: roadMaxX)
            randomPos = randomDist.nextInt()
        }
        
        let car = SKSpriteNode(texture: texture)
        car.position = CGPoint(x: CGFloat(randomPos), y: frame.maxY + car.size.height)
        car.name = Cars.car.rawValue
        car.zPosition = 1
                    
        if let body = cachedCars[carName] {
            car.physicsBody = (body.copy() as! SKPhysicsBody)
        } else {
            if !setCarPhysicsBody(car, from: texture) {
                let shapeNode = SKShapeNode()
                shapeNode.fillTexture = SKTexture(imageNamed: carName)
                setCarPhysicsBody(car, from: shapeNode.fillTexture)
            }
            
            if car.physicsBody != nil {
                cachedCars[carName] = car.physicsBody
            } else {
                // Physics body is empty, if game is active dont add car to screen
                if !remainingLives.isEmpty {
                    return
                }
            }
        }
        
        car.setScale(to: frame.width / scaleRatio)
        
        var actions = [SKAction]()
        actions.append(.moveTo(
            y: -car.size.height / 2,
            duration: 3))

        let increaseScore = SKAction.run {
            if !self.gameOver {
                self.score += 1
            }
        }

        actions.append(increaseScore)
        actions.append(.removeFromParent())
        
        DispatchQueue.main.async {
            self.addChild(car)
            car.run(.sequence(actions))
        }
    }
    
    private func addCoin() {
        let random = Int.random(in: 0...10)
        var randomCoin: SKSpriteNode?
        
        if random >= 0 && random <= 5 {
            randomCoin = self.singleCoin.copy() as? SKSpriteNode
        } else if random > 5 && random <= 8 {
            randomCoin = self.multipleCoins.copy() as? SKSpriteNode
        } else {
            randomCoin = self.coinBag.copy() as? SKSpriteNode
        }
        
        if let coin = randomCoin {
            let roadMinX = Int(self.frame.minX + 30)
            let roadMaxX = Int(self.frame.maxX - 20)
            
            var randomPos: Int = Int.random(in: roadMinX..<roadMaxX)
            if #available(iOS 9.0, *) {
                let randomDist = GKRandomDistribution(lowestValue: roadMinX, highestValue: roadMaxX)
                randomPos = randomDist.nextInt()
            }
            
            coin.position.x = CGFloat(randomPos)
            
            let body = SKPhysicsBody(circleOfRadius: coin.size.width / 2)
            body.isDynamic = false
            body.categoryBitMask = Category.coin.rawValue
            body.contactTestBitMask = Category.player.rawValue
            body.collisionBitMask = 0
            coin.physicsBody = body
            
            var actions = [SKAction]()
            actions.append(.moveTo(
                y: -coin.size.height / 2,
                duration: 3))
            
            actions.append(.removeFromParent())
            
            DispatchQueue.main.async {
                self.addChild(coin)
                coin.run(.sequence(actions))
            }
        }
    }
    
    func handleContact(_ contact: SKPhysicsContact) {
        var fBody: SKPhysicsBody
        var sBody: SKPhysicsBody
        
        if contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask {
            fBody = contact.bodyA
            sBody = contact.bodyB
        } else {
            fBody = contact.bodyB
            sBody = contact.bodyA
        }
        
        if (fBody.categoryBitMask & Category.player.rawValue) != 0
            && (sBody.categoryBitMask & Category.car.rawValue) != 0 {
            if let car = sBody.node as? SKSpriteNode {
                playerDidCollide(withCar: car)
            }
        }
        
        if (fBody.categoryBitMask & Category.player.rawValue) != 0
            && (sBody.categoryBitMask & Category.coin.rawValue) != 0 {
            if let coin = sBody.node as? SKSpriteNode {
                playerDidCollide(withCoin: coin)
            }
        }
    }
}

// MARK: - SKPhysicsContactDelegate
extension GameScene: SKPhysicsContactDelegate {
    func didBegin(_ contact: SKPhysicsContact) {
        handleContact(contact)
    }
    
    fileprivate func playerDidCollide(withCar car: SKSpriteNode) {
        car.removeFromParent()
        
        if let live = remainingLives.last {
            live.removeFromParent()
            remainingLives.removeLast()
        }
        
        if remainingLives.isEmpty {
            endGame()
        }
    }
    
    fileprivate func endGame() {
        self.gameOver = true
        
        let explosion = self.explosionNode.copy() as! SKEmitterNode
        explosion.position = playerNode.position
        self.addChild(explosion)
        
        self.run(explosionSound)
        playerNode.removeFromParent()
        
        self.run(.wait(forDuration: 2)) { [weak self] in
            guard let strongSelf = self else { return }
            explosion.removeFromParent()
            strongSelf.stopGame()
        }
    }
    
    fileprivate func playerDidCollide(withCoin coin: SKSpriteNode) {
        self.run(coinSound)
        let name = coin.name
        coin.removeFromParent()
        
        if let id = name, let c = Coin(rawValue: id) {
            score += c.value
        }
    }
}
