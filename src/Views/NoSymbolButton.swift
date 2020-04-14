//
//  NoSymbolButton.swift
//  Retro
//
//  Created by Atilla Özder on 13.04.2020.
//  Copyright © 2020 Atilla Özder. All rights reserved.
//

import UIKit

class NoSymbolButton: UIButton {

    private var shapeLayer: CAShapeLayer?
    
    var noSymbolDrawable: Bool = false {
        didSet {
            layer.setNeedsDisplay()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    private func setup() {
        self.tintAdjustmentMode = .normal
        self.isUserInteractionEnabled = false
        self.layer.masksToBounds = true
        self.tintColor = .white
    }
    
    override func draw(_ layer: CALayer, in ctx: CGContext) {
        if noSymbolDrawable {
            guard self.shapeLayer == nil else { return }
            
            let shapeLayer = CAShapeLayer()
            let lineWidth: CGFloat = UIDevice.current.isPad ? 8 : 4
            
            let path = UIBezierPath()
            path.move(to: CGPoint(x: bounds.minX, y: bounds.maxY))
            path.addLine(to: CGPoint(x: bounds.maxX, y: bounds.minY))
            path.close()

            shapeLayer.strokeColor = UIColor.white.cgColor
            shapeLayer.lineWidth = lineWidth
            shapeLayer.path = path.cgPath
            
            layer.addSublayer(shapeLayer)
            self.shapeLayer = shapeLayer
        } else {
            guard let sublayer = self.shapeLayer else { return }
            sublayer.removeFromSuperlayer()
            self.shapeLayer = nil
        }
    }
}
