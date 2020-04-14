//
//  PlayingMenu.swift
//  Retro
//
//  Created by Atilla Özder on 14.04.2020.
//  Copyright © 2020 Atilla Özder. All rights reserved.
//

import UIKit

class PlayingMenu: Menu {
    
    weak var delegate: MenuDelegate?
    
    static var scoreHeight: CGFloat {
        return UIDevice.current.isPad ? 70 : 40
    }
    
    lazy var scoreButton: UIButton = {
        let btn = buildButton(withTitle: .scoreTitle, height: PlayingMenu.scoreHeight)
        btn.setTitle(MainStrings.scoreTitle.localized + ": 0", for: .normal)
        btn.layer.cornerRadius = PlayingMenu.scoreHeight / 2
        btn.isUserInteractionEnabled = false
        btn.titleEdgeInsets = .init(top: 6, left: 10, bottom: 6, right: 10)
        return btn
    }()

    override func setup() {
        setupPauseButton()
        
        addSubview(scoreButton)
        let constant: CGFloat = UIDevice.current.isPad ? 16 : 8
        scoreButton.pinTop(to: safeTopAnchor, constant: constant)
        scoreButton.pinLeading(to: safeLeadingAnchor, constant: constant)
        self.isHidden = true
    }
    
    func setScore(_ score: Double) {
        let text = MainStrings.scoreTitle.localized + ": \(Int(score))"
        scoreButton.setTitle(text, for: .normal)
    }
    
    private func setupPauseButton() {
        let btn = NoSymbolButton()
        let image = UIImage(named: "pause")?.withRenderingMode(.alwaysTemplate)
        btn.setImage(image, for: .normal)
        btn.imageEdgeInsets = UIDevice.current.isPad ? .initialize(4) : .initialize(2)
        
        let containerSize: CGSize = .initialize(PlayingMenu.scoreHeight)
        
        let container = UIView()
        container.backgroundColor = .menuButton
        container.clipsToBounds = true
        container.layer.borderWidth = 0
        container.layer.borderColor = nil
                
        let bounds: CGRect = .init(origin: .zero, size: containerSize)
        let path = UIBezierPath(
            roundedRect: bounds,
            byRoundingCorners: .allCorners,
            cornerRadii: .initialize(containerSize.height / 2)).cgPath
        
        if #available(iOS 11.0, *) {
            container.layer.cornerRadius = containerSize.height / 2
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
        
        let tappableView = UIView()
        tappableView.addSubview(container)
        
        let padding: CGFloat = UIDevice.current.isPad ? 16 : 8
        container.pinTop(to: tappableView.topAnchor, constant: padding)
        container.pinTrailing(to: tappableView.trailingAnchor, constant: -padding)
        container.pinSize(to: containerSize)
        
        self.addSubview(tappableView)
        tappableView.pinTop(to: safeTopAnchor)
        tappableView.pinTrailing(to: safeTrailingAnchor)
        tappableView.pinSize(to: .initialize(containerSize.width * 1.5))
        tappableView.addTapGesture(target: self, action: #selector(didTapPause(_:)))
    }
    
    @objc
    func didTapPause(_ sender: UITapGestureRecognizer) {
        sender.view?.scale()
        delegate?.menu(self, didUpdateGameState: .paused)
    }
}
