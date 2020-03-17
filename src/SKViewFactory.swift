//
//  SKViewFactory.swift
//  Retro
//
//  Created by Atilla Özder on 13.10.2019.
//  Copyright © 2019 Atilla Özder. All rights reserved.
//

import SpriteKit
import GameplayKit
import UIKit

// MARK: - MainStrings
enum MainStrings: String {
    case score = "score"
    case best = "bestScore"
    case viewThisAdPt1 = "viewThisAdPt1"
    case viewThisAdPt2 = "viewThisAdPt2"
    case newGame = "newGame"
    
    var localized: String {
        return NSLocalizedString(self.rawValue, comment: "")
    }
}

// MARK: - Coin
enum Coin: String {
    case single = "single_coin"
    case multiple = "multiple_coins"
    case bag = "coin_bag"
    
    var value: Int {
        switch self {
        case .single:
            return 10
        case .multiple:
            return 25
        case .bag:
            return 50
        }
    }
}

// MARK: - Category
enum Category: UInt32 {
    case coin = 0x100
    case car = 0x10
    case player = 0x1
}

// MARK: - SKViewFactory

struct SKViewFactory {

    let ngLabelKey = "new_game_label"
    let ngBtnKey = "new_game_button"
    let pvLabelKey = "play_video_label"
    let pvBtnKey = "play_video_button"
    let iOS10pvLabelKey = "play_video_label_iOS10"
    
    static let fontName: String = "AmericanTypewriter-semibold"
    
    func childNodeNames() -> [String] {
        return [ngLabelKey, ngBtnKey, pvLabelKey, pvBtnKey, iOS10pvLabelKey]
    }
    
    func buildLabel(text: String, name: String) -> SKLabelNode {
        let lbl = SKLabelNode(fontNamed: SKViewFactory.fontName)
        lbl.fontSize = 24
        lbl.name = name
        lbl.zPosition = 999
        lbl.text = text
        return lbl
    }
    
    func buildNewGameButton(rect: CGRect) -> (button: SKShapeNode, label: SKLabelNode) {
        let btn = buildButton(name: ngBtnKey, color: UIColor(red: 249, green: 220, blue: 92))
        btn.position = .init(x: rect.midX, y: rect.midY + 25)
                
        let lbl = buildLabel(text: MainStrings.newGame.localized, name: ngLabelKey)
        lbl.position = .init(x: rect.midX, y: btn.position.y - 8)
        lbl.isUserInteractionEnabled = false
        return (btn, lbl)
    }
    
    func buildPlayVideoButton(rect: CGRect) -> (button: SKShapeNode, label: SKLabelNode) {
        let btnHeight: CGFloat = 80
        let btn = buildButton(name: pvBtnKey, color: .systemTeal, height: btnHeight)
        btn.position = .init(x: rect.midX, y: rect.midY - 25 - 32)
        
        var text = MainStrings.viewThisAdPt1.localized
        if #available(iOS 11.0, *) {
            text = MainStrings.viewThisAdPt1.localized + " " + MainStrings.viewThisAdPt2.localized
        }
                
        let lbl = buildLabel(text: text, name: pvLabelKey)
        lbl.isUserInteractionEnabled = false
        lbl.horizontalAlignmentMode = .center
        var lblY = btn.position.y + 8

