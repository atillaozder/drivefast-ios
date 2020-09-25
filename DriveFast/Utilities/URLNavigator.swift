//
//  URLNavigator.swift
//  DriveFast
//
//  Created by Atilla Özder on 25.09.2020.
//  Copyright © 2020 Atilla Özder. All rights reserved.
//

import UIKit

// MARK: - URLNavigator

struct URLNavigator {
        
    init() {}
    
    @discardableResult
    func open(_ url: URL) -> Bool {
        let application = UIApplication.shared
        guard application.canOpenURL(url) else { return false }
        
        if #available(iOS 10.0, *) {
            application.open(url, options: [:], completionHandler: nil)
        } else {
            application.openURL(url)
        }
        
        return true
    }
    
    @discardableResult
    func open(_ urlString: String) -> Bool {
        guard let url = urlString.asURL else { return false }
        return open(url)
    }
}
