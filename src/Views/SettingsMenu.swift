//
//  SettingsView.swift
//  DriveFast
//
//  Created by Atilla Özder on 13.04.2020.
//  Copyright © 2020 Atilla Özder. All rights reserved.
//

import UIKit

enum SettingsMenuOption {
    case moreApp, privacy, share, support, back
}

protocol SettingsMenuDelegate: AnyObject {
    func settingsMenu(_ settingsMenu: SettingsMenu, didSelectOption option: SettingsMenuOption)
}

class SettingsMenu: Menu {
    
    weak var delegate: SettingsMenuDelegate?
    
    override func setup() {
        let fontSize: CGFloat = UIDevice.current.isPad ? 28 : 18
        let font = UIFont.buildFont(withSize: fontSize)
        
        let shareButton = buildButton(withTitle: .shareTitle, font: font)
        shareButton.addTarget(self, action: #selector(didTapShare(_:)), for: .touchUpInside)
        stackView.addArrangedSubview(shareButton)
        
        let moreAppButton = buildButton(withTitle: .moreAppTitle, font: font)
        moreAppButton.addTarget(self, action: #selector(didTapMoreApp(_:)), for: .touchUpInside)
        stackView.addArrangedSubview(moreAppButton)
        
        let ppButton = buildButton(withTitle: .privacyTitle, font: font)
        ppButton.addTarget(self, action: #selector(didTapPrivacy(_:)), for: .touchUpInside)
        stackView.addArrangedSubview(ppButton)
        
        let supportButton = buildButton(withTitle: .supportTitle, font: font)
        supportButton.addTarget(self, action: #selector(didTapSupport(_:)), for: .touchUpInside)
        stackView.addArrangedSubview(supportButton)
                        
        backButton.addTarget(self, action: #selector(didTapBack(_:)), for: .touchUpInside)
        backButton.titleLabel?.font = font
        stackView.addArrangedSubview(backButton)
        
        self.isHidden = true
        super.setup()
    }
    
    @objc
    func didTapBack(_ sender: UIButton) {
        delegate?.settingsMenu(self, didSelectOption: .back)
    }
    
    @objc
    func didTapMoreApp(_ sender: UIButton) {
        sender.scale()
        delegate?.settingsMenu(self, didSelectOption: .moreApp)
    }
    
    @objc
    func didTapPrivacy(_ sender: UIButton) {
        sender.scale()
        delegate?.settingsMenu(self, didSelectOption: .privacy)
    }
    
    @objc
    func didTapSupport(_ sender: UIButton) {
        sender.scale()
        delegate?.settingsMenu(self, didSelectOption: .support)
    }
    
    @objc
    func didTapShare(_ sender: UIButton) {
        sender.scale()
        delegate?.settingsMenu(self, didSelectOption: .share)
    }
}
