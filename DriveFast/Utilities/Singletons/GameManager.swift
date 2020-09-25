//
//  GameManager.swift
//  DriveFast
//
//  Created by Atilla Özder on 2.05.2020.
//  Copyright © 2020 Atilla Özder. All rights reserved.
//

import Foundation
import SpriteKit
import GameKit

// MARK: - GameManager

final class GameManager: NSObject {
    
    // MARK: - Properties
    
    static let shared = GameManager()
    
    private var _explosion: SKEmitterNode!
    var explosionEffect: SKEmitterNode {
        return _explosion.copy() as! SKEmitterNode
    }
    
    private(set) var cars: [SKSpriteNode] = []
    private(set) var objRepresentation: [SKSpriteNode: Car] = [:]
    
    static let carCount: Int = 20
    
    var gameCount: Double = 0
    private(set) var gcEnabled = Bool()
    private(set) var gcDefaultLeaderBoard = String()
    
    private let workCount: Double = 21
    private var unitWorkValue: Double {
        return 1 / workCount
    }
    
    private var progressValue: Double = 0 {
        didSet {
            DispatchQueue.main.async {
                if let loadingProgress = self.progress {
                    loadingProgress(Float(self.progressValue))
                }
            }
        }
    }
    
    var progress: ((Float) -> ())?
    
    // MARK: - Private Constructor
    
    private override init() {
        super.init()
    }
    
    // MARK: - Helper Methods
    
    func startLoading() {
        DispatchQueue.global().async {
            self._explosion = SKEmitterNode(fileNamed: "Explosion")!
            self.preloadCars()
        }
    }
    
    func getObjRepresentation(of sprite: SKSpriteNode) -> Car {
        return objRepresentation[sprite] ?? .init(index: 1)
    }
    
    func getDictElement(value: Car) -> Dictionary<SKSpriteNode, Car>.Element {
        return objRepresentation.first(where: { return $1 == value })!
    }
    
    func submitNewScore(_ score: Int) {
        if gcEnabled {
            let highscore = GKScore(leaderboardIdentifier: Globals.leaderboardID)
            highscore.value = Int64(score)
                        
            GKScore.report([highscore]) { (error) in
                if let err = error {
                    print(err.localizedDescription)
                }
            }
        }
    }
    
    func authenticatePlayer(presentingViewController: UIViewController) {
        let defaults = UserDefaults.standard
        if defaults.shouldRequestGCAuthentication {
            let localPlayer = GKLocalPlayer.local
            localPlayer.authenticateHandler = { [weak self] (viewController, error) in
                guard let self = self else { return }
                if viewController != nil {
                    presentingViewController.present(viewController!, animated: true, completion: nil)
                    defaults.setGCRequestAuthentication()
                } else if localPlayer.isAuthenticated {
                    self.gcEnabled = true
                    defaults.setGCRequestAuthentication()
                } else {
                    self.gcEnabled = false
                    if let err = error {
                        print(err.localizedDescription)
                    }
                }
                self.progressValue += self.unitWorkValue
            }
        } else {
            self.progressValue += self.unitWorkValue
        }
    }
    
    // MARK: - Private Helper Methods
    
    private func preloadCars() {
        for idx in 0...GameManager.carCount {
            let car = Car(index: idx)
            let spriteNode = self.buildSpriteNode(from: car)
            self.cars.append(spriteNode)
            self.progressValue += self.unitWorkValue
        }
    }
        
    private func buildSpriteNode(from car: Car) -> SKSpriteNode {
        let texture = SKTexture(imageNamed: car.imageName)
        let spriteNode = SKSpriteNode(texture: texture)
        spriteNode.name = Globals.Keys.kCar.rawValue
        spriteNode.zPosition = 1

        if !setSpritePhysicsBody(spriteNode, from: texture) {
            let node = SKShapeNode()
            node.fillTexture = SKTexture(imageNamed: car.imageName)
            setSpritePhysicsBody(spriteNode, from: node.fillTexture)
        }

        objRepresentation[spriteNode] = car
        return spriteNode
    }
    
    @discardableResult
    private func setSpritePhysicsBody(_ sprite: SKSpriteNode, from texture: SKTexture?) -> Bool {
        if sprite.physicsBody != nil {
            return true
        }
        
        guard let texture = texture else { return false }
        let physicsBody = SKPhysicsBody(texture: texture, size: texture.size())
        physicsBody.isDynamic = true
        physicsBody.categoryBitMask = Category.car.rawValue
        physicsBody.contactTestBitMask = Category.player.rawValue | Category.car.rawValue
        physicsBody.collisionBitMask = 0
        
        sprite.physicsBody = physicsBody
        return physicsBody.area != 0.0
    }
}
