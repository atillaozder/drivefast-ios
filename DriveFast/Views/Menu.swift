//
//  Menu.swift
//  DriveFast
//
//  Created by Atilla Özder on 13.04.2020.
//  Copyright © 2020 Atilla Özder. All rights reserved.
//

import UIKit

enum MenuOption {
    case rate
}

protocol MenuDelegate: AnyObject {
    func menu(_ menu: Menu, didUpdateGameState gameState: GameState)
    func menu(_ menu: Menu, didSelectOption option: MenuOption)
}

class Menu: UIView {
    
    static let defaultButtonHeight: CGFloat = 44
    
    var defaultSpacing: CGFloat {
        return UIDevice.current.isPad ? 16 : 12
    }

    lazy var backButton: UIButton = {
        let btn = buildButton(withTitle: .backToMenuTitle)
        let color = UIColor.systemYellow
        btn.backgroundColor = color
        btn.layer.borderColor = color.darker().cgColor
        btn.setTitleColor(.customBlack, for: .normal)
        return btn
    }()
    
    lazy var stackView: UIStackView = {
        let sv = UIStackView()
        sv.distribution = .fill
        sv.alignment = .fill
        sv.axis = .vertical
        sv.spacing = defaultSpacing
        return sv
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    func setup() {
        self.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        let container = UIView()
        container.addSubview(stackView)
        stackView.pinCenterOfSuperview()
        stackView.pinWidth(to: 200)
        
        addSubview(container)
        container.pinEdgesToSuperview()
    }
    
    func buildButton(withTitle localizable: MainStrings,
                     font: UIFont = .buildFont(),
                     height: CGFloat = Menu.defaultButtonHeight) -> UIButton {
        
        var aHeight = height
        if height == Menu.defaultButtonHeight {
            aHeight = UIDevice.current.isPad ? height * 1.25 : height
        }
        
        let btn = UIButton()
        btn.setTitle(localizable.localized.uppercased(with: .current), for: .normal)
        btn.setTitleColor(.white, for: .normal)
        btn.titleLabel?.font = font
        btn.titleLabel?.textAlignment = .center
        btn.titleLabel?.baselineAdjustment = .alignCenters
        btn.titleLabel?.minimumScaleFactor = 0.2
        btn.titleLabel?.adjustsFontSizeToFitWidth = true
        btn.contentEdgeInsets = .init(top: 6, left: 16, bottom: 6, right: 16)
        btn.contentHorizontalAlignment = .center
        btn.backgroundColor = .customBlue
        btn.layer.borderColor = UIColor.customBlue2.cgColor
        btn.layer.borderWidth = Globals.borderWidth
        btn.layer.cornerRadius = aHeight / 2
        btn.pinHeight(to: aHeight)
        return btn
    }
    
    func buildSquareButton(asset: Asset) -> UIButton {
        let btn = UIButton()
        btn.tintColor = .white
        btn.setImage(asset.imageRepresentation()?.withRenderingMode(.alwaysTemplate), for: .normal)
        btn.backgroundColor = .customBlue
        btn.layer.borderColor = UIColor.customBlue2.cgColor
        btn.layer.borderWidth = Globals.borderWidth
        btn.layer.cornerRadius = 16
        btn.imageEdgeInsets = .initialize(16)
        btn.adjustsImageWhenHighlighted = false
        btn.adjustsImageWhenDisabled = false
        btn.pinHeight(to: btn.widthAnchor)
        return btn
    }
}
