//
//  Extensions.swift
//  Retro
//
//  Created by Atilla Özder on 9.04.2020.
//  Copyright © 2020 Atilla Özder. All rights reserved.
//

import UIKit
import SpriteKit

// MARK: - UserDefaults
extension UserDefaults {
    
    var score: Int {
       return integer(forKey: "score")
    }
    
    var highscore: Int {
        return integer(forKey: "best_score")
    }
    
    var session: Double {
        return double(forKey: "session")
    }
    
    var isSoundOn: Bool {
        return integer(forKey: "sound_preference") == 0
    }
    
    func setScore(_ score: Int) {
        set(score, forKey: "score")
        setHighscore(score)
    }
    
    func setHighscore(_ score: Int) {
        if score > highscore {
            set(score, forKey: "best_score")
        }
    }
    
    func setSession(_ newValue: Double? = nil) {
        let value = newValue ?? (session + 1.0)
        set(value, forKey: "session")
    }
        
    func setSound(_ sound: Bool) {
        set(!sound, forKey: "sound_preference")
    }
    
    var player: String {
        return string(forKey: "player") ?? "car0"
    }
    
    func setPlayer(_ player: String) {
        set(player, forKey: "player")
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
    
    class var menuButton: UIColor {
        return UIColor(red: 17, green: 52, blue: 68)
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

// MARK: - FontNameRepresentable
protocol FontNameRepresentable {
    var fontName: String { get }
}

enum AmericanTypeWriter: String, FontNameRepresentable {
    case bold = "-Bold"
    case semibold = "-Semibold"
    case condensed = "-Condensed"
    case condensedBold = "-CondensedBold"
    case light = "-Light"
    case regular = ""
    
    var fontName: String {
        return "AmericanTypewriter\(rawValue)"
    }
}

// MARK: - UIFont
extension UIFont {
    static func buildFont(name: String, size: CGFloat) -> UIFont {
        guard let font = UIFont(name: name, size: size) else {
            return .boldSystemFont(ofSize: size)
        }
        
        if #available(iOS 11.0, *) {
            return UIFontMetrics.default.scaledFont(for: font)
        }
        
        return font
    }
    
    static func buildFont(
        _ font: FontNameRepresentable = AmericanTypeWriter.bold,
        withSize size: CGFloat? = nil) -> UIFont {
        let defaultSize: CGFloat = UIDevice.current.isPad ? 26 : 20
        let aSize: CGFloat = size == nil ? defaultSize : size!
        return buildFont(name: font.fontName, size: aSize)
    }
}

// MARK: - UIView
extension UIView {
    static let soundButtonID: Int = 1000
    
    func addTapGesture(target: Any?, action: Selector) {
        let tapGesture = UITapGestureRecognizer(target: target, action: action)
        self.isUserInteractionEnabled = true
        self.addGestureRecognizer(tapGesture)
    }
    
    func scale(_ factor: CGFloat = 0.9, withDuration duration: TimeInterval = 0.1) {
        UIView.animate(withDuration: duration, animations: {
            self.transform = .init(scaleX: factor, y: factor)
        }) { (finished) in
            UIView.animate(withDuration: duration) {
                self.transform = .identity
            }
        }
    }
}

// MARK: - CGSize
extension CGSize {
    static func initialize(_ constant: CGFloat) -> CGSize {
        return .init(width: constant, height: constant)
    }
}

// MARK: - UIEdgeInsets
extension UIEdgeInsets {
    static func initialize(_ constant: CGFloat) -> UIEdgeInsets {
        return .init(top: constant, left: constant, bottom: constant, right: constant)
    }
}

// MARK: - NSNotification
extension NSNotification.Name {
    static let shouldStayPausedNotification = Notification.Name("shouldStayPausedNotification")
}
