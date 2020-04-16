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
    
    lazy var livesStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.alignment = .fill
        stackView.distribution = .fillEqually
        stackView.spacing = 4
        stackView.axis = .horizontal
        return stackView
    }()

    override func setup() {
        setupPauseButton()
        
        let scoreStack = UIStackView(arrangedSubviews: [scoreButton, livesStackView])
        scoreStack.spacing = 6
        scoreStack.alignment = .center
        scoreStack.distribution = .fill
        scoreStack.axis = .vertical
        
        addSubview(scoreStack)
        let constant: CGFloat = UIDevice.current.isPad ? 16 : 8
        scoreStack.pinTop(to: safeTopAnchor, constant: constant)
        scoreStack.pinLeading(to: safeLeadingAnchor, constant: constant)
        
        self.isHidden = true
    }
    
    func setScore(_ score: Double) {
        let text = MainStrings.scoreTitle.localized + ": \(Int(score))"
        scoreButton.setTitle(text, for: .normal)
    }
    
    func setLifeCount(_ count: Int) {
        let previousCount = livesStackView.arrangedSubviews.count
        if previousCount > count {
            guard let lifeView = livesStackView.arrangedSubviews.last else { return }
            livesStackView.removeArrangedSubview(lifeView)
            lifeView.removeFromSuperview()
        } else {
            addLives(count)
        }
    }
    
    private func setupPauseButton() {
        let btn = CircleBackslashButton()
        let image = UIImage(named: "pause")?.withRenderingMode(.alwaysTemplate)
        btn.setImage(image, for: .normal)
        btn.imageEdgeInsets = UIDevice.current.isPad ? .initialize(4) : .initialize(2)
        
        let size: CGSize = .initialize(PlayingMenu.scoreHeight)
        let container = btn.buildContainer(withSize: size)
        
        let tappableView = UIView()
        tappableView.addSubview(container)
        
        let padding: CGFloat = UIDevice.current.isPad ? 16 : 8
        container.pinTop(to: tappableView.topAnchor, constant: padding)
        container.pinTrailing(to: tappableView.trailingAnchor, constant: -padding)
        
        self.addSubview(tappableView)
        tappableView.pinTop(to: safeTopAnchor)
        tappableView.pinTrailing(to: safeTrailingAnchor)
        tappableView.pinSize(to: .initialize(size.width * 1.5))
        tappableView.addTapGesture(target: self, action: #selector(didTapPause(_:)))
    }
    
    private func addLives(_ count: Int) {
        livesStackView.arrangedSubviews.forEach { (lifeView) in
            livesStackView.removeArrangedSubview(lifeView)
            lifeView.removeFromSuperview()
        }
        
        let constant: CGFloat = UIDevice.current.isPad ? 25 : 15
        for _ in 0..<count {
            let image = UIImage(named: "heart")
            let imageView = UIImageView(image: image)
            imageView.contentMode = .scaleAspectFit
            imageView.makeSquare(constant: constant)
            livesStackView.addArrangedSubview(imageView)
        }
    }
    
    @objc
    func didTapPause(_ sender: UITapGestureRecognizer) {
        sender.view?.scale()
        delegate?.menu(self, didUpdateGameState: .paused)
    }
}
