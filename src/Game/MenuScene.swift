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
    
    override func didMove(to view: SKView) {
        super.didMove(to: view)
        let _ = playerNode.texture?.size()
    }
            
    override func startGame() {
        return
    }
    
    override func didBegin(_ contact: SKPhysicsContact) {
        return
    }
}
