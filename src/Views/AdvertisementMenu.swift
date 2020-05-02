//
//  AdvertisementMenu.swift
//  DriveFast
//
//  Created by Atilla Özder on 13.04.2020.
//  Copyright © 2020 Atilla Özder. All rights reserved.
//

import UIKit

class AdvertisementMenu: Menu {
    
    weak var delegate: MenuDelegate?
    
    override func setup() {
        let advButton = buildButton(withTitle: .advButtonTitle, height: 100)
        advButton.titleLabel?.font = UIFont.buildFont(withSize: UIDevice.current.isPad ? 24 : 20)
        advButton.titleLabel?.numberOfLines = 3
        advButton.addTarget(self, action: #selector(didTapAdvertisement(_:)), for: .touchUpInside)
        stackView.addArrangedSubview(advButton)
        
        backButton.addTarget(self, action: #selector(didTapBack(_:)), for: .touchUpInside)
        stackView.addArrangedSubview(backButton)
        
        self.isHidden = true
        super.setup()
    }
    
    @objc
    func didTapBack(_ sender: UIButton) {
        delegate?.menu(self, didUpdateGameState: .home)
    }
    
    @objc
    func didTapAdvertisement(_ sender: UIButton) {
        sender.scale()
        delegate?.menu(self, didUpdateGameState: .advPresenting)
    }
}
