//
//  HomeMenu.swift
//  DriveFast
//
//  Created by Atilla Özder on 9.04.2020.
//  Copyright © 2020 Atilla Özder. All rights reserved.
//

import UIKit

// MARK: - HomeMenu

final class HomeMenu: Menu {
    
    weak var delegate: MenuDelegate?
 
    override func setup() {
        setupNewGameButton()
        setupGarageButton()
        setupSettingsButton()
        setupHorizontalStackView()
        super.setup()
    }
    
    // MARK: - Tap Handling
    
    @objc
    private func didTapToggleSound(_ sender: UIButton) {
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
    private func didTapNewGame(_ sender: UIButton) {
        delegate?.menu(self, didUpdateGameState: .playing)
    }
    
    @objc
    private func didTapGarage(_ sender: UIButton) {
        delegate?.menu(self, didUpdateGameState: .garage)
    }
    
    @objc
    private func didTapSettings(_ sender: UIButton) {
        delegate?.menu(self, didUpdateGameState: .settings)
    }
    
    @objc
    private func didTapRate(_ sender: UIButton) {
        sender.scale()
        delegate?.menu(self, didSelectOption: .rate)
    }
    
    @objc
    private func didTapLeaderboard(_ sender: UIButton) {
        delegate?.menu(self, didUpdateGameState: .leaderboard)
    }
    
    // MARK: - Private Helper Methods
    
    private func setupNewGameButton() {
        let newGameButton = buildButton(title: .newGame)
        newGameButton.addTarget(self, action: #selector(didTapNewGame(_:)), for: .touchUpInside)
        verticalStackView.addArrangedSubview(newGameButton)
    }
    
    private func setupGarageButton() {
        let garageButton = buildButton(title: .garage)
        garageButton.addTarget(self, action: #selector(didTapGarage(_:)), for: .touchUpInside)
        verticalStackView.addArrangedSubview(garageButton)
    }
    
    private func setupSettingsButton() {
        let settingsButton = buildButton(title: .settings)
        settingsButton.addTarget(self, action: #selector(didTapSettings(_:)), for: .touchUpInside)
        verticalStackView.addArrangedSubview(settingsButton)
    }
    
    private func setupHorizontalStackView() {
        let rateButton = buildSquareButton(with: .star)
        rateButton.addTarget(self, action: #selector(didTapRate(_:)), for: .touchUpInside)
                
        let leaderboardButton = buildSquareButton(with: .podium)
        leaderboardButton.addTarget(self,
                                    action: #selector(didTapLeaderboard(_:)),
                                    for: .touchUpInside)
        
        let muteButton = buildMuteButton(from: rateButton)
        
        let arrangedSubviews = [rateButton, leaderboardButton, muteButton]
        let horizontalStackView = UIStackView(arrangedSubviews: arrangedSubviews)
        horizontalStackView.alignment = .center
        horizontalStackView.distribution = .fillEqually
        horizontalStackView.spacing = spacing
        horizontalStackView.axis = .horizontal
        verticalStackView.addArrangedSubview(horizontalStackView)
    }
    
    private func buildMuteButton(from otherButton: UIButton) -> UIButton {
        let button = BackslashButton()
        
        let image = Asset.music.imageRepresentation()?
            .withRenderingMode(.alwaysTemplate)
        button.setImage(image, for: .normal)
        
        button.contentEdgeInsets = .zero
        button.isUserInteractionEnabled = true
        
        button.imageEdgeInsets = otherButton.imageEdgeInsets
        button.backgroundColor = otherButton.backgroundColor
        button.layer.borderColor = otherButton.layer.borderColor
        button.layer.borderWidth = otherButton.layer.borderWidth
        button.layer.cornerRadius = otherButton.layer.cornerRadius
        
        button.borderColor = otherButton.layer.borderColor
        button.backslashDrawable = !UserDefaults.standard.isSoundOn
        button.pinHeight(to: button.widthAnchor)
        
        button.addTarget(self,
                         action: #selector(didTapToggleSound(_:)),
                         for: .touchUpInside)
        
        return button
    }
}

