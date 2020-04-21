//
//  Car.swift
//  Retro
//
//  Created by Atilla Özder on 13.04.2020.
//  Copyright © 2020 Atilla Özder. All rights reserved.
//

import UIKit

// MARK: - Car
struct Car: Hashable {
    private var _index: Int
    
    var index: Int {
        return _index
    }
    
    var imageName: String {
        return "car\(index)"
    }
    
    var ratio: CGFloat {
        var value = index > 4 ? scaleRatio + 3 : scaleRatio + 2
        
        // truck
        if index == 20 {
            value -= 2
        }
        
        return UIDevice.current.isPad ? value + 3 : value
    }
    
    init(index: Int) {
        self._index = index
    }
}

extension Car: Equatable {
    static func == (lhs: Self, rhs: Self) -> Bool {
        return lhs._index == rhs._index
    }
}
