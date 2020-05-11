//
//  HomeMenu.swift
//  DriveFast
//
//  Created by Atilla Özder on 9.04.2020.
//  Copyright © 2020 Atilla Özder. All rights reserved.
//

import UIKit

class HomeMenu: Menu {
    
    weak var delegate: MenuDelegate?
 
    override func setup() {
        let newGameButton = buildButton(withTitle: .newGameTitle)
        newGameButton.addTarget(self, action: #selector(didTapNewGame(_:)), for: .touchUpInside)
        stackView.addArrangedSubview(newGameButton)
        
        let garageButton = buildButton(withTitle: .garageTitle)
        garageButton.addTarget(self, action: #selector(didTapGarage(_:)), for: .touchUpInside)
        stackView.addArrangedSubview(garageButton)
        
        let settingsButton = buildButton(withTitle: .settingsTitle)
        settingsButton.addTarget(self, action: #selector(didTapSettings(_:)), for: .touchUpInside)
        stackView.addArrangedSubview(settingsButton)
        setupRowButtons()
        
        super.setup()
    }
    
    private func setupRowButtons() {
        func buildMuteButton(from rowButton: UIButton) -> UIButton {
            let btn = BackslashButton()
            let image = Asset.music.imageRepresentation()?.withRenderingMode(.alwaysTemplate)
            btn.setImage(image, for: .normal)
            btn.contentEdgeInsets = .zero
            btn.isUserInteractionEnabled = true
            btn.imageEdgeInsets = rowButton.imageEdgeInsets
            btn.backgroundColor = rowButton.backgroundColor
            btn.layer.borderColor = rowButton.layer.borderColor
            btn.layer.borderWidth = rowButton.layer.borderWidth
            btn.layer.cornerRadius = rowButton.layer.cornerRadius
            btn.borderColor = rowButton.layer.borderColor
            btn.backslashDrawable = !UserDefaults.standard.isSoundOn
            btn.pinHeight(to: btn.widthAnchor)
            btn.addTarget(self, action: #selector(didTapToggleSound(_:)), for: .touchUpInside)
            return btn
        }
        
        let rateButton = buildSquareButton(asset: .star)
        rateButton.addTarget(self, action: #selector(didTapRate(_:)), for: .touchUpInside)
                
        let leaderboardButton = buildSquareButton(asset: .podium)
        leaderboardButton.addTarget(
            self, action: #selector(didTapLeaderboard(_:)), for: .touchUpInside)
        
        let muteButton = buildMuteButton(from: rateButton)
        
        let subviews: [UIView] = [rateButton, leaderboardButton, muteButton]
        let sv = UIStackView(arrangedSubviews: subviews)
        sv.alignment = .center
        sv.distribution = .fillEqually
        sv.spacing = defaultSpacing
        sv.axis = .horizontal
        stackView.addArrangedSubview(sv)
    }

    @objc
    func didTapToggleSound(_ sender: UIButton) {
        sender.scale()
        let newValue = !UserDefaults.standard.isSoundOn
        UserDefaults.standard.setSound(newValue)
        if let button = sender as? BackslashButton {
            button.backslashDrawable = !newValue
        }
        
        newValue ?
            AudioPlayer.shared.playMusic() :
            AudioPlayer.shared.pauseMusic()
    }
        
    @objc
    func didTapNewGame(_ sender: UIButton) {
        delegate?.menu(self, didUpdateGameState: .playing)
    }
    
    @objc
    func didTapGarage(_ sender: UIButton) {
        delegate?.menu(self, didUpdateGameState: .garage)
    }
    
    @objc
    func didTapSettings(_ sender: UIButton) {
        delegate?.menu(self, didUpdateGameState: .settings)
    }
    
    @objc
    func didTapRate(_ sender: UIButton) {
        sender.scale()
        delegate?.menu(self, didSelectOption: .rate)
    }
    
    @objc
    func didTapLeaderboard(_ sender: UIButton) {
        delegate?.menu(self, didUpdateGameState: .leaderboard)
    }
}

