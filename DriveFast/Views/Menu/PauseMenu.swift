//
//  PauseMenu.swift
//  DriveFast
//
//  Created by Atilla Özder on 14.04.2020.
//  Copyright © 2020 Atilla Özder. All rights reserved.
//

import UIKit

// MARK: - PauseMenu

final class PauseMenu: Menu {
    
    weak var delegate: MenuDelegate?
    
    // MARK: - Setup Views
    
    override func setup() {
        setupContinueButton()
        backButton.addTarget(self, action: #selector(didTapBack(_:)), for: .touchUpInside)
        verticalStackView.addArrangedSubview(backButton)
        self.isHidden = true
        super.setup()
    }
    
    // MARK: - Tap Handling
    
    @objc
    private func didTapContinue(_ sender: UIButton) {
        delegate?.menu(self, didUpdateGameState: .continued)
    }
    
    @objc
    private func didTapBack(_ sender: UIButton) {
        delegate?.menu(self, didUpdateGameState: .home)
    }
    
    // MARK: - Private Helper Methods
    
    private func setupContinueButton() {
        let continueButton = buildButton(title: .continueTitle)
        continueButton.addTarget(self, action: #selector(didTapContinue(_:)), for: .touchUpInside)
        verticalStackView.addArrangedSubview(continueButton)
    }
}
