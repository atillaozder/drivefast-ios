//
//  Utilities.swift
//  DriveFast
//
//  Created by Atilla Özder on 9.04.2020.
//  Copyright © 2020 Atilla Özder. All rights reserved.
//

import UIKit
import SpriteKit

// MARK: - Effect
enum Effect {
    case coin, crash, horns, fuel
}

// MARK: - GameHelper
class GameHelper {
    
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
    
    let coinSound = SKAction.playSoundFileNamed("coin.wav", waitForCompletion: false)
    let fuelSound = SKAction.playSoundFileNamed("fuel.wav", waitForCompletion: false)
    let crashSound = SKAction.playSoundFileNamed("crash.wav", waitForCompletion: false)
    let hornSound = SKAction.playSoundFileNamed("horns.mp3", waitForCompletion: false)
            
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
                scene.run(coinSound)
            case .fuel:
                scene.run(fuelSound)
            case .crash:
                scene.run(crashSound)
            case .horns:
                scene.run(hornSound)
            }
        }
    }
}

// MARK: - RoadBoundingBox
struct RoadBoundingBox {
    var minY: CGFloat
    var minX: CGFloat
    var maxY: CGFloat
    var maxX: CGFloat
    
    var midX: CGFloat {
        return (maxX - minX) / 2
    }
}

// MARK: - Cars
enum Cars: String {
    case player = "player"
    case car = "car"
}

// MARK: - Actions
enum Actions: String {
    case addCar = "add_car"
    case movePlayer = "move_player"
    case addCoin = "add_coin"
    case addFuel = "add_fuel"
}

// MARK: - Category
enum Category: UInt32 {
    case fuel = 0x1000
    case coin = 0x100
    case car = 0x10
    case player = 0x1
    case none = 0x10000
}

// MARK: - GameOverReason
enum GameOverReason {
    case runningOutOfFuel
    case crash
}

// MARK: - MainStrings
enum MainStrings: String {
    case scoreTitle = "scoreTitle"
    case highscoreTitle = "highscoreTitle"
    case newGameTitle = "newGameTitle"
    case advButtonTitle = "advButtonTitle"
    case settingsTitle = "settingsTitle"
    case backToMenuTitle = "backToMenuTitle"
    case rateTitle = "rateTitle"
    case supportTitle = "supportTitle"
    case privacyTitle = "privacyTitle"
    case moreAppTitle = "moreAppTitle"
    case shareTitle = "shareTitle"
    case continueTitle = "continueTitle"
    case garageTitle = "garageTitle"
    case chooseTitle = "chooseTitle"
    case loadingTitle = "loadingTitle"
    case okTitle = "okTitle"
    case gcErrorMessage = "gcErrorMessage"
    case fuelAlert = "fuelAlert"
    
    var localized: String {
        return NSLocalizedString(self.rawValue, comment: "")
    }
}

// MARK: - URLNavigator
class URLNavigator {
    
    static let shared = URLNavigator()
    
    private init() {}
    
    @discardableResult
    func open(_ url: URL) -> Bool {
        let application = UIApplication.shared
        guard application.canOpenURL(url) else { return false }
        
        if #available(iOS 10.0, *) {
            application.open(url, options: [:], completionHandler: nil)
        } else {
            application.openURL(url)
        }
        
        return true
    }
    
    @discardableResult
    func open(_ urlString: String) -> Bool {
        guard let url = URL(string: urlString) else { return false }
        return open(url)
    }
}
