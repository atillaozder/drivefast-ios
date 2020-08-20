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
    
    override func setup() {
        let continueButton = buildButton(withTitle: .continueTitle)
        continueButton.addTarget(self, action: #selector(didTapContinue(_:)), for: .touchUpInside)
        stackView.addArrangedSubview(continueButton)
                        
        backButton.addTarget(self, action: #selector(didTapBack(_:)), for: .touchUpInside)
        stackView.addArrangedSubview(backButton)
        
        self.isHidden = true
        super.setup()
    }
    
    @objc
    func didTapContinue(_ sender: UIButton) {
        delegate?.menu(self, didUpdateGameState: .continued)
    }
    
    @objc
    func didTapBack(_ sender: UIButton) {
        delegate?.menu(self, didUpdateGameState: .home)
    }
}
