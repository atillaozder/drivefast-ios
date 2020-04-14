//
//  AchievementsMenu.swift
//  Retro
//
//  Created by Atilla Özder on 13.04.2020.
//  Copyright © 2020 Atilla Özder. All rights reserved.
//

import UIKit

class AchievementsMenu: Menu {
    
    weak var delegate: MenuDelegate?
    
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
        
        backButton.addTarget(self, action: #selector(didTapBack(_:)), for: .touchUpInside)
        stackView.addArrangedSubview(backButton)
        self.isHidden = true
        super.setup()
    }
    
    @objc
    func didTapBack(_ sender: UIButton) {
        delegate?.menu(self, didUpdateGameState: .home)
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
