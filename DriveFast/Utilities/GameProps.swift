//
//  GameProps.swift
//  DriveFast
//
//  Created by Atilla Özder on 25.09.2020.
//  Copyright © 2020 Atilla Özder. All rights reserved.
//

import SpriteKit

// MARK: - GameProps

final class GameProps {
    
    // MARK: - Properties
    
    private(set) var spriteMoveDuration: TimeInterval = 3
    private var spriteMoveThreshold: TimeInterval = 1.5
    private(set) var carWaitForDuration: TimeInterval = 1
    private var carWaitForThreshold: TimeInterval = 0.5
    private(set) var fuelWaitForDuration: TimeInterval = 8
    private var fuelWaitForThreshold: TimeInterval = 3
    
    private(set) var fuelConsumption: Float = 1
    private var maxFuelConsumption: Float = 5
    
    var fuelValue: Float {
        return fuelConsumption * Float(fuelWaitForDuration) + 5
    }
    
    static let coinSound = SKAction.playSoundFileNamed("coin.wav", waitForCompletion: false)
    static let fuelSound = SKAction.playSoundFileNamed("fuel.wav", waitForCompletion: false)
    static let crashSound = SKAction.playSoundFileNamed("crash.wav", waitForCompletion: false)
    static let hornSound = SKAction.playSoundFileNamed("horns.mp3", waitForCompletion: false)
            
    // MARK: - Helpers
    
    func updateDifficulty() {
        spriteMoveDuration = max(spriteMoveThreshold, spriteMoveDuration - 0.5)
        carWaitForDuration = max(carWaitForThreshold, carWaitForDuration - 0.1)
        fuelWaitForDuration = max(fuelWaitForThreshold, fuelWaitForDuration - 2)
        fuelConsumption = min(maxFuelConsumption, fuelConsumption + 1)
    }
    
    func playEffect(_ effect: Effect, in scene: SKScene) {
        if UserDefaults.standard.isSoundOn {
            switch effect {
            case .coin:
                scene.run(GameProps.coinSound)
            case .fuel:
                scene.run(GameProps.fuelSound)
            case .crash:
                scene.run(GameProps.crashSound)
            case .horns:
                scene.run(GameProps.hornSound)
            }
        }
    }
}
