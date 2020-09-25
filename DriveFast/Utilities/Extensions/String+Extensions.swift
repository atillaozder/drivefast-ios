//
//  String+Extensions.swift
//  DriveFast
//
//  Created by Atilla Özder on 25.09.2020.
//  Copyright © 2020 Atilla Özder. All rights reserved.
//

import Foundation

// MARK: - String

extension String {
    var asURL: URL? {
        return URL(string: self)
    }
}
