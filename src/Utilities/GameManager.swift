//
//  GameManager.swift
//  DriveFast
//
//  Created by Atilla Özder on 2.05.2020.
//  Copyright © 2020 Atilla Özder. All rights reserved.
//

import Foundation
import SpriteKit

class GameManager {
    
    static let shared = GameManager()

    private var _explosion: SKEmitterNode!
    var explosionEffect: SKEmitterNode {
        return _explosion.copy() as! SKEmitterNode
    }
    
    private var _cars: [SKSpriteNode] = []
    private var objRepresentation: [SKSpriteNode: Car] = [:]
    
    var cars: [SKSpriteNode] {
        return _cars
    }
    
    static let carCount: Int = 20
    var gameCount: Double = 0

    private init() {}
    
    func preloadCars(completionHandler: @escaping ((Int) -> ())) {
        DispatchQueue.global().async {
            for idx in 0...GameManager.carCount {
                let car = Car(index: idx)
                let spriteNode = self.buildSpriteNode(from: car)
                self._cars.append(spriteNode)
                DispatchQueue.main.async {
                    completionHandler(idx)
                }
            }
        }
    }
    
    func preloadExplosion() {
        self._explosion = SKEmitterNode(fileNamed: "Explosion")!
    }
    
    func getObjRepresentation(of sprite: SKSpriteNode) -> Car {
        return objRepresentation[sprite] ?? .init(index: 1)
    }
    
    func getDictElement(value: Car) -> Dictionary<SKSpriteNode, Car>.Element {
        return objRepresentation.first(where: { return $1 == value })!
    }
    
    private func buildSpriteNode(from car: Car) -> SKSpriteNode {
        let texture = SKTexture(imageNamed: car.imageName)
        let spriteNode = SKSpriteNode(texture: texture)
        spriteNode.name = Cars.car.rawValue
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
