//
//  GameScene+SKPhysicsContactDelegate.swift
//  Retro
//
//  Created by Atilla Özder on 9.04.2020.
//  Copyright © 2020 Atilla Özder. All rights reserved.
//

import SpriteKit

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
        
        let fCategory = fBody.categoryBitMask
        let sCategory = sBody.categoryBitMask
        
        if fCategory & Category.car.rawValue != 0 &&
            sCategory & Category.car.rawValue != 0 {
            if let car = fBody.node as? SKSpriteNode {
                car.removeFromParent()
            }
        }
        
        if fCategory & Category.player.rawValue != 0 &&
            sCategory & Category.car.rawValue != 0 {
            if let car = sBody.node as? SKSpriteNode {
                playerDidCollide(with: car)
            }
        }
        
        if fCategory & Category.player.rawValue != 0 &&
            sCategory & Category.coin.rawValue != 0 {
            if let coin = sBody.node as? Coin {
                playerDidCollide(with: coin)
            }
        }
    }
    
    fileprivate func playerDidCollide(with car: SKSpriteNode) {
        if lifeCount > 1 {
            soundManager.playEffect(.horns, in: self)
        }
        
        car.removeFromParent()
        lifeCount -= 1
    }
        
    fileprivate func playerDidCollide(with coin: Coin) {
        soundManager.playEffect(.coin, in: self)
        coin.removeFromParent()
        score += coin.value
    }
}