        let preferredMaxLayoutWidth: CGFloat = 204
        if #available(iOS 11.0, *) {
            lbl.numberOfLines = 3
            lbl.lineBreakMode = .byWordWrapping
            lbl.preferredMaxLayoutWidth = preferredMaxLayoutWidth
            lblY -= 36
        }
        
        let labelFrame = lbl.calculateAccumulatedFrame()
        if labelFrame.width > preferredMaxLayoutWidth || labelFrame.height > btnHeight {
            lbl.fontSize = 20
            if #available(iOS 11.0, *) {
                lblY -= 6
            }
        }
        
        if #available(iOS 11.0, *) {
            let attrText = NSMutableAttributedString(string: text)
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.alignment = .center
            
            let font = UIFont(name: lbl.fontName!, size: lbl.fontSize) ?? UIFont.systemFont(ofSize: lbl.fontSize)
            
            attrText.addAttributes([
                .foregroundColor : UIColor.white,
                .font : font,
                .paragraphStyle: paragraphStyle
            ], range: NSRange(location: 0, length: text.count))
            
            lbl.attributedText = attrText
        }

        lbl.position = .init(x: rect.midX, y: lblY)
        return (btn, lbl)
    }
        
    func buildButton(name: String, color: UIColor, height: CGFloat = 50) -> SKShapeNode {
        let btn = SKShapeNode(rectOf: .init(width: 260, height: height), cornerRadius: 10)
        btn.fillColor = color
        btn.lineWidth = 4
        btn.strokeColor = color.darker()
        btn.name = name
        btn.zPosition = 998
        return btn
    }
    
    func buildCoin(rect: CGRect, type: Coin) -> SKSpriteNode {
        let texture = SKTexture(imageNamed: type.rawValue)
        let node = SKSpriteNode(texture: texture)
        node.size = CGSize(width: 10, height: 10)
        node.position = CGPoint(x: 0, y: rect.size.height + node.size.height)
        node.zPosition = 0
        node.name = type.rawValue
        let ratio = UIDevice.current.isPad ? rect.width / 3 : rect.width / 1.5
        node.setScale(to: ratio)
        return node
    }
}

// MARK: - UserDefaults
extension UserDefaults {
    
    func setScore(_ score: Int?) {
        set(score, forKey: "score")
        if let wrappedValue = score, wrappedValue > getBestScore() {
            setBestScore(wrappedValue)
        }
    }
    
    func getScore() -> Int {
        return (value(forKey: "score") as? Int) ?? 0
    }
    
    func setBestScore(_ score: Int) {
        set(score, forKey: "best_score")
    }
    
    func getBestScore() -> Int {
        return (value(forKey: "best_score") as? Int) ?? 0
    }
}


// MARK: - SKSpriteNode
extension SKSpriteNode {
    func scaleAspectFill(to size: CGSize) {
        if texture != nil {
            self.size = texture!.size()
            let vRatio = size.height / self.texture!.size().height
            let hRatio = size.width /  self.texture!.size().width
            let ratio = hRatio > vRatio ? hRatio : vRatio
            self.setScale(ratio)
        }
    }
    
    func setScale(to value: CGFloat) {
        if let texture = self.texture {
            self.setScale((value / texture.size().width))
        }
    }
}

// MARK: - UIColor
extension UIColor {
    
    convenience init(red: Int, green: Int, blue: Int) {
        self.init(
            red: CGFloat(red) / 255,
            green: CGFloat(green) / 255,
            blue: CGFloat(blue) / 255,
            alpha: 1
        )
    }
    
    class var roadColor: UIColor {
        return .init(red: 33, green: 44, blue: 48)
    }
    
    class var customBlack: UIColor {
        return .init(red: 34, green: 34, blue: 34)
    }
    
    func lighter(by percentage: CGFloat = 20) -> UIColor {
        return self.adjust(by: abs(percentage))
    }
    
    func darker(by percentage: CGFloat = 20) -> UIColor {
        return self.adjust(by: -1 * abs(percentage))
    }
    
    func adjust(by percentage: CGFloat = 30.0) -> UIColor {
        var red: CGFloat = 0, green: CGFloat = 0, blue: CGFloat = 0, alpha: CGFloat = 0
        if self.getRed(&red, green: &green, blue: &blue, alpha: &alpha) {
            return UIColor(red: min(red + percentage/100, 1.0),
                           green: min(green + percentage/100, 1.0),
                           blue: min(blue + percentage/100, 1.0),
                           alpha: alpha)
        } else {
            return self
        }
    }
}

// MARK: - UIDevice
extension UIDevice {
    var isPad: Bool {
        return UIDevice.current.userInterfaceIdiom == .pad
    }
}
