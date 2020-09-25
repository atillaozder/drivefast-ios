//
//  Category.swift
//  DriveFast
//
//  Created by Atilla Özder on 25.09.2020.
//  Copyright © 2020 Atilla Özder. All rights reserved.
//

import Foundation

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
