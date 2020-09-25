//
//  Fonts.swift
//  DriveFast
//
//  Created by Atilla Özder on 25.09.2020.
//  Copyright © 2020 Atilla Özder. All rights reserved.
//

import Foundation

// MARK: - FontNameRepresentable

protocol FontNameRepresentable {
    var fontName: String { get }
}

// MARK: - Fonts

struct Fonts {
    
    enum Courier: String, FontNameRepresentable {
        case bold = "-Bold"
        case regular = ""
        
        var fontName: String {
            return "Courier\(rawValue)"
        }
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
}
