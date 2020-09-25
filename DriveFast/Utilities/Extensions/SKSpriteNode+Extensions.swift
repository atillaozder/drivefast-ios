//
//  SKSpriteNode+Extensions.swift
//  DriveFast
//
//  Created by Atilla Özder on 25.09.2020.
//  Copyright © 2020 Atilla Özder. All rights reserved.
//

import SpriteKit

// MARK: - SKSpriteNode

extension SKSpriteNode {
    func aspectFill(to size: CGSize) {
        if let texture = self.texture {
            self.size = texture.size()
            let vRatio = size.height / texture.size().height
            let hRatio = size.width /  texture.size().width
            let ratio = max(hRatio, vRatio)
            self.setScale(ratio)
        }
    }
    
    func aspectFit(to size: CGSize) {
        if let texture = self.texture {
            self.size = texture.size()
            let vRatio = size.height / texture.size().height
            let hRatio = size.width /  texture.size().width
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
