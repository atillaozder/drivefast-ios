//
//  BackslashButton.swift
//  DriveFast
//
//  Created by Atilla Özder on 13.04.2020.
//  Copyright © 2020 Atilla Özder. All rights reserved.
//

import UIKit

// MARK: - BackslashButton

class BackslashButton: UIButton {

    // MARK: - Properties
    
    private var shapeLayer: CAShapeLayer?
    
    var lineWidth: CGFloat = Globals.borderWidth {
        didSet {
            layer.setNeedsDisplay()
        }
    }
    
    var borderColor: CGColor? = UIColor.white.cgColor {
        didSet {
            layer.setNeedsDisplay()
        }
    }
    
    var backslashDrawable: Bool = false {
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
        self.adjustsImageWhenDisabled = false
        self.adjustsImageWhenHighlighted = false
        self.layer.masksToBounds = true
        self.tintColor = .white
    }
    
    override func draw(_ layer: CALayer, in ctx: CGContext) {
        if backslashDrawable {
            guard self.shapeLayer == nil else { return }
            
            let shapeLayer = CAShapeLayer()
            let path = UIBezierPath()
            path.move(to: CGPoint(x: bounds.minX, y: bounds.maxY))
            path.addLine(to: CGPoint(x: bounds.maxX, y: bounds.minY))
            path.close()

            shapeLayer.strokeColor = borderColor
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
    
    func buildContainer(withSize size: CGSize, cornerRadius: CGFloat) -> UIView {
        let container = UIView()
        container.backgroundColor = .mainColor
        container.clipsToBounds = true
        container.layer.borderWidth = 0
        container.layer.borderColor = nil
                
        let bounds: CGRect = .init(origin: .zero, size: size)
        let path = UIBezierPath(
            roundedRect: bounds,
            byRoundingCorners: .allCorners,
            cornerRadii: .initialize(cornerRadius)).cgPath
        
        if #available(iOS 11.0, *) {
            container.layer.cornerRadius = cornerRadius
        } else {
            let mask = CAShapeLayer()
            mask.path = path
            container.layer.mask = mask
        }
        
        let border = CAShapeLayer()
        border.path = path
        border.fillColor = nil
        border.strokeColor = borderColor
        
        border.lineWidth = lineWidth
        container.layer.addSublayer(border)
        container.pinSize(to: size)

        container.addSubview(self)
        self.pinEdgesToUnsafeArea()
        self.contentEdgeInsets = UIDevice.current.isPad ? .initialize(16) : .initialize(10)
        
        return container
    }
}
