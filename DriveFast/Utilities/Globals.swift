//
//  Globals.swift
//  DriveFast
//
//  Created by Atilla Özder on 9.04.2020.
//  Copyright © 2020 Atilla Özder. All rights reserved.
//

import UIKit
import SpriteKit

// MARK: - Globals

struct Globals {
    
    // MARK: - Tags
    
    enum Tags: Int {
        case toast = 1000
    }
    
    // MARK: - Keys
    
    enum Keys: String {
        case kScore = "score"
        case kSession = "session"
        case kSoundPreference = "sound_preference"
        case kPlayersCar = "players_car"
        case kHighscore = "best_score"
        case kPlayer = "player"
        case kCar = "car"
        case kAddCar = "add_car"
        case kMovePlayer = "move_player"
        case kAddCoin = "add_coin"
        case kAddFuel = "add_fuel"
        case kGCRequestAuthentication = "kGCRequestAuthentication"
    }
    
    static var borderWidth: CGFloat { 2 }
    static var appID: String { "1483121139" }
    static var bundleID: String { "com.atillaozder.DriveFast" }
    static var leaderboardID: String { "\(bundleID).Leaderboard" }
    
    private static var viewControllerState: RootViewControllerType { .splash }

    private enum RootViewControllerType {
        case splash, game
    }
    
    static var rootViewController: UIViewController {
        #if DEBUG
        switch viewControllerState {
        case .splash:
            return SplashViewController()
        case .game:
            return GameViewController()
        }
        #else
        return SplashViewController()
        #endif
    }
}
