//
//  AchievementsView.swift
//  Retro
//
//  Created by Atilla Özder on 13.04.2020.
//  Copyright © 2020 Atilla Özder. All rights reserved.
//

import UIKit

class AchievementsView: View {
    
    override func setup() {
        let scoreText = MainStrings.scoreTitle.localized + ": \(UserDefaults.standard.score)"
        let scoreLabel = buildLabel(withText: scoreText)
        
        let bestText = MainStrings.bestScoreTitle.localized + ": \(UserDefaults.standard.bestScore)"
        let bestScoreLabel = buildLabel(withText: bestText)
        
        let labels = UIStackView(arrangedSubviews: [scoreLabel, bestScoreLabel])
        labels.spacing = 0
        labels.axis = .vertical
        labels.distribution = .fillEqually
        labels.alignment = .fill
        
        stackView.addArrangedSubview(labels)
        stackView.addArrangedSubview(backButton)
        self.isHidden = true
        super.setup()
    }
    
    private func buildLabel(withText text: String) -> UILabel {
        let lbl = UILabel()
        lbl.font = UIFont.buildFont()
        lbl.textColor = .white
        lbl.text = text
        lbl.textAlignment = .center
        return lbl
    }
}
