//
//  GameScene+SKPhysicsContactDelegate.swift
//  DriveFast
//
//  Created by Atilla Özder on 9.04.2020.
//  Copyright © 2020 Atilla Özder. All rights reserved.
//

import SpriteKit

// MARK: - SKPhysicsContactDelegate
extension GameScene: SKPhysicsContactDelegate {
    func didBegin(_ contact: SKPhysicsContact) {
        let isPlayer = contact.bodyA.category == .player
        let bodyA = isPlayer ? contact.bodyA : contact.bodyB
        let bodyB = isPlayer ? contact.bodyB : contact.bodyA
        
        switch (bodyA.category, bodyB.category) {
        case (.player, .car):
            if let car = bodyB.node {
                playerDidCollide(with: car)
            }
        case (.player, .fuel):
            if let fuel = bodyB.node as? Fuel {
                playerDidCollide(with: fuel)
            }
        case (.player, .coin):
            if let coin = bodyB.node as? Coin {
                playerDidCollide(with: coin)
            }
        case (.coin, .fuel), (.fuel, .coin):
            let coin: SKNode? = bodyA.node is Fuel ? bodyB.node : bodyA.node
            if let wrapped = coin {
                wrapped.removeFromParent()
            }
        case (.car, .car):
            if let car = bodyA.node {
                car.removeFromParent()
            }
        default:
            break
        }
    }
    
    fileprivate func playerDidCollide(with car: SKNode) {
        if lifeCount > 1 {
            gameHelper.playEffect(.horns, in: self)
        }
        
        car.removeFromParent()
        lifeCount = max(0, lifeCount - 1)
    }
    
    fileprivate func playerDidCollide(with coin: Coin) {
        gameHelper.playEffect(.coin, in: self)
        coin.removeFromParent()
        score += coin.value
    }
    
    fileprivate func playerDidCollide(with fuelNode: Fuel) {
        gameHelper.playEffect(.fuel, in: self)
        fuelNode.removeFromParent()
        let newValue = self.fuel + gameHelper.fuelValue
        self.fuel = min(newValue, 100)
    }
}

// MARK: - SKPhysicsBody
extension SKPhysicsBody {
    var category: Category {
        return Category(rawValue: categoryBitMask) ?? .none
    }
}
