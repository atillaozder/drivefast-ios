//
//  BackslashButton.swift
//  DriveFast
//
//  Created by Atilla Özder on 13.04.2020.
//  Copyright © 2020 Atilla Özder. All rights reserved.
//

import UIKit

// MARK: - BackslashButton

final class BackslashButton: UIButton {

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
    
    // MARK: - Constructor
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
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
    
    private func setup() {
        self.tintAdjustmentMode = .normal
        self.isUserInteractionEnabled = false
        self.adjustsImageWhenDisabled = false
        self.adjustsImageWhenHighlighted = false
        self.layer.masksToBounds = true
        self.tintColor = .white
    }
    
    func buildContainer(withSize size: CGSize, cornerRadius: CGFloat) -> UIView {
        let containerView = UIView()
        containerView.backgroundColor = .primary
        containerView.clipsToBounds = true
        containerView.layer.borderWidth = 0
        containerView.layer.borderColor = nil
                
        let bounds: CGRect = .init(origin: .zero, size: size)
        let path = UIBezierPath(
            roundedRect: bounds,
            byRoundingCorners: .allCorners,
            cornerRadii: .initialize(cornerRadius)).cgPath
        
        if #available(iOS 11.0, *) {
            containerView.layer.cornerRadius = cornerRadius
        } else {
            let mask = CAShapeLayer()
            mask.path = path
            containerView.layer.mask = mask
        }
        
        let borderShapeLayer = CAShapeLayer()
        borderShapeLayer.path = path
        borderShapeLayer.fillColor = nil
        borderShapeLayer.strokeColor = borderColor
        
        borderShapeLayer.lineWidth = lineWidth
        containerView.layer.addSublayer(borderShapeLayer)
        containerView.pinSize(to: size)

        containerView.addSubview(self)
        self.pinEdgesToUnsafeArea()
        self.contentEdgeInsets = .initialize(10)
        
        return containerView
    }
}
