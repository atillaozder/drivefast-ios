//
//  HomeMenu.swift
//  Retro
//
//  Created by Atilla Özder on 9.04.2020.
//  Copyright © 2020 Atilla Özder. All rights reserved.
//

import UIKit

class HomeMenu: Menu {
    
    weak var delegate: MenuDelegate?
 
    override func setup() {
        setupSoundButton()
        
        let newGameButton = buildButton(withTitle: .newGameTitle)
        newGameButton.addTarget(self, action: #selector(didTapNewGame(_:)), for: .touchUpInside)
        stackView.addArrangedSubview(newGameButton)
                
        let achievementsButton = buildButton(withTitle: .achievementsTitle)
        achievementsButton.addTarget(self, action: #selector(didTapAchievements(_:)), for: .touchUpInside)
        stackView.addArrangedSubview(achievementsButton)
        
        let settingsButton = buildButton(withTitle: .settingsTitle)
        settingsButton.addTarget(self, action: #selector(didTapSettings(_:)), for: .touchUpInside)
        stackView.addArrangedSubview(settingsButton)
        
        super.setup()
    }
    
    private func setupSoundButton() {
        let btn = CircleBackslashButton()
        let image = UIImage(named: "music")?.withRenderingMode(.alwaysTemplate)
        btn.setImage(image, for: .normal)
        btn.backslashDrawable = !UserDefaults.standard.isSoundOn
        btn.imageEdgeInsets = UIDevice.current.isPad ? .initialize(4) : .initialize(2)
        
        let constant: CGFloat = UIDevice.current.isPad ? 80 : 50
        let size: CGSize = .initialize(constant)
        let container = btn.buildContainer(withSize: size)
        
        let padding: CGFloat = UIDevice.current.isPad ? 32 : 16
        self.addSubview(container)
        container.pinTop(to: topAnchor, constant: padding)
        container.pinTrailing(to: trailingAnchor, constant: -padding)
        container.addTapGesture(target: self, action: #selector(didTapMute(_:)))
        container.tag = UIView.soundButtonID
    }
    
    @objc
    func didTapMute(_ sender: UITapGestureRecognizer) {
        sender.view?.scale()
        let newValue = !UserDefaults.standard.isSoundOn
        UserDefaults.standard.setSound(newValue)
        
        if let container = self.viewWithTag(UIView.soundButtonID) {
            for subview in container.subviews where subview is CircleBackslashButton {
                let button = subview as! CircleBackslashButton
                button.backslashDrawable = !newValue
            }
        }
    }
        
    @objc
    func didTapNewGame(_ sender: UIButton) {
        delegate?.menu(self, didUpdateGameState: .playing)
    }
    
    @objc
    func didTapSettings(_ sender: UIButton) {
        delegate?.menu(self, didUpdateGameState: .settings)
    }
    
    @objc
    func didTapAchievements(_ sender: UIButton) {
        delegate?.menu(self, didUpdateGameState: .achievements)
    }
}

