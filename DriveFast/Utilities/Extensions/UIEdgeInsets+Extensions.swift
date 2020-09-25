//
//  UIEdgeInsets+Extensions.swift
//  DriveFast
//
//  Created by Atilla Özder on 25.09.2020.
//  Copyright © 2020 Atilla Özder. All rights reserved.
//

import UIKit

// MARK: - UIEdgeInsets

extension UIEdgeInsets {
    static func initialize(_ constant: CGFloat) -> UIEdgeInsets {
        return .init(top: constant, left: constant, bottom: constant, right: constant)
    }
    
    static func viewEdge(_ constant: CGFloat) -> UIEdgeInsets {
        return .init(top: constant, left: constant, bottom: -constant, right: -constant)
    }
}
