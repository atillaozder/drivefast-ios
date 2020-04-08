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

// MARK: - ViewKey
enum ViewKey: String {
    case newGame = "new_game"
    case advertisement = "advertisement"
}

// MARK: - SKViewFactory
struct SKViewFactory {

    static let fontName: String = "AmericanTypewriter-semibold"
    
    private var id: String {
        return Locale.current.identifier == "tr_TR" ? "tr" : "en"
    }
    
    func buildScoreLabel(in rect: CGRect) -> SKLabelNode {
        let lbl = SKLabelNode(fontNamed: SKViewFactory.fontName)
        lbl.fontSize = UIDevice.current.isPad ? 36 : 24
        lbl.position = CGPoint(x: rect.midX, y: 0)
        lbl.zPosition = 999
        return lbl
    }

    func buildNewGameButton(in rect: CGRect) -> SKSpriteNode {
        let imageName = "newgame_" + id
        let btn = SKSpriteNode(imageNamed: imageName)
        let size: CGSize = UIDevice.current.isPad ?
            .init(width: 300, height: 75) :
            .init(width: 200, height: 50)
        
        btn.aspectFit(to: size)
        btn.position = .init(x: rect.midX, y: rect.midY + (size.height / 2))
        btn.zPosition = 999
        btn.name = ViewKey.newGame.rawValue
        return btn
    }
    
    func buildAdvertisementButton(in rect: CGRect) -> SKSpriteNode {
        let imageName = "adv_" + id
        let btn = SKSpriteNode(imageNamed: imageName)
        let size: CGSize = UIDevice.current.isPad ?
            .init(width: 300, height: 120) :
            .init(width: 200, height: 80)
        
        btn.aspectFit(to: size)
        
        let midY = rect.midY - 25 - 32
        let posY = UIDevice.current.isPad ? midY - 24 : midY
        btn.position = .init(x: rect.midX, y: posY)
        
        btn.zPosition = 999
        btn.name = ViewKey.advertisement.rawValue
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
    func aspectFill(to size: CGSize) {
        if texture != nil {
            let textureSize = self.texture!.size()
            self.size = textureSize
            let vRatio = size.height / textureSize.height
            let hRatio = size.width /  textureSize.width
            let ratio = max(hRatio, vRatio)
            self.setScale(ratio)
        }
    }
    
    func aspectFit(to size: CGSize) {
        if texture != nil {
            let textureSize = self.texture!.size()
            self.size = textureSize
            let vRatio = size.height / textureSize.height
            let hRatio = size.width /  textureSize.width
            let ratio = min(hRatio, vRatio)
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
