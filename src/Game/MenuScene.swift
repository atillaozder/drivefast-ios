//
//  MenuScene.swift
//  CarRacing
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
        setupGameButton()
        setupScores()
    }
    
    override func setupGame() {
        return
    }
    
    private func setupScores() {
        let score = UserDefaults.standard.integer(forKey: Key.score.rawValue)
        
        if score > 0 {
            let posY = frame.midY - 48 - 48
            let scoreLabel = buildMenuLabel()
            scoreLabel.position.y = posY
            scoreLabel.text = "Score: \(score)"
            addChild(scoreLabel)
            
            UserDefaults.standard.set(nil, forKey: Key.score.rawValue)
            
            let bestScore = UserDefaults.standard.integer(forKey: Key.bestScore.rawValue)
            if bestScore > 0 {
                let bScoreLabel = buildMenuLabel()
                bScoreLabel.position.y = posY - 48
                bScoreLabel.text = "Best: \(bestScore)"
                addChild(bScoreLabel)
            }
        }
    }
    
    private func buildMenuLabel() -> SKLabelNode {
        let menuLabel = SKLabelNode(fontNamed: fontName)
        menuLabel.fontSize = 32
        menuLabel.position = CGPoint(x: frame.midX, y: 0)
        menuLabel.zPosition = 999
        return menuLabel
    }
}
