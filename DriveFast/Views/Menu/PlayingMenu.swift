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
    
    private lazy var scoreLabel: UILabel = { buildScoreLabel() }()
    
    private lazy var horizontalLivesStackView: UIStackView = {
        buildHorizontalLivesStackView()
    }()
    
    private lazy var progressView: UIProgressView = {
        buildProgressView()
    }()
    
    private lazy var pauseButton: UIView = {
        buildPauseButton()
    }()
    
    private lazy var fuelAlertLabel: UILabel = {
        buildFuelAlertLabel()
    }()
    
    // MARK: - Setup Views
    
    override func setup() {
        setupPauseButton()
        setupScoreVerticalStackView()
        setupProgressBar()
        setupFuelAlertLabel()
        self.isHidden = true
        self.backgroundColor = nil
    }
    
    // MARK: - Helper Methods
        
    func setFuelProgress(_ progress: Float, animated: Bool = true) {
        if progress.isZero || horizontalLivesStackView.arrangedSubviews.isEmpty {
            stopFuelAnimation()
        } else {
            progress < 0.25 ? startFuelAnimation() : stopFuelAnimation()
        }
        
        self.progressView.setProgress(progress, animated: animated)
    }
    
    func setScore(_ score: Double) {
        scoreLabel.text = Strings.score.localized + ": \(Int(score))"
    }
    
    func setLifeCount(_ count: Int) {
        let previousCount = horizontalLivesStackView.arrangedSubviews.count
        if previousCount > count {
            guard let subview = horizontalLivesStackView.arrangedSubviews.last else { return }
            horizontalLivesStackView.removeArrangedSubview(subview)
            subview.removeFromSuperview()
        } else {
            addLives(count)
        }
    }
    
    func reset() {
        setScore(0)
        setLifeCount(3)
        setFuelProgress(1.0, animated: false)
        isHidden = false
    }
    
    func stopFuelAnimation() {
        isAnimated = false
        fuelAlertLabel.isHidden = true
        fuelAlertLabel.layer.removeAllAnimations()
    }
    
    // MARK: - Tap Handling
    
    @objc
    private func didTapPause(_ sender: UITapGestureRecognizer) {
        sender.view?.scale()
        delegate?.menu(self, didUpdateGameState: .paused)
    }
    
    // MARK: - Private Helper Methods
    
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
    
    private func addLives(_ count: Int) {
        horizontalLivesStackView.arrangedSubviews.forEach { (subview) in
            horizontalLivesStackView.removeArrangedSubview(subview)
            subview.removeFromSuperview()
        }
        
        let constant: CGFloat = UIDevice.current.isPad ? 25 : 15
        for _ in 0..<count {
            let imageView = UIImageView(image: Asset.heart.imageRepresentation())
            imageView.contentMode = .scaleAspectFit
            imageView.makeSquare(constant: constant)
            horizontalLivesStackView.addArrangedSubview(imageView)
        }
    }
    
    private func setupScoreVerticalStackView() {
        let verticalStackView = UIStackView(arrangedSubviews: [scoreLabel, horizontalLivesStackView])
        verticalStackView.spacing = 6
        verticalStackView.alignment = .center
        verticalStackView.distribution = .fill
        verticalStackView.axis = .vertical
        
        addSubview(verticalStackView)
        let constant: CGFloat = UIDevice.current.isPad ? 16 : 8
        verticalStackView.pinTop(to: safeTopAnchor, constant: constant)
        verticalStackView.pinLeading(to: safeLeadingAnchor, constant: constant)
    }
    
    private func setupPauseButton() {
        self.addSubview(pauseButton)
        pauseButton.pinTop(to: safeTopAnchor)
        pauseButton.pinTrailing(to: safeTrailingAnchor)
        pauseButton.addTapGesture(target: self, action: #selector(didTapPause(_:)))
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
        
        let constant: CGFloat = UIDevice.current.isPad ? 122 : 104
        progressView.pinTrailing(to: safeTrailingAnchor, constant: constant)
    }
    
    private func setupFuelAlertLabel() {
        addSubview(fuelAlertLabel)
        fuelAlertLabel.pinTop(to: horizontalLivesStackView.bottomAnchor, constant: 16)
        fuelAlertLabel.pinCenterX(to: centerXAnchor)
        fuelAlertLabel.pinHeight(to: 40)
    }
    
    private func buildScoreLabel() -> UILabel {
        let scoreLabel = UILabel()
        scoreLabel.textColor = UIColor.white
        scoreLabel.font = UIDevice.current.isPad ? .systemFont(ofSize: 24) : .systemFont(ofSize: 18)
        scoreLabel.text = Strings.score.localized + ": 0"
        return scoreLabel
    }
    
    private func buildHorizontalLivesStackView() -> UIStackView {
        let horizontalStackView = UIStackView()
        horizontalStackView.alignment = .fill
        horizontalStackView.distribution = .fillEqually
        horizontalStackView.spacing = 4
        horizontalStackView.axis = .horizontal
        return horizontalStackView
    }
    
    private func buildProgressView() -> UIProgressView {
        let progressView = UIProgressView(progressViewStyle: .default)
        progressView.progressTintColor = .systemYellow
        progressView.trackTintColor = UIColor.systemRed.withAlphaComponent(0.6)
        progressView.layer.borderColor = UIColor.systemRed.cgColor
        progressView.layer.cornerRadius = UIDevice.current.isPad ? 12 : 8
        progressView.layer.borderWidth = 2
        progressView.layer.masksToBounds = true
        progressView.progress = 1.0
        progressView.transform = .init(rotationAngle: .pi / 2)
        progressView.semanticContentAttribute = .forceRightToLeft
        return progressView
    }
    
    private func buildPauseButton() -> UIView {
        let pauseButton = BackslashButton()
        pauseButton.lineWidth = Globals.borderWidth + 2
        
        let image = Asset.pause.imageRepresentation()?.withRenderingMode(.alwaysTemplate)
        pauseButton.setImage(image, for: .normal)
        pauseButton.imageEdgeInsets = UIDevice.current.isPad ? .initialize(4) : .initialize(2)
        
        let height: CGFloat = UIDevice.current.isPad ? 70 : 40
        let size: CGSize = .initialize(height)
        let containerView = pauseButton.buildContainer(withSize: size, cornerRadius: size.height / 2)
        
        let tappableView = UIView()
        tappableView.addSubview(containerView)
        tappableView.pinSize(to: .initialize(size.width * 1.5))
        
        let padding: CGFloat = UIDevice.current.isPad ? 16 : 8
        containerView.pinTop(to: tappableView.topAnchor, constant: padding)
        containerView.pinTrailing(to: tappableView.trailingAnchor, constant: -padding)
        return tappableView
    }
    
    private func buildFuelAlertLabel() -> UILabel {
        let fuelAlertLabel = UILabel()
        fuelAlertLabel.text = Strings.fuelAlert.uppercased
        fuelAlertLabel.font = .systemFont(ofSize: 24, weight: .semibold)
        fuelAlertLabel.textAlignment = .center
        fuelAlertLabel.textColor = .red
        fuelAlertLabel.isHidden = true
        return fuelAlertLabel
    }
}
