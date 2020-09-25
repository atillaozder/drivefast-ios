//
//  AdManager.swift
//  DriveFast
//
//  Created by Atilla Özder on 17.04.2020.
//  Copyright © 2020 Atilla Özder. All rights reserved.
//

import Foundation
import GoogleMobileAds

// MARK: - AdManagerDelegate

protocol AdManagerDelegate: AnyObject {
    func adManager(_ adManager: AdManager, userDidEarn reward: GADAdReward?)
    func adManager(_ adManager: AdManager, willPresentRewardedAd isReady: Bool)
}

// MARK: - AdManager

final class AdManager: NSObject {
    
    // MARK: - Properties
    
    private let interstitialAdID: String
    private let rewardedAdID: String
    private weak var rootViewController: UIViewController!

    private var rewardedAd: GADRewardedAd!
    private var interstitial: GADInterstitial!
    private var reward: GADAdReward?
    private var adRequestInProgress: Bool
    
    weak var delegate: AdManagerDelegate?

    init(rootViewController: UIViewController) {
        self.rootViewController = rootViewController
        self.rewardedAdID = "ca-app-pub-3176546388613754/6713944364"
        self.interstitialAdID = "ca-app-pub-3176546388613754/6987129300"
        self.adRequestInProgress = false
        super.init()
        buildRewardedAd()
        self.interstitial = buildInterstitial()
    }
    
    func presentRewardedAd() {
        delegate?.adManager(self, willPresentRewardedAd: rewardedAd.isReady)

        if rewardedAd.isReady {
            AudioPlayer.shared.pauseMusic()
            rewardedAd.present(fromRootViewController: rootViewController, delegate: self)
        } else {
            guard !adRequestInProgress else { return }
            loadRewardedAd()
        }
    }
    
    func presentInterstitial() {
        if interstitial.isReady {
            AudioPlayer.shared.pauseMusic()
            interstitial.present(fromRootViewController: rootViewController)
        } else {
            interstitial.load(.init())
        }
    }
    
    private func buildRewardedAd() {
        adRequestInProgress = true
        rewardedAd = GADRewardedAd(adUnitID: rewardedAdID)
        loadRewardedAd()
    }
    
    private func loadRewardedAd() {
        rewardedAd.load(.init()) { [weak self] (error) in
            guard let self = self else { return }
            self.adRequestInProgress = false
            if let err = error {
                print(err.localizedDescription)
            }
        }
    }
    
    private func buildInterstitial() -> GADInterstitial {
        let interstitial = GADInterstitial(adUnitID: interstitialAdID)
        interstitial.load(.init())
        interstitial.delegate = self
        return interstitial
    }
}

// MARK: - GADInterstitialDelegate

extension AdManager: GADInterstitialDelegate {
    func interstitialDidDismissScreen(_ ad: GADInterstitial) {
        AudioPlayer.shared.playMusic(.main)
        self.interstitial = buildInterstitial()
    }
    
    func interstitial(_ ad: GADInterstitial,
                      didFailToReceiveAdWithError error: GADRequestError) {
        // Gets the domain from which the error came.
        let errorDomain = error.domain
        // Gets the error code. See
        // https://developers.google.com/admob/ios/api/reference/Enums/GADErrorCode
        // for a list of possible codes.
        let errorCode = error.code
        // Gets an error message.
        // For example "Account not approved yet". See
        // https://support.google.com/admob/answer/9905175 for explanations of
        // common errors.
        let errorMessage = error.localizedDescription
        // Gets additional response information about the request. See
        // https://developers.google.com/admob/ios/response-info for more information.
        let responseInfo = error.userInfo[GADErrorUserInfoKeyResponseInfo] as? GADResponseInfo
        // Gets the underlyingError, if available.
        let underlyingError = error.userInfo[NSUnderlyingErrorKey] as? Error
        
        if let responseInfo = responseInfo {
            print("Received error with domain: \(errorDomain)\ncode: \(errorCode)"
            + "\nmessage: \(errorMessage)\nresponseInfo: \(responseInfo)"
            + "\nunderLyingError: \(underlyingError?.localizedDescription ?? "nil")")
        }
    }
}

// MARK: - GADRewardedAdDelegate

extension AdManager: GADRewardedAdDelegate {
    func rewardedAd(_ rewardedAd: GADRewardedAd, userDidEarn reward: GADAdReward) {
        self.reward = reward
    }
    
    func rewardedAdDidDismiss(_ rewardedAd: GADRewardedAd) {
        AudioPlayer.shared.playMusic(.main)
        delegate?.adManager(self, userDidEarn: reward)
        reward = nil
        buildRewardedAd()
    }
    
    #if DEBUG
    func rewardedAd(_ rewardedAd: GADRewardedAd, didFailToPresentWithError error: Error) {
        print(error.localizedDescription)
    }
    #endif
}
