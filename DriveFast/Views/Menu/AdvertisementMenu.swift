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
    
    private lazy var scoreLabel: UILabel = { buildScoreLabel() }()
    
    override var isHidden: Bool {
        didSet {
            scoreLabel.text = "\(UserDefaults.standard.score)"
        }
    }
    
    override func setup() {
        verticalStackView.alignment = .center
        verticalStackView.spacing = 8
        
        let titleLabel = buildTitleLabel()
        
        verticalStackView.addArrangedSubview(titleLabel)
        verticalStackView.addArrangedSubview(scoreLabel)
        verticalStackView.addArrangedSubview(UIView())
        
        setupHorizontalStackView()
        
        self.isHidden = true
        super.setup()
    }
    
    // MARK: - Tap Handling
    
    @objc
    private func didTapBack(_ sender: UIButton) {
        delegate?.menu(self, didUpdateGameState: .home)
    }
    
    @objc
    private func didTapAdvertisement(_ sender: UIButton) {
        sender.scale()
        delegate?.menu(self, didUpdateGameState: .adPresented)
    }
    
    // MARK: - Private Helper Methods
    
    private func buildTitleLabel() -> UILabel {
        let titleLabel = UILabel()
        titleLabel.text = Strings.score.uppercased
        titleLabel.textColor = UIColor.white
        titleLabel.font = .systemFont(ofSize: 30)
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
    
    private func setupHorizontalStackView() {
        let horizontalStackView = UIStackView()
        horizontalStackView.spacing = spacing
        horizontalStackView.axis = .horizontal
        horizontalStackView.distribution = .fillEqually
        horizontalStackView.alignment = .fill
        horizontalStackView.pinHeight(to: 66)
        
        let menuButton = buildSquareButton(with: .menu)
        menuButton.addTarget(self, action: #selector(didTapBack(_:)), for: .touchUpInside)
        horizontalStackView.addArrangedSubview(menuButton)
        
        let advButton = buildSquareButton(with: .roll)
        advButton.imageEdgeInsets = .initialize(12)
        advButton.addTarget(self, action: #selector(didTapAdvertisement(_:)), for: .touchUpInside)
        horizontalStackView.addArrangedSubview(advButton)
        
        verticalStackView.addArrangedSubview(horizontalStackView)
    }
}
