//
//  MenuView.swift
//  Retro
//
//  Created by Atilla Özder on 9.04.2020.
//  Copyright © 2020 Atilla Özder. All rights reserved.
//

import UIKit

enum MenuButton {
    case newGame, settings, achievements
}

protocol MenuViewDelegate: AnyObject {
    func menuView(_ menuView: MenuView, didTapMenuButton button: MenuButton)
}

class MenuView: View {
    
    weak var delegate: MenuViewDelegate?
 
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
        let btn = NoSymbolButton()
        let image = UIImage(named: "music")?.withRenderingMode(.alwaysTemplate)
        btn.setImage(image, for: .normal)
        btn.noSymbolDrawable = !UserDefaults.standard.isSoundOn
        btn.imageEdgeInsets = UIDevice.current.isPad ? .initialize(4) : .initialize(2)
        
        let constant: CGFloat = UIDevice.current.isPad ? 80 : 50
        let containerSize: CGSize = .init(width: constant, height: constant)
        
        let container = UIView()
        container.backgroundColor = .menuButton
        container.clipsToBounds = true
        container.layer.borderWidth = 0
        container.layer.borderColor = nil
                
        let bounds: CGRect = .init(origin: .zero, size: containerSize)
        let path = UIBezierPath(
            roundedRect: bounds,
            byRoundingCorners: .allCorners,
            cornerRadii: .initialize(constant / 2)).cgPath
        
        if #available(iOS 11.0, *) {
            container.layer.cornerRadius = constant / 2
        } else {
            let mask = CAShapeLayer()
            mask.path = path
            container.layer.mask = mask
        }
        
        let border = CAShapeLayer()
        border.path = path
        border.fillColor = nil
        border.strokeColor = UIColor.white.cgColor
        
        border.lineWidth = UIDevice.current.isPad ? 10 : 6
        container.layer.addSublayer(border)
        
        container.addSubview(btn)
        btn.pinEdgesToUnsafeArea()
        btn.contentEdgeInsets = UIDevice.current.isPad ? .initialize(16) : .initialize(10)
        
        let padding: CGFloat = UIDevice.current.isPad ? 32 : 16
        self.addSubview(container)
        container.pinTop(to: topAnchor, constant: padding)
        container.pinSize(to: containerSize)
        
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
            for subview in container.subviews where subview is NoSymbolButton {
                let button = subview as! NoSymbolButton
                button.noSymbolDrawable = !newValue
            }
        }
    }
        
    @objc
    func didTapNewGame(_ sender: UIButton) {
        sender.scale()
        delegate?.menuView(self, didTapMenuButton: .newGame)
    }
    
    @objc
    func didTapSettings(_ sender: UIButton) {
        sender.scale()
        delegate?.menuView(self, didTapMenuButton: .settings)
    }
    
    @objc
    func didTapAchievements(_ sender: UIButton) {
        sender.scale()
        delegate?.menuView(self, didTapMenuButton: .achievements)
    }
}

