//
//  AdHelper.swift
//  DriveFast
//
//  Created by Atilla Özder on 17.04.2020.
//  Copyright © 2020 Atilla Özder. All rights reserved.
//

import Foundation
import GoogleMobileAds

protocol AdHelperDelegate: AnyObject {
    func adHelper(_ adHelper: AdHelper, userDidEarn reward: GADAdReward?)
    func adHelper(_ adHelper: AdHelper, willPresentRewardedAd isReady: Bool)
}

// MARK: - AdHelper
class AdHelper: NSObject {
    static var interstitialID: String {
        #if DEBUG
        return "ca-app-pub-3940256099942544/4411468910"
        #else
        return "ca-app-pub-3176546388613754/6987129300"
        #endif
    }
    
    static var rewardedAdID: String {
        #if DEBUG
        return "ca-app-pub-3940256099942544/1712485313"
        #else
        return "ca-app-pub-3176546388613754/7634389777"
        #endif
    }
    
    weak var delegate: AdHelperDelegate?
        
    private var rootViewController: UIViewController!
    private var rewardedAd: GADRewardedAd!
    private var interstitial: GADInterstitial!
    private var reward: GADAdReward?

    init(rootViewController: UIViewController) {
        self.rootViewController = rootViewController
        super.init()
        loadRewardedAd()
        self.interstitial = buildInterstitial()
    }
    
    func presentRewardedAd() {
        delegate?.adHelper(self, willPresentRewardedAd: rewardedAd.isReady)
        rewardedAd.isReady ?
            rewardedAd.present(fromRootViewController: rootViewController, delegate: self) :
            loadRewardedAd()
    }
    
    func presentInterstitial() {
        interstitial.isReady ?
            interstitial.present(fromRootViewController: rootViewController) :
            interstitial.load(.init())
    }
    
    private func loadRewardedAd() {
        rewardedAd = GADRewardedAd(adUnitID: AdHelper.rewardedAdID)
        rewardedAd.load(.init()) { (error) in
            if let err = error {
                print(err.localizedDescription)
            }
        }
    }
    
    private func buildInterstitial() -> GADInterstitial {
        let interstitial = GADInterstitial(adUnitID: AdHelper.interstitialID)
        interstitial.load(.init())
        interstitial.delegate = self
        return interstitial
    }
}

extension AdHelper: GADInterstitialDelegate {
    func interstitialDidDismissScreen(_ ad: GADInterstitial) {
        self.interstitial = buildInterstitial()
    }
}

extension AdHelper: GADRewardedAdDelegate {
    func rewardedAd(_ rewardedAd: GADRewardedAd, userDidEarn reward: GADAdReward) {
        self.reward = reward
    }
    
    func rewardedAdDidDismiss(_ rewardedAd: GADRewardedAd) {
        delegate?.adHelper(self, userDidEarn: reward)
        reward = nil
        loadRewardedAd()
    }
}
