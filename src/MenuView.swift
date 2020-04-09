//
//  MenuView.swift
//  Retro
//
//  Created by Atilla Özder on 9.04.2020.
//  Copyright © 2020 Atilla Özder. All rights reserved.
//

import UIKit

class MenuView: UIView {
    
    let newGameButton: UIButton = {
        let btn = UIButton()
        btn.setTitle(MainStrings.newGame.localized, for: .normal)
        btn.setTitleColor(.white, for: .normal)
        btn.titleLabel?.font = UIFont.defaultFont(ofSize: 24)
        btn.titleLabel?.textAlignment = .center
        btn.contentHorizontalAlignment = .center
        btn.backgroundColor = .systemTeal
        btn.layer.borderColor = UIColor.systemTeal.darker().cgColor
        btn.layer.borderWidth = 6
        btn.layer.cornerRadius = 25
        return btn
    }()
    
    lazy var scoreLabel: UILabel = {
        return buildLabel()
    }()
    
    lazy var bestScoreLabel: UILabel = {
        return buildLabel()
    }()
    
    lazy var advertisementButton: UIButton = {
        let btn = UIButton()
        btn.setTitle(MainStrings.advButtonTitle.localized, for: .normal)
        btn.setTitleColor(.white, for: .normal)
        btn.titleLabel?.font = UIFont.defaultFont(ofSize: 20)
        btn.titleLabel?.numberOfLines = 3
        btn.titleLabel?.minimumScaleFactor = 0.5
        btn.titleLabel?.adjustsFontSizeToFitWidth = true
        btn.titleLabel?.textAlignment = .center
        btn.contentHorizontalAlignment = .center
        btn.backgroundColor = .systemOrange
        btn.layer.borderColor = UIColor.systemOrange.darker().cgColor
        btn.layer.borderWidth = 6
        btn.layer.cornerRadius = 50
        btn.isHidden = true
        return btn
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupViews()
    }
    
    private func setupViews() {
        let btnWidth: CGFloat = 200
        let midX = (frame.width / 2) - (btnWidth / 2)
        let y = frame.midY - 50
        
        addSubview(newGameButton)
        newGameButton.frame = CGRect(
            x: midX, y: y, width: btnWidth, height: 50)
        
        let nextPosY = y + 32
        addSubview(advertisementButton)
        advertisementButton.frame = CGRect(
            x: midX, y: nextPosY + 34, width: btnWidth, height: 100)
        
        addSubview(scoreLabel)
        scoreLabel.frame = CGRect(
            x: midX, y: nextPosY, width: btnWidth, height: 100)

        addSubview(bestScoreLabel)
        bestScoreLabel.frame = CGRect(
            x: midX, y: nextPosY + 32, width: btnWidth, height: 100)
    }
    
    func setScores() {
        let score = UserDefaults.standard.getScore()
        scoreLabel.text = score > 0 ?
            MainStrings.score.localized + ": \(score)" : nil
        
        let best = UserDefaults.standard.getBestScore()
        bestScoreLabel.text = best > 0 ?
            MainStrings.best.localized + ": \(best)" : nil
    }
    
    func setAdvertisementButtonHidden(_ isHidden: Bool) {
        self.isHidden = isHidden
        advertisementButton.isHidden = isHidden
        scoreLabel.isHidden = !isHidden
        bestScoreLabel.isHidden = !isHidden
    }
    
    private func buildLabel() -> UILabel {
        let lbl = UILabel()
        lbl.font = UIFont.defaultFont(ofSize: 24)
        lbl.textColor = .white
        lbl.textAlignment = .center
        return lbl
    }
}
