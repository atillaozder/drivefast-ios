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
        setupNewGameButton()
        setupScores()
    }
            
    private func setupScores() {
        var posY = frame.midY - 36
        if UIDevice.current.isPad {
            posY -= 24
        }
        
        let score = UserDefaults.standard.getScore()
        if score > 0 {
            let scoreLabel = SKViewFactory().buildScoreLabel(in: frame)
            scoreLabel.position.y = posY
            scoreLabel.text = MainStrings.score.localized + ": \(score)"
            addChild(scoreLabel)
            posY -= 36
            
            if UIDevice.current.isPad {
                posY -= 16
            }
        }
        
        let bestScore = UserDefaults.standard.getBestScore()
        if bestScore > 0 {
            let bestScoreLabel = SKViewFactory().buildScoreLabel(in: frame)
            bestScoreLabel.position.y = posY
            bestScoreLabel.text = MainStrings.best.localized + ": \(bestScore)"
            addChild(bestScoreLabel)
        }
    }
    
    override func startGame() {
        return
    }
    
    override func handleContact(_ contact: SKPhysicsContact) {
        return
    }
}
