//
//  UIView+Autolayout.swift
//  DriveFast
//
//  Created by Atilla Özder on 13.04.2020.
//  Copyright © 2020 Atilla Özder. All rights reserved.
//

import UIKit

extension UIView {
    
    var safeTopAnchor: NSLayoutYAxisAnchor {
        if #available(iOS 11, *) {
            return safeAreaLayoutGuide.topAnchor
        }
        return topAnchor
    }
    
    var safeBottomAnchor: NSLayoutYAxisAnchor {
        if #available(iOS 11, *) {
            return safeAreaLayoutGuide.bottomAnchor
        }
        return bottomAnchor
    }
    
    var safeLeadingAnchor: NSLayoutXAxisAnchor {
        if #available(iOS 11, *) {
            return safeAreaLayoutGuide.leadingAnchor
        }
        return leadingAnchor
    }
    
    var safeTrailingAnchor: NSLayoutXAxisAnchor {
        if #available(iOS 11, *) {
            return safeAreaLayoutGuide.trailingAnchor
        }
        return trailingAnchor
    }
    
    var safeLeftAnchor: NSLayoutXAxisAnchor {
        if #available(iOS 11, *) {
            return safeAreaLayoutGuide.leftAnchor
        }
        return leftAnchor
    }
    
    var safeRightAnchor: NSLayoutXAxisAnchor {
        if #available(iOS 11, *) {
            return safeAreaLayoutGuide.rightAnchor
        }
        return rightAnchor
    }
    
    @discardableResult
    func pinCenterX(
        to: NSLayoutAnchor<NSLayoutXAxisAnchor>,
        constant: CGFloat = 0,
        priority: UILayoutPriority = .required) -> NSLayoutConstraint
    {
        self.translatesAutoresizingMaskIntoConstraints = false
        let c = self.centerXAnchor.constraint(equalTo: to, constant: constant)
        c.priority = priority
        c.isActive = true
        return c
    }
    
    @discardableResult
    func pinCenterY(
        to: NSLayoutAnchor<NSLayoutYAxisAnchor>,
        constant: CGFloat = 0,
        priority: UILayoutPriority = .required) -> NSLayoutConstraint
    {
        self.translatesAutoresizingMaskIntoConstraints = false
        let c = self.centerYAnchor.constraint(equalTo: to, constant: constant)
        c.priority = priority
        c.isActive = true
        return c
    }
    
    @discardableResult
    func pinTrailing(
        to: NSLayoutAnchor<NSLayoutXAxisAnchor>,
        constant: CGFloat = 0,
        priority: UILayoutPriority = .required) -> NSLayoutConstraint
    {
        self.translatesAutoresizingMaskIntoConstraints = false
        let c = self.trailingAnchor.constraint(equalTo: to, constant: constant)
        c.priority = priority
        c.isActive = true
        return c
    }
    
    @discardableResult
    func pinLeading(
        to: NSLayoutAnchor<NSLayoutXAxisAnchor>,
        constant: CGFloat = 0,
        priority: UILayoutPriority = .required) -> NSLayoutConstraint
    {
        self.translatesAutoresizingMaskIntoConstraints = false
        let c = self.leadingAnchor.constraint(equalTo: to, constant: constant)
        c.priority = priority
        c.isActive = true
        return c
    }
    
    @discardableResult
    func pinLeft(
        to: NSLayoutAnchor<NSLayoutXAxisAnchor>,
        constant: CGFloat = 0,
        priority: UILayoutPriority = .required) -> NSLayoutConstraint
    {
        self.translatesAutoresizingMaskIntoConstraints = false
        let c = self.leftAnchor.constraint(equalTo: to, constant: constant)
        c.priority = priority
        c.isActive = true
        return c
    }
    
    @discardableResult
    func pinRight(
        to: NSLayoutAnchor<NSLayoutXAxisAnchor>,
        constant: CGFloat = 0,
        priority: UILayoutPriority = .required) -> NSLayoutConstraint
    {
        self.translatesAutoresizingMaskIntoConstraints = false
        let c = self.rightAnchor.constraint(equalTo: to, constant: constant)
        c.priority = priority
        c.isActive = true
        return c
    }
    
    @discardableResult
    func pinTop(
        to: NSLayoutAnchor<NSLayoutYAxisAnchor>,
        constant: CGFloat = 0,
        priority: UILayoutPriority = .required) -> NSLayoutConstraint
    {
        self.translatesAutoresizingMaskIntoConstraints = false
        let c = self.topAnchor.constraint(equalTo: to, constant: constant)
        c.priority = priority
        c.isActive = true
        return c
    }
    
    @discardableResult
    func pinBottom(
        to: NSLayoutAnchor<NSLayoutYAxisAnchor>,
        constant: CGFloat = 0,
        priority: UILayoutPriority = .required) -> NSLayoutConstraint
    {
        self.translatesAutoresizingMaskIntoConstraints = false
        let c = self.bottomAnchor.constraint(equalTo: to, constant: constant)
        c.priority = priority
        c.isActive = true
        return c
    }
    
    func pinEdgesToUnsafeArea(insets: UIEdgeInsets = .zero) {
        guard let superView = superview else { return }
        self.pinTop(to: superView.topAnchor, constant: insets.top)
        self.pinBottom(to: superView.bottomAnchor, constant: insets.bottom)
        self.pinTrailing(to: superView.trailingAnchor, constant: insets.right)
        self.pinLeading(to: superView.leadingAnchor, constant: insets.left)
    }
    
    func pinEdgesToSuperview(insets: UIEdgeInsets = .zero) {
        guard let superView = superview else { return }
        pinEdgesToView(superView, insets: insets)
    }
    
    func pinEdgesToView(_ view: UIView,
                        insets: UIEdgeInsets = .zero,
                        exclude: [NSLayoutConstraint.Attribute] = []) {
        self.translatesAutoresizingMaskIntoConstraints = false
        let dims = [
            leadingAnchor.constraint(equalTo: view.safeLeadingAnchor, constant: insets.left),
            topAnchor.constraint(equalTo: view.safeTopAnchor, constant: insets.top),
            bottomAnchor.constraint(equalTo: view.safeBottomAnchor, constant: insets.bottom),
            trailingAnchor.constraint(equalTo: view.safeTrailingAnchor, constant: insets.right)
        ]
        
        let constraints = dims.filter { !exclude.contains($0.firstAttribute) }
        NSLayoutConstraint.activate(constraints)
    }
    
    func pinCenterOfSuperview(insets: UIEdgeInsets = .zero) {
        guard let superView = superview else { return }
        self.pinCenterX(to: superView.centerXAnchor)
        self.pinCenterY(to: superView.centerYAnchor)
    }
}

