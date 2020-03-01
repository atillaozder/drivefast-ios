//
//  Extensions.swift
//  Retro
//
//  Created by Atilla Özder on 13.10.2019.
//  Copyright © 2019 Atilla Özder. All rights reserved.
//

import SpriteKit
import GameplayKit
import UIKit

extension SKSpriteNode {
    func aspectFill(to size: CGSize) {
        if texture != nil {
            self.size = texture!.size()
            let vRatio = size.height / self.texture!.size().height
            let hRatio = size.width /  self.texture!.size().width
            let ratio = hRatio > vRatio ? hRatio : vRatio
            self.setScale(ratio)
        }
    }
    
    func aspectFill(width: CGFloat) {
        if texture != nil {
            let ratio = width /  texture!.size().width
            self.setScale(ratio)
        }
    }
}

extension SKLabelNode {
    static func buildLabel(text: String, name: String, fontName: String) -> SKLabelNode {
        let lbl = SKLabelNode(fontNamed: fontName)
        lbl.fontSize = 24
        lbl.name = name
        lbl.zPosition = 999
        lbl.text = text
        return lbl
    }
}

extension SKShapeNode {
    static func buildButton(name: String) -> SKShapeNode {
        let btn = SKShapeNode(rectOf: .init(width: 220, height: 50), cornerRadius: 10)
        btn.fillColor = .dark
        btn.strokeColor = .white
        btn.name = name
        btn.zPosition = 998
        return btn
    }
}

extension UIColor {
    class var dark: UIColor {
        return .init(red: 21/255, green: 21/255, blue: 21/255, alpha: 1)
    }
}
