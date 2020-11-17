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
    
    override var width: CGFloat { UIScreen.main.bounds.width }
    private lazy var scoreLabel: UILabel = buildScoreLabel()
    
    override var isHidden: Bool {
        didSet {
            scoreLabel.text = "\(UserDefaults.standard.score)"
        }
    }
    
    override func setup() {
        verticalStackView.alignment = .center
        verticalStackView.spacing = 16
        
        let titleLabel = buildTitleLabel()
        verticalStackView.addArrangedSubview(titleLabel)
        verticalStackView.addArrangedSubview(scoreLabel)
        
        let spacer = UIView()
        spacer.pinHeight(to: 6)
        verticalStackView.addArrangedSubview(spacer)
        
        setupButtons()
                
        self.isHidden = true
        super.setup()
    }
    
    // MARK: - Tap Handling
    
    @objc
    private func didTapBack() {
        delegate?.menu(self, didUpdateGameState: .home)
    }
    
    @objc
    private func didTapAdvertisement() {
        delegate?.menu(self, didUpdateGameState: .adPresented)
    }
    
    // MARK: - Private Helper Methods
    
    private func setupButtons() {
        let menuButton = buildContainer(asset: .menu, title: Strings.backToMenu.localized)
        menuButton.addTapGesture(target: self, action: #selector(didTapBack))
        
        let advButton = buildContainer(asset: .playVideo,
                                       title: "watch a video",
                                       subtitle: "to continue game")
        advButton.addTapGesture(target: self, action: #selector(didTapAdvertisement))
        
        verticalStackView.addArrangedSubview(advButton)
        verticalStackView.addArrangedSubview(menuButton)
        
        menuButton.pinWidth(to: advButton.widthAnchor)
    }
    
    private func buildTitleLabel() -> UILabel {
        let titleLabel = UILabel()
        titleLabel.text = Strings.score.uppercased
        titleLabel.textColor = UIColor.white
        titleLabel.font = .boldSystemFont(ofSize: 30)
        titleLabel.textAlignment = .center
        titleLabel.minimumScaleFactor = 0.5
        titleLabel.adjustsFontSizeToFitWidth = true
        return titleLabel
    }
    
    private func buildScoreLabel() -> UILabel {
        let scoreLabel = UILabel()
        scoreLabel.text = "\(UserDefaults.standard.score)"
        scoreLabel.textColor = .white
        scoreLabel.font = .boldSystemFont(ofSize: 80)
        scoreLabel.textAlignment = .center
        scoreLabel.minimumScaleFactor = 0.5
        scoreLabel.adjustsFontSizeToFitWidth = true
        return scoreLabel
    }
    
    private func buildContainer(asset: Asset, title: String, subtitle: String? = nil) -> UIView {
        let containerView = UIView()
        containerView.backgroundColor = .primary
        containerView.pinHeight(to: 64)
        
        containerView.layer.cornerRadius = 32
        containerView.layer.borderColor = UIColor.primaryBorder.cgColor
        containerView.layer.borderWidth = 2
        
        let imageView: UIImageView = {
            let imageView = UIImageView()
            imageView.contentMode = .scaleAspectFit
            imageView.tintColor = .white
            imageView.image = asset.imageRepresentation()?.withRenderingMode(.alwaysTemplate)
            
            containerView.addSubview(imageView)
            imageView.pinTrailing(to: containerView.trailingAnchor, constant: -10)
            imageView.pinCenterY(to: containerView.centerYAnchor)
            imageView.pinSize(to: .initialize(40))
            return imageView
        }()
        
        let verticalStackView: UIStackView = {
            let titleLabel = buildLabel()
            titleLabel.text = title.uppercased(with: .current)
            
            let verticalStackView = UIStackView(arrangedSubviews: [titleLabel])
            verticalStackView.axis = .vertical
            verticalStackView.spacing = 2
            verticalStackView.distribution = .fill
            verticalStackView.alignment = .fill
            
            if let subtitle = subtitle {
                let subtitleLabel = buildLabel()
                subtitleLabel.text = subtitle
                subtitleLabel.font = UIFont.systemFont(ofSize: 12)
                verticalStackView.addArrangedSubview(subtitleLabel)
            }
            
            containerView.addSubview(verticalStackView)
            verticalStackView.pinLeading(to: containerView.leadingAnchor, constant: 20)
            verticalStackView.pinCenterY(to: containerView.centerYAnchor)
            return verticalStackView
        }()

        verticalStackView.pinTrailing(to: imageView.leadingAnchor, constant: -10)
        return containerView
    }
    
    private func buildLabel() -> UILabel {
        let label = UILabel()
        label.textColor = .white
        label.textAlignment = .center
        label.minimumScaleFactor = 0.5
        label.adjustsFontSizeToFitWidth = true
        label.font = UIFont.boldSystemFont(ofSize: 18)
        return label
    }
}
