//
//  PlayingMenu.swift
//  DriveFast
//
//  Created by Atilla Özder on 14.04.2020.
//  Copyright © 2020 Atilla Özder. All rights reserved.
//

import UIKit

// MARK: - PlayingMenu

final class PlayingMenu: Menu {
    
    // MARK: - Properties
    private var isAnimated: Bool = false
    weak var delegate: MenuDelegate?

    static var scoreHeight: CGFloat {
        return UIDevice.current.isPad ? 70 : 40
    }
    
    let scoreLabel: UILabel = {
        let lbl = UILabel()
        lbl.textColor = UIColor.white
        lbl.font = UIDevice.current.isPad ? .buildFont(withSize: 24) : .buildFont(withSize: 18)
        lbl.text = MainStrings.scoreTitle.localized + ": 0"
        return lbl
    }()
    
    lazy var livesStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.alignment = .fill
        stackView.distribution = .fillEqually
        stackView.spacing = 4
        stackView.axis = .horizontal
        return stackView
    }()
    
    lazy var progressView: UIProgressView = {
        let pv = UIProgressView(progressViewStyle: .default)
        pv.progressTintColor = .systemYellow
        pv.trackTintColor = UIColor.systemRed.withAlphaComponent(0.6)
        pv.layer.borderColor = UIColor.systemRed.cgColor
        pv.layer.cornerRadius = UIDevice.current.isPad ? 12 : 8
        pv.layer.borderWidth = 2
        pv.layer.masksToBounds = true
        pv.progress = 1.0
        pv.transform = .init(rotationAngle: .pi / 2)
        pv.semanticContentAttribute = .forceRightToLeft
        return pv
    }()
    
    lazy var pauseContainer: UIView = {
        let btn = BackslashButton()
        btn.lineWidth = Globals.borderWidth + 2
        let image = Asset.pause.imageRepresentation()?.withRenderingMode(.alwaysTemplate)
        btn.setImage(image, for: .normal)
        btn.imageEdgeInsets = UIDevice.current.isPad ? .initialize(4) : .initialize(2)
        let size: CGSize = .initialize(PlayingMenu.scoreHeight)
        let container = btn.buildContainer(withSize: size, cornerRadius: size.height / 2)
        
        let tappableView = UIView()
        tappableView.addSubview(container)
        tappableView.pinSize(to: .initialize(size.width * 1.5))
        
        let padding: CGFloat = UIDevice.current.isPad ? 16 : 8
        container.pinTop(to: tappableView.topAnchor, constant: padding)
        container.pinTrailing(to: tappableView.trailingAnchor, constant: -padding)
        return tappableView
    }()
    
    lazy var fuelAlertLabel: UILabel = {
        let lbl = UILabel()
        lbl.text = MainStrings.fuelAlert.localized
        lbl.font = .buildFont(withSize: 18)
        lbl.textAlignment = .center
        lbl.textColor = .red
        lbl.isHidden = true
        return lbl
    }()
    
    override func setup() {
        setupPauseButton()
        setupScoreButton()
        setupProgressBar()
        
        addSubview(fuelAlertLabel)
        fuelAlertLabel.pinTop(to: livesStackView.bottomAnchor, constant: 16)
        fuelAlertLabel.pinCenterX(to: centerXAnchor)
        fuelAlertLabel.pinHeight(to: 40)
        self.isHidden = true
        self.backgroundColor = nil
    }
    
    func reset() {
        setScore(0)
        setLifeCount(3)
        setFuelProgress(1.0, animated: false)
        isHidden = false
    }
    
    func setFuelProgress(_ progress: Float, animated: Bool = true) {
        if progress.isZero || livesStackView.arrangedSubviews.isEmpty {
            stopFuelAnimation()
        } else {
            progress < 0.25 ? startFuelAnimation() : stopFuelAnimation()
        }
        
        self.progressView.setProgress(progress, animated: animated)
    }
    
    func setScore(_ score: Double) {
        scoreLabel.text = MainStrings.scoreTitle.localized + ": \(Int(score))"
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
    
    private func startFuelAnimation() {
        if isAnimated {
            return
        }
        
        fuelAlertLabel.isHidden = false
        isAnimated = true
        fuelAlertLabel.alpha = 1
        
        UIView.animate(
            withDuration: 0.25,
            delay: 0.0,
            options: [.repeat, .autoreverse],
            animations: {
                self.fuelAlertLabel.alpha = 0.5
        }, completion: nil)
    }
    
    func stopFuelAnimation() {
        isAnimated = false
        fuelAlertLabel.isHidden = true
        fuelAlertLabel.layer.removeAllAnimations()
    }
    
    private func setupPauseButton() {
        self.addSubview(pauseContainer)
        pauseContainer.pinTop(to: safeTopAnchor)
        pauseContainer.pinTrailing(to: safeTrailingAnchor)
        pauseContainer.addTapGesture(target: self, action: #selector(didTapPause(_:)))
    }
    
    private func setupScoreButton() {
        let scoreStack = UIStackView(arrangedSubviews: [scoreLabel, livesStackView])
        scoreStack.spacing = 6
        scoreStack.alignment = .center
        scoreStack.distribution = .fill
        scoreStack.axis = .vertical
        
        addSubview(scoreStack)
        let constant: CGFloat = UIDevice.current.isPad ? 16 : 8
        scoreStack.pinTop(to: safeTopAnchor, constant: constant)
        scoreStack.pinLeading(to: safeLeadingAnchor, constant: constant)
    }
    
    private func setupProgressBar() {
        let fuelImageView = UIImageView(image: Asset.fuel.imageRepresentation())
        fuelImageView.pinSize(to: UIDevice.current.isPad ? .initialize(48) : .initialize(32))
        fuelImageView.contentMode = .scaleAspectFit
        
        addSubview(fuelImageView)
        let insets: UIEdgeInsets = UIDevice.current.isPad ? .viewEdge(16) : .viewEdge(8)
        fuelImageView.pinEdgesToView(self, insets: insets, exclude: [.top, .leading])
        
        addSubview(progressView)
        let height: CGFloat = UIDevice.current.isPad ? 24 : 16
        let width: CGFloat = UIDevice.current.isPad ? 300 : 240
        progressView.pinSize(to: .init(width: width, height: height))
        progressView.pinBottom(to: fuelImageView.topAnchor, constant: -(width / 2))
        
        let rPadding: CGFloat = UIDevice.current.isPad ? 122 : 104
        progressView.pinTrailing(to: safeTrailingAnchor, constant: rPadding)
    }
    
    private func addLives(_ count: Int) {
        livesStackView.arrangedSubviews.forEach { (lifeView) in
            livesStackView.removeArrangedSubview(lifeView)
            lifeView.removeFromSuperview()
        }
        
        let constant: CGFloat = UIDevice.current.isPad ? 25 : 15
        for _ in 0..<count {
            let imageView = UIImageView(image: Asset.heart.imageRepresentation())
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
