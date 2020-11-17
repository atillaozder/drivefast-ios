//
//  Menu.swift
//  DriveFast
//
//  Created by Atilla Özder on 13.04.2020.
//  Copyright © 2020 Atilla Özder. All rights reserved.
//

import UIKit

// MARK: - MenuDelegate

protocol MenuDelegate: AnyObject {
    func menu(_ menu: Menu, didUpdateGameState gameState: GameState)
    func menu(_ menu: Menu, didSelectOption option: Menu.MenuOption)
}

// MARK: - Menu

class Menu: View {
    
    // MARK: - Properties
    
    enum MenuOption {
        case rate
    }
        
    var width: CGFloat { 200 }
    var spacing: CGFloat { 16 }

    private(set) lazy var backButton: UIButton = buildBackButton()
    private(set) lazy var verticalStackView: UIStackView = buildVerticalStackView()
    
    // MARK: - Setup Views
    
    override func setup() {
        super.setup()
        self.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        let containerView = UIView()
        containerView.addSubview(verticalStackView)
        verticalStackView.pinCenterOfSuperview()
        verticalStackView.pinWidth(to: width)
        
        addSubview(containerView)
        containerView.pinEdgesToSuperview()
    }
    
    func buildButton(title: Strings,
                     font: UIFont = .boldSystemFont(ofSize: 16),
                     height: CGFloat = 48) -> UIButton {
        
        let button = UIButton()
        button.setTitle(title.uppercased, for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = font
        button.titleLabel?.textAlignment = .center
        button.titleLabel?.baselineAdjustment = .alignCenters
        button.titleLabel?.minimumScaleFactor = 0.5
        button.titleLabel?.adjustsFontSizeToFitWidth = true
        
        button.contentEdgeInsets = .init(top: 6, left: 16, bottom: 6, right: 16)
        button.contentHorizontalAlignment = .center
        
        button.backgroundColor = .primary
        button.layer.borderColor = UIColor.primaryBorder.cgColor
        button.layer.borderWidth = Globals.borderWidth
        button.layer.cornerRadius = height / 2
        
        button.pinHeight(to: height)
        return button
    }
    
    func buildSquareButton(with asset: Asset) -> UIButton {
        let button = UIButton()
        button.tintColor = .white
        button.setImage(
            asset.imageRepresentation()?.withRenderingMode(.alwaysTemplate),
            for: .normal)
        button.imageEdgeInsets = .initialize(12)
        button.adjustsImageWhenHighlighted = false
        button.adjustsImageWhenDisabled = false
        
        button.backgroundColor = .primary
        button.layer.borderColor = UIColor.primaryBorder.cgColor
        button.layer.borderWidth = Globals.borderWidth
        button.layer.cornerRadius = 12
                
        button.pinHeight(to: button.widthAnchor)
        return button
    }
    
    // MARK: - Private Helper Methods
    
    private func buildBackButton() -> UIButton {
        let backButton = buildButton(title: .backToMenu)
        backButton.backgroundColor = .systemPink
        backButton.layer.borderColor = UIColor.primaryBorder.cgColor
        backButton.setTitleColor(.white, for: .normal)
        return backButton
    }
    
    private func buildVerticalStackView() -> UIStackView {
        let verticalStackView = UIStackView()
        verticalStackView.distribution = .fill
        verticalStackView.alignment = .fill
        verticalStackView.axis = .vertical
        verticalStackView.spacing = spacing
        return verticalStackView
    }
}
