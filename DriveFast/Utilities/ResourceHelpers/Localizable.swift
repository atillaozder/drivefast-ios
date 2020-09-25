//
//  Localizable.swift
//  DriveFast
//
//  Created by Atilla Özder on 25.09.2020.
//  Copyright © 2020 Atilla Özder. All rights reserved.
//

import Foundation

// MARK: - Strings

enum Strings: String {
    case score = "scoreTitle"
    case highscore = "highscoreTitle"
    case newGame = "newGameTitle"
    case advertisement = "advButtonTitle"
    case settings = "settingsTitle"
    case backToMenu = "backToMenuTitle"
    case rate = "rateTitle"
    case support = "supportTitle"
    case privacy = "privacyTitle"
    case otherApps = "otherAppsTitle"
    case share = "shareTitle"
    case continueTitle = "continueTitle"
    case garage = "garageTitle"
    case choose = "chooseTitle"
    case loading = "loadingTitle"
    case ok = "okTitle"
    case gcErrorMessage = "gcErrorMessage"
    case fuelAlert = "fuelAlert"
    case resetDataSharing = "resetDataSharingConfigurationsTitle"
    
    var localized: String {
        return NSLocalizedString(self.rawValue, comment: "")
    }
    
    var uppercased: String {
        localized.uppercased(with: .current)
    }
    
    var capitalized: String {
        localized.capitalized(with: .current)
    }
}
