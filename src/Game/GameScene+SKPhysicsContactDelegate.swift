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
        
        if (fBody.categoryBitMask & Category.player.rawValue) != 0
            && (sBody.categoryBitMask & Category.car.rawValue) != 0 {
            if let car = sBody.node as? SKSpriteNode {
                playerDidCollide(withCar: car)
            }
        }
        
        if (fBody.categoryBitMask & Category.player.rawValue) != 0
            && (sBody.categoryBitMask & Category.coin.rawValue) != 0 {
            if let coin = sBody.node as? Coin {
                playerDidCollide(withCoin: coin)
            }
        }
    }
    
    fileprivate func playerDidCollide(withCar car: SKSpriteNode) {
        if remainingLives.count > 1 {
            soundManager.playEffect(.horns, in: self)
        }
        
        car.removeFromParent()
        
        if let live = remainingLives.last {
            live.removeFromParent()
            remainingLives.removeLast()
        }
        
        if remainingLives.isEmpty {
            finishGame()
        }
    }
        
    fileprivate func playerDidCollide(withCoin coin: Coin) {
        soundManager.playEffect(.coin, in: self)
        coin.removeFromParent()
        score += coin.value
    }
}
