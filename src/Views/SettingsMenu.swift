//
//  SettingsView.swift
//  DriveFast
//
//  Created by Atilla Özder on 13.04.2020.
//  Copyright © 2020 Atilla Özder. All rights reserved.
//

import UIKit

enum SettingsMenuOption {
    case otherApps, privacy, share, support, back
}

protocol SettingsMenuDelegate: AnyObject {
    func settingsMenu(_ settingsMenu: SettingsMenu, didSelectOption option: SettingsMenuOption)
}

class SettingsMenu: Menu {
    
    weak var delegate: SettingsMenuDelegate?
    
    override func setup() {
        let shareButton = buildButton(withTitle: .shareTitle)
        shareButton.addTarget(self, action: #selector(didTapShare(_:)), for: .touchUpInside)
        stackView.addArrangedSubview(shareButton)
        
        let otherAppsButton = buildButton(withTitle: .otherAppsTitle)
        otherAppsButton.addTarget(self, action: #selector(didTapOtherApps(_:)), for: .touchUpInside)
        stackView.addArrangedSubview(otherAppsButton)
        
        let ppButton = buildButton(withTitle: .privacyTitle)
        ppButton.addTarget(self, action: #selector(didTapPrivacy(_:)), for: .touchUpInside)
        stackView.addArrangedSubview(ppButton)
        
        let supportButton = buildButton(withTitle: .supportTitle)
        supportButton.addTarget(self, action: #selector(didTapSupport(_:)), for: .touchUpInside)
        stackView.addArrangedSubview(supportButton)
                        
        backButton.addTarget(self, action: #selector(didTapBack(_:)), for: .touchUpInside)
        stackView.addArrangedSubview(backButton)
        
        self.isHidden = true
        super.setup()
    }
    
    @objc
    func didTapBack(_ sender: UIButton) {
        delegate?.settingsMenu(self, didSelectOption: .back)
    }
    
    @objc
    func didTapOtherApps(_ sender: UIButton) {
        sender.scale()
        delegate?.settingsMenu(self, didSelectOption: .otherApps)
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