extension UIView {
    
    @discardableResult
    private func pin(
        _ anchor: NSLayoutDimension,
        to dim: NSLayoutDimension? = nil,
        constant: CGFloat = 0,
        multiplier: CGFloat = 1,
        priority: UILayoutPriority) -> NSLayoutConstraint
    {
        self.translatesAutoresizingMaskIntoConstraints = false
        let constraint: NSLayoutConstraint
        
        if let dimension = dim {
            constraint = anchor.constraint(equalTo: dimension, multiplier: multiplier)
        } else {
            constraint = anchor.constraint(equalToConstant: constant)
        }
        
        constraint.priority = priority
        constraint.isActive = true
        return constraint
    }
    
    @discardableResult
    func makeSquare(constant: CGFloat) -> (width: NSLayoutConstraint, height: NSLayoutConstraint ){
        let w = self.pinWidth(to: constant)
        let h = self.pinHeight(to: constant)
        return (w, h)
    }
    
    @discardableResult
    func pinSize(to size: CGSize) -> (width: NSLayoutConstraint, height: NSLayoutConstraint) {
        let w = self.pinWidth(to: size.width)
        let h = self.pinHeight(to: size.height)
        return (w, h)
    }
    
    @discardableResult
    func pinHeight(to anchor: NSLayoutDimension,
                   priority: UILayoutPriority = .required,
                   multiplier: CGFloat = 1) -> NSLayoutConstraint {
        return self.pin(heightAnchor, to: anchor, multiplier: multiplier, priority: priority)
    }
    
    @discardableResult
    func pinHeight(to constant: CGFloat, priority: UILayoutPriority = .required) -> NSLayoutConstraint {
        return self.pin(heightAnchor, constant: constant, priority: priority)
    }
    
    @discardableResult
    func pinWidth(to anchor: NSLayoutDimension,
                  priority: UILayoutPriority = .required,
                  multiplier: CGFloat = 1) -> NSLayoutConstraint {
        return self.pin(widthAnchor, to: anchor, multiplier: multiplier, priority: priority)
    }
    
    @discardableResult
    func pinWidth(to constant: CGFloat, priority: UILayoutPriority = .required) -> NSLayoutConstraint {
        return self.pin(widthAnchor, constant: constant, priority: priority)
    }
}
