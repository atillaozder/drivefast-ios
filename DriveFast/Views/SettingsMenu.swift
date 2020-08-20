//
//  SettingsView.swift
//  DriveFast
//
//  Created by Atilla Özder on 13.04.2020.
//  Copyright © 2020 Atilla Özder. All rights reserved.
//

import UIKit
import UserMessagingPlatform

enum SettingsMenuOption {
    case otherApps, privacy, share, support, back
}

protocol SettingsMenuDelegate: AnyObject {
    func settingsMenu(_ settingsMenu: SettingsMenu, didSelectOption option: SettingsMenuOption)
}

// MARK: - SettingsMenu

final class SettingsMenu: Menu {
    
    weak var delegate: SettingsMenuDelegate?
    
    override func setup() {
        let shareButton = buildButton(withTitle: .shareTitle)
        shareButton.addTarget(self, action: #selector(didTapShare(_:)), for: .touchUpInside)
        stackView.addArrangedSubview(shareButton)
        
        let supportButton = buildButton(withTitle: .supportTitle)
        supportButton.addTarget(
            self, action: #selector(didTapSupport(_:)), for: .touchUpInside)
        stackView.addArrangedSubview(supportButton)
        
        let otherAppsButton = buildButton(withTitle: .otherAppsTitle)
        otherAppsButton.addTarget(self, action: #selector(didTapOtherApps(_:)), for: .touchUpInside)
        stackView.addArrangedSubview(otherAppsButton)
        
        let ppButton = buildButton(withTitle: .privacyTitle)
        ppButton.addTarget(self, action: #selector(didTapPrivacy(_:)), for: .touchUpInside)
        stackView.addArrangedSubview(ppButton)
        
        let resetButtonHeight: CGFloat = UIDevice.current.isPad ? 70 : 60
        let resetButton = buildButton(
            withTitle: .resetDataSharingConfigurationsTitle, height: resetButtonHeight)
        
        resetButton.contentEdgeInsets = .init(top: 2, left: 16, bottom: 2, right: 16)
        resetButton.layer.cornerRadius = ppButton.layer.cornerRadius
        resetButton.titleLabel?.numberOfLines = 2
        
        resetButton.addTarget(
            self,
            action: #selector(didTapResetDataSharingConfigurations(_:)),
            for: .touchUpInside)
        
        stackView.addArrangedSubview(resetButton)
        
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
    
    @objc
    func didTapResetDataSharingConfigurations(_ sender: UIButton) {
        sender.scale()
        UMPConsentInformation.sharedInstance.reset()
        Toast.shared.present(in: self, with: "Reset successfully!", duration: 1.5)
    }
}
