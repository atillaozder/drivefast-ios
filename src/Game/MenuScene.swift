//
//  MenuScene.swift
//  Retro
//
//  Created by Atilla Özder on 11.10.2019.
//  Copyright © 2019 Atilla Özder. All rights reserved.
//

import SpriteKit
import GameplayKit

// MARK: - MenuScene
class MenuScene: GameScene {
    
    override var gameStarted: Bool {
        return false
    }
    
    override func didMove(to view: SKView) {
        super.didMove(to: view)
        DispatchQueue.global().async {
            self.movePlayerToMiddle()
        }
    }
            
    override func initiateGame() {
        return
    }
    
    override func didBegin(_ contact: SKPhysicsContact) {
        return
    }
}
