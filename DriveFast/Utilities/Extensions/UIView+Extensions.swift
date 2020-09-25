//
//  UIView+Extensions.swift
//  DriveFast
//
//  Created by Atilla Özder on 25.09.2020.
//  Copyright © 2020 Atilla Özder. All rights reserved.
//

import UIKit

// MARK: - UIView

extension UIView {
    
    func viewWithTag(_ tag: Globals.Tags) -> UIView? {
        return viewWithTag(tag.rawValue)
    }
    
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
