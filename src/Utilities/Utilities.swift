//
//  Utilities.swift
//  Retro
//
//  Created by Atilla Özder on 9.04.2020.
//  Copyright © 2020 Atilla Özder. All rights reserved.
//

import UIKit
import SpriteKit

// MARK: - Effect
enum Effect {
    case coin, crash, horns, brake
}

// MARK: - SoundManager
struct SoundManager {
    let coin = SKAction.playSoundFileNamed("coin.wav", waitForCompletion: false)
    let crash = SKAction.playSoundFileNamed("crash.wav", waitForCompletion: false)
    let horns = SKAction.playSoundFileNamed("horns.mp3", waitForCompletion: false)
//    let brake = SKAction.playSoundFileNamed("brake.wav", waitForCompletion: false)
    
    func playEffect(_ effect: Effect, in scene: SKScene) {
        if UserDefaults.standard.isSoundOn {
            switch effect {
            case .coin:
                scene.run(coin)
            case .crash:
                scene.run(crash)
            case .horns:
                scene.run(horns)
            case .brake:
                break
//                scene.run(brake)
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
}

// MARK: - Category
enum Category: UInt32 {
    case coin = 0x100
    case car = 0x10
    case player = 0x1
    case none = 0x1000
}

// MARK: - MainStrings
enum MainStrings: String {
    case scoreTitle = "scoreTitle"
    case highscoreTitle = "highscoreTitle"
    case newGameTitle = "newGameTitle"
    case advButtonTitle = "advButtonTitle"
    case settingsTitle = "settingsTitle"
    case achievementsTitle = "achievementsTitle"
    case backToMenuTitle = "backToMenuTitle"
    case rateTitle = "rateTitle"
    case supportTitle = "supportTitle"
    case privacyTitle = "privacyTitle"
    case moreAppTitle = "moreAppTitle"
    case shareTitle = "shareTitle"
    case continueTitle = "continueTitle"
    
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
