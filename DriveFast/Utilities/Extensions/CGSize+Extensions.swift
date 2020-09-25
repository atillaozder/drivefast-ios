//
//  CGSize+Extensions.swift
//  DriveFast
//
//  Created by Atilla Özder on 25.09.2020.
//  Copyright © 2020 Atilla Özder. All rights reserved.
//

import UIKit

// MARK: - CGSize

extension CGSize {
    static func initialize(_ constant: CGFloat) -> CGSize {
        return .init(width: constant, height: constant)
    }
}
