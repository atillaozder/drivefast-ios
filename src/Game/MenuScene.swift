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
        addNewGameButton()

        let defaults = UserDefaults.standard
        
        let score = defaults.integer(forKey: "score")
        let scorePosY = frame.midY - 128
        if score > 0 {
            let scoreLabel = SKLabelNode(fontNamed: fontName)
            scoreLabel.fontSize = 32
            scoreLabel.position = CGPoint(x: frame.midX, y: scorePosY)
            scoreLabel.text = "Score: \(score)"
            scoreLabel.zPosition = 999
            addChild(scoreLabel)
            defaults.set(nil, forKey: "score")
        }
        
        let bestScore = defaults.integer(forKey: "best_score")
        if bestScore > 0 {
            let bestScoreLabel = SKLabelNode(fontNamed: fontName)
            bestScoreLabel.fontSize = 32
            bestScoreLabel.position = CGPoint(x: frame.midX, y: scorePosY - 48)
            bestScoreLabel.text = "Best: \(bestScore)"
            bestScoreLabel.zPosition = 999
            addChild(bestScoreLabel)
        }
    }
    
    override func addPlayer() {}
    
    override func addLives() {}
    
    override func addGameScore() {}
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            
            let location = touch.location(in: self)
            let node = self.atPoint(location)
            
            if node.name == "new_game_button"
                || node.name == "new_game_label" {
                let gameScene = GameScene(size: self.size)
                gameScene.safeAreaInsets = safeAreaInsets
                gameScene.sceneDelegate = sceneDelegate
                gameScene.scaleMode = .aspectFit
                self.view?.presentScene(gameScene)
            }
        }
    }
    
    func addNewGameButton() {
        let btn = SKShapeNode(rectOf: .init(width: 200, height: 50), cornerRadius: 10)
        btn.fillColor = .dark
        btn.strokeColor = .white
        btn.position = .init(x: frame.midX, y: frame.midY)
        btn.name = "new_game_button"
        btn.zPosition = 998
        addChild(btn)
        
        let lbl = SKLabelNode(fontNamed: fontName)
        lbl.fontSize = 24
        lbl.position = .init(x: frame.midX, y: frame.midY - 8)
        lbl.name = "new_game_label"
        lbl.zPosition = 999
        lbl.text = "New Game"
        addChild(lbl)
    }
}
