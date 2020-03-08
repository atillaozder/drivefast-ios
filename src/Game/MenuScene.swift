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
        setupNewGameButton()
        setupScores()
    }
    
    override func startGame() {
        return
    }
    
    private func setupScores() {
        
        func buildLabel() -> SKLabelNode {
            let lbl = SKLabelNode(fontNamed: SKViewFactory.fontName)
            lbl.fontSize = 32
            lbl.position = CGPoint(x: frame.midX, y: 0)
            lbl.zPosition = 999
            return lbl
        }
        
        var posY = frame.midY - 96
        let score = UserDefaults.standard.getScore()
        if score > 0 {
            let scoreLabel = buildLabel()
            scoreLabel.position.y = posY
            scoreLabel.text = "Score: \(score)"
            addChild(scoreLabel)
            posY -= 48
        }
        
        let bestScore = UserDefaults.standard.getBestScore()
        if bestScore > 0 {
            let bestScoreLabel = buildLabel()
            bestScoreLabel.position.y = posY
            bestScoreLabel.text = "Best: \(bestScore)"
            addChild(bestScoreLabel)
        }
    }
}
