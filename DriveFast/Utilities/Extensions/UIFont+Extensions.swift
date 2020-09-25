//
//  UIFont+Extensions.swift
//  DriveFast
//
//  Created by Atilla Özder on 25.09.2020.
//  Copyright © 2020 Atilla Özder. All rights reserved.
//

import UIKit

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
        _ font: FontNameRepresentable = Fonts.AmericanTypeWriter.bold,
        withSize size: CGFloat? = nil) -> UIFont {
        return buildFont(name: font.fontName, size: size ?? 16)
    }
}
