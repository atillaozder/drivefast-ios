//
//  AdvertisementMenu.swift
//  DriveFast
//
//  Created by Atilla Özder on 13.04.2020.
//  Copyright © 2020 Atilla Özder. All rights reserved.
//

import UIKit

// MARK: - AdvertisementMenu

final class AdvertisementMenu: Menu {
    
    weak var delegate: MenuDelegate?
    
    let scoreLabel: UILabel = {
        let lbl = UILabel()
        lbl.text = "\(UserDefaults.standard.score)"
        lbl.textColor = .white
        lbl.font = .buildFont(Fonts.Courier.bold, withSize: 80)
        lbl.textAlignment = .center
        lbl.minimumScaleFactor = 0.5
        lbl.adjustsFontSizeToFitWidth = true
        return lbl
    }()
    
    override var isHidden: Bool {
        didSet {
            scoreLabel.text = "\(UserDefaults.standard.score)"
        }
    }
    
    override func setup() {
        stackView.alignment = .center
        stackView.spacing = 8
        
        let titleLabel = UILabel()
        titleLabel.text = MainStrings.scoreTitle.localized.uppercased()
        titleLabel.textColor = UIColor.white
        titleLabel.font = .buildFont(Fonts.Courier.bold, withSize: UIDevice.current.isPad ? 40 : 30)
        titleLabel.textAlignment = .center
        titleLabel.minimumScaleFactor = 0.5
        titleLabel.adjustsFontSizeToFitWidth = true
        
        stackView.addArrangedSubview(titleLabel)
        stackView.addArrangedSubview(scoreLabel)
        
        let spacer = UIView()
        stackView.addArrangedSubview(spacer)
        
        let buttons = UIStackView()
        buttons.spacing = defaultSpacing
        buttons.axis = .horizontal
        buttons.distribution = .fillEqually
        buttons.alignment = .fill
        buttons.pinHeight(to: 66)
        
        let menuButton = buildSquareButton(asset: .menu)
        menuButton.addTarget(self, action: #selector(didTapBack(_:)), for: .touchUpInside)
        buttons.addArrangedSubview(menuButton)
        
        let advButton = buildSquareButton(asset: .roll)
        advButton.imageEdgeInsets = .initialize(12)
        advButton.addTarget(self, action: #selector(didTapAdvertisement(_:)), for: .touchUpInside)
        buttons.addArrangedSubview(advButton)
        
        stackView.addArrangedSubview(buttons)

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
        delegate?.menu(self, didUpdateGameState: .adPresented)
    }
}
