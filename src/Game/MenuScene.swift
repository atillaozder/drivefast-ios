//
//  MenuScene.swift
//  CarRacing
//
//  Created by Atilla Özder on 11.10.2019.
//  Copyright © 2019 Atilla Özder. All rights reserved.
//

import SpriteKit
import GameplayKit

class MenuScene: GameScene {
        
    override func didMove(to view: SKView) {
        super.didMove(to: view)
        setupNewGameButton()
        setupScores()
    }
        
    override func setupGame() {
        return
    }
        
    private func setupScores() {
        let defaults = UserDefaults.standard
        
        let score = defaults.integer(forKey: Key.score.rawValue)
        var scorePosY = frame.midY - 48
        if score > 0 {
            scorePosY -= 48
            let scoreLabel = SKLabelNode(fontNamed: fontName)
            scoreLabel.fontSize = 32
            scoreLabel.position = CGPoint(x: frame.midX, y: scorePosY)
            scoreLabel.text = "Score: \(score)"
            scoreLabel.zPosition = 999
            addChild(scoreLabel)
            defaults.set(nil, forKey: Key.score.rawValue)
            
            let bestScore = defaults.integer(forKey: Key.bestScore.rawValue)
            if bestScore > 0 {
                let bestScoreLabel = SKLabelNode(fontNamed: fontName)
                bestScoreLabel.fontSize = 32
                bestScoreLabel.position = CGPoint(x: frame.midX, y: scorePosY - 48)
                bestScoreLabel.text = "Best: \(bestScore)"
                bestScoreLabel.zPosition = 999
                addChild(bestScoreLabel)
            }
        }
    }
}
