//
//  Utilities.swift
//  Retro
//
//  Created by Atilla Özder on 9.04.2020.
//  Copyright © 2020 Atilla Özder. All rights reserved.
//

import UIKit
import SpriteKit

// MARK: - Sound
struct Sound {
    let coinFlip = SKAction.playSoundFileNamed("coin.wav", waitForCompletion: false)
    let crash = SKAction.playSoundFileNamed("crash.wav", waitForCompletion: false)
    let horns = SKAction.playSoundFileNamed("horns.mp3", waitForCompletion: false)
    let brake = SKAction.playSoundFileNamed("brake.wav", waitForCompletion: false)
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
}

// MARK: - MainStrings
enum MainStrings: String {
    case score = "score"
    case best = "bestScore"
    case newGame = "newGame"
    case advButtonTitle = "advButtonTitle"
    
    var localized: String {
        return NSLocalizedString(self.rawValue, comment: "")
    }
}
