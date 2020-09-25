//
//  RoadRect.swift
//  DriveFast
//
//  Created by Atilla Özder on 25.09.2020.
//  Copyright © 2020 Atilla Özder. All rights reserved.
//

import UIKit

// MARK: - RoadRect

struct RoadRect {
    var minY: CGFloat
    var minX: CGFloat
    var maxY: CGFloat
    var maxX: CGFloat
    
    var midX: CGFloat {
        return (maxX - minX) / 2
    }
}
