//
//  SettingsView.swift
//  DriveFast
//
//  Created by Atilla Özder on 13.04.2020.
//  Copyright © 2020 Atilla Özder. All rights reserved.
//

import UIKit

// MARK: - SettingsMenuDelegate

protocol SettingsMenuDelegate: AnyObject {
    func settingsMenu(_ settingsMenu: SettingsMenu, didSelectOption option: SettingsMenu.Option)
}

// MARK: - SettingsMenu

final class SettingsMenu: Menu {
    
    // MARK: - Properties
    
    enum Option {
        case otherApps, privacy, share, support, back
        
        var url: URL? {
            switch self {
            case .otherApps:
                let urlString = "itms-apps://itunes.apple.com/developer/atilla-ozder/id1440770128?mt=8"
                return urlString.asURL
            case .privacy:
                let urlString = "http://www.atillaozder.com/privacy-policy"
                return urlString.asURL
            case .support:
                let urlString = "http://www.atillaozder.com"
                return urlString.asURL
            default:
                return nil
            }
        }
    }
    
    weak var delegate: SettingsMenuDelegate?
    
    override func setup() {
        setupShareButton()
        setupSupportButton()
        setupOtherAppsButton()
        setupPrivacyPolicyButton()
        
        backButton.addTarget(self, action: #selector(didTapBack(_:)), for: .touchUpInside)
        verticalStackView.addArrangedSubview(backButton)
        
        self.isHidden = true
        super.setup()
    }
    
    // MARK: - Tap Handling
    
    @objc
    private func didTapBack(_ sender: UIButton) {
        delegate?.settingsMenu(self, didSelectOption: .back)
    }
    
    @objc
    private func didTapOtherApps(_ sender: UIButton) {
        sender.scale()
        delegate?.settingsMenu(self, didSelectOption: .otherApps)
    }
    
    @objc
    private func didTapPrivacy(_ sender: UIButton) {
        sender.scale()
        delegate?.settingsMenu(self, didSelectOption: .privacy)
    }
    
    @objc
    private func didTapSupport(_ sender: UIButton) {
        sender.scale()
        delegate?.settingsMenu(self, didSelectOption: .support)
    }
    
    @objc
    private func didTapShare(_ sender: UIButton) {
        sender.scale()
        delegate?.settingsMenu(self, didSelectOption: .share)
    }
    
    // MARK: - Private Helper Methods
    
    private func setupShareButton() {
        let shareButton = buildButton(title: .share)
        shareButton.addTarget(self, action: #selector(didTapShare(_:)), for: .touchUpInside)
        verticalStackView.addArrangedSubview(shareButton)
    }
    
    private func setupSupportButton() {
        let supportButton = buildButton(title: .support)
        supportButton.addTarget(self, action: #selector(didTapSupport(_:)), for: .touchUpInside)
        verticalStackView.addArrangedSubview(supportButton)
    }
    
    private func setupOtherAppsButton() {
        let otherAppsButton = buildButton(title: .otherApps)
        otherAppsButton.addTarget(self, action: #selector(didTapOtherApps(_:)), for: .touchUpInside)
        verticalStackView.addArrangedSubview(otherAppsButton)
    }
    
    private func setupPrivacyPolicyButton() {
        let ppButton = buildButton(title: .privacy)
        ppButton.addTarget(self, action: #selector(didTapPrivacy(_:)), for: .touchUpInside)
        verticalStackView.addArrangedSubview(ppButton)
    }
}
