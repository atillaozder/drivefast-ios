//
//  UIDevice+Extensions.swift
//  DriveFast
//
//  Created by Atilla Özder on 25.09.2020.
//  Copyright © 2020 Atilla Özder. All rights reserved.
//

import UIKit

// MARK: - UIDevice

extension UIDevice {
    var isPad: Bool {
        userInterfaceIdiom == .pad
    }
}
