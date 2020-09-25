//
//  UserDefaults+Extensions.swift
//  DriveFast
//
//  Created by Atilla Özder on 25.09.2020.
//  Copyright © 2020 Atilla Özder. All rights reserved.
//

import Foundation

// MARK: - UserDefaults

extension UserDefaults {
    
    var shouldRequestGCAuthentication: Bool {
        integer(forKey: Globals.Keys.kGCRequestAuthentication.rawValue) == 0
    }
    
    var score: Int {
        integer(forKey: Globals.Keys.kScore.rawValue)
    }
    
    var highscore: Int {
        integer(forKey: Globals.Keys.kHighscore.rawValue)
    }
    
    var session: Double {
        double(forKey: Globals.Keys.kSession.rawValue)
    }
    
    var isSoundOn: Bool {
        integer(forKey: Globals.Keys.kSoundPreference.rawValue) == 0
    }
    
    var playerCar: Car { Car(index: playerCarNo) }
    
    var playerCarNo: Int {
        integer(forKey: Globals.Keys.kPlayersCar.rawValue)
    }
    
    func setScore(_ score: Int) {
        set(score, forKey: Globals.Keys.kScore.rawValue)
        setHighscore(score)
    }
    
    func setHighscore(_ score: Int) {
        if score > highscore {
            GameManager.shared.submitNewScore(score)
            set(score, forKey: Globals.Keys.kHighscore.rawValue)
        }
    }
    
    func setSession(_ newValue: Double? = nil) {
        let value = newValue ?? (session + 1.0)
        set(value, forKey: Globals.Keys.kSession.rawValue)
    }
        
    func setSound(_ sound: Bool) {
        set(!sound, forKey: Globals.Keys.kSoundPreference.rawValue)
    }
    
    func setPlayerCar(_ player: Car) {
        set(player.index, forKey: Globals.Keys.kPlayersCar.rawValue)
    }
    
    func setGCRequestAuthentication() {
        set(1, forKey: Globals.Keys.kGCRequestAuthentication.rawValue)
    }
}
