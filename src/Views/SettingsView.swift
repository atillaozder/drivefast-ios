//
//  SettingsView.swift
//  Retro
//
//  Created by Atilla Özder on 13.04.2020.
//  Copyright © 2020 Atilla Özder. All rights reserved.
//

import UIKit

enum SettingButton {
    case rate, moreApp, privacy, share, support
}

protocol SettingsViewDelegate: AnyObject {
    func settingsView(_ settingsView: SettingsView, didTapSettingButton button: SettingButton)
}

class SettingsView: View {
    
    weak var delegate: SettingsViewDelegate?
    
    override func setup() {
        let rateButton = buildButton(withTitle: .rateTitle)
        rateButton.addTarget(self, action: #selector(didTapRate(_:)), for: .touchUpInside)
        stackView.addArrangedSubview(rateButton)
        
        let shareButton = buildButton(withTitle: .shareTitle)
        shareButton.addTarget(self, action: #selector(didTapShare(_:)), for: .touchUpInside)
        stackView.addArrangedSubview(shareButton)
        
        let moreAppButton = buildButton(withTitle: .moreAppTitle)
        moreAppButton.addTarget(self, action: #selector(didTapMoreApp(_:)), for: .touchUpInside)
        stackView.addArrangedSubview(moreAppButton)
        
        let ppButton = buildButton(withTitle: .privacyTitle)
        ppButton.addTarget(self, action: #selector(didTapPrivacy(_:)), for: .touchUpInside)
        stackView.addArrangedSubview(ppButton)
        
        let supportButton = buildButton(withTitle: .supportTitle)
        supportButton.addTarget(self, action: #selector(didTapSupport(_:)), for: .touchUpInside)
        stackView.addArrangedSubview(supportButton)
                        
        stackView.addArrangedSubview(backButton)
        
        self.isHidden = true
        super.setup()
    }
    
    @objc
    func didTapMoreApp(_ sender: UIButton) {
        sender.scale()
        delegate?.settingsView(self, didTapSettingButton: .moreApp)
    }
    
    @objc
    func didTapPrivacy(_ sender: UIButton) {
        sender.scale()
        delegate?.settingsView(self, didTapSettingButton: .privacy)
    }
    
    @objc
    func didTapSupport(_ sender: UIButton) {
        sender.scale()
        delegate?.settingsView(self, didTapSettingButton: .support)
    }
    
    @objc
    func didTapShare(_ sender: UIButton) {
        sender.scale()
        delegate?.settingsView(self, didTapSettingButton: .share)
    }
    
    @objc
    func didTapRate(_ sender: UIButton) {
        sender.scale()
        delegate?.settingsView(self, didTapSettingButton: .rate)
    }
}
