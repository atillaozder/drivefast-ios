//
//  AdvView.swift
//  Retro
//
//  Created by Atilla Özder on 13.04.2020.
//  Copyright © 2020 Atilla Özder. All rights reserved.
//

import UIKit

protocol AdvViewDelegate: AnyObject {
    func advViewDidTapAdvertisement(_ advView: AdvView)
}

class AdvView: View {
    
    weak var delegate: AdvViewDelegate?
    
    override func setup() {
        let advButton = buildButton(withTitle: .advButtonTitle, height: 100)
        advButton.titleLabel?.font = UIFont.buildFont(withSize: UIDevice.current.isPad ? 24 : 20)
        advButton.titleLabel?.numberOfLines = 3
        advButton.layer.cornerRadius = 20
        advButton.addTarget(self, action: #selector(didTapAdvertisement(_:)), for: .touchUpInside)
        stackView.addArrangedSubview(advButton)
        stackView.addArrangedSubview(backButton)
        
        self.isHidden = true
        super.setup()
    }
    
    @objc
    func didTapAdvertisement(_ sender: UIButton) {
        sender.scale()
        delegate?.advViewDidTapAdvertisement(self)
    }
}
