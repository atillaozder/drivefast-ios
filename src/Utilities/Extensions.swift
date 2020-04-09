//
//  Extensions.swift
//  Retro
//
//  Created by Atilla Özder on 9.04.2020.
//  Copyright © 2020 Atilla Özder. All rights reserved.
//

import UIKit
import SpriteKit

// MARK: - SKScene
extension SKScene {
    var scaleRatio: CGFloat {
        return UIDevice.current.isPad ? 6 : 4
    }
}

// MARK: - UserDefaults
extension UserDefaults {
    
    func setScore(_ score: Int) {
        set(score, forKey: "score")
        setBestScore(score)
    }
    
    func getScore() -> Int {
        return integer(forKey: "score")
    }
    
    func setBestScore(_ score: Int) {
        if score > getBestScore() {
            set(score, forKey: "best_score")
        }
    }
    
    func getBestScore() -> Int {
        return integer(forKey: "best_score")
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

// MARK: - UIFont
extension UIFont {
    static let fontName: String = "AmericanTypewriter-semibold"
    
    static func defaultFont(ofSize size: CGFloat) -> UIFont {
        return UIFont(name: fontName, size: size) ?? .systemFont(ofSize: size)
    }
}
