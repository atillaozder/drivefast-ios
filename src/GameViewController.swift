//
//  GameViewController.swift
//  Retro Car Racing
//
//  Created by Atilla Özder on 10.10.2019.
//  Copyright © 2019 Atilla Özder. All rights reserved.
//

import UIKit
import SpriteKit
import GoogleMobileAds

class GameViewController: UIViewController {
    
    private var reward: GADAdReward?
    private var interstitial: GADInterstitial!

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if #available(iOS 11.0, *) {
            guard let view = self.view as? SKView else { return }
            if let gameScene = view.scene as? GameScene {
                gameScene.safeAreaInsets = view.safeAreaInsets
            }
            
            if let menuScene = view.scene as? MenuScene {
                menuScene.safeAreaInsets = view.safeAreaInsets
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        presentMenuScene()
        interstitial = createInterstitial()
        DispatchQueue.main.async {
            self.registerRemoteNotifications()
        }
        GADRewardBasedVideoAd.sharedInstance().delegate = self
    }
    
    private func presentMenuScene() {
        if let view = self.view as! SKView? {
            let scene = MenuScene(size: view.frame.size)
            scene.sceneDelegate = self
            scene.scaleMode = .aspectFit
            if #available(iOS 11.0, *) {
                scene.safeAreaInsets = view.safeAreaInsets
            }
            view.presentScene(scene)
            view.ignoresSiblingOrder = true
        }
    }

    private func createInterstitial() -> GADInterstitial {
        let interstitial = GADInterstitial(adUnitID: AppDelegate.interstitialIdentifier)
        interstitial.delegate = self
        interstitial.load(.init())
        return interstitial
    }
    
    private func registerRemoteNotifications() {
        let options: UNAuthorizationOptions = [.alert, .badge, .sound]
        UNUserNotificationCenter.current()
            .requestAuthorization(options: options) { (_, _) in
                DispatchQueue.main.async {
                    UIApplication.shared.registerForRemoteNotifications()
                }
        }
    }
    
    override var shouldAutorotate: Bool {
        return false
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .init(arrayLiteral: .portrait)
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
}

extension GameViewController: GADRewardBasedVideoAdDelegate {
    func rewardBasedVideoAd(_ rewardBasedVideoAd: GADRewardBasedVideoAd,
                            didRewardUserWith reward: GADAdReward) {
        self.reward = reward
    }

    func rewardBasedVideoAdDidClose(_ rewardBasedVideoAd: GADRewardBasedVideoAd) {
        if reward != nil {
            if let view = self.view as? SKView,
                let gameScene = view.scene as? GameScene {
                gameScene.continueGame()
            }
            reward = nil
        } else {
            presentMenuScene()
        }
        
        GADRewardBasedVideoAd
            .sharedInstance()
            .load(.init(), withAdUnitID: AppDelegate.rewardBasedVideoAdIdentifier)
    }
}

extension GameViewController: GADInterstitialDelegate {
    func interstitialDidDismissScreen(_ ad: GADInterstitial) {
        interstitial = createInterstitial()
    }
}

extension GameViewController: SceneDelegate {

    func scene(_ scene: GameScene, shouldPresentRewardBasedVideoAd present: Bool) {
        let rewardBasedVideoAd = GADRewardBasedVideoAd.sharedInstance()

        if rewardBasedVideoAd.isReady {
            rewardBasedVideoAd.present(fromRootViewController: self)
        } else {
            presentMenuScene()
            rewardBasedVideoAd
                .load(.init(), withAdUnitID: AppDelegate.rewardBasedVideoAdIdentifier)
        }
    }
    
    func scene(_ scene: GameScene, didFinishGameWithScore score: Int) {
        let defaults = UserDefaults.standard
        defaults.set(score, forKey: Key.score.rawValue)
        let bestScore = defaults.integer(forKey: Key.bestScore.rawValue)
        if score > bestScore {
            defaults.set(score, forKey: Key.bestScore.rawValue)
        }
        
        if gameCount.remainder(dividingBy: 2) == 0 {
            interstitial.isReady ?
                interstitial.present(fromRootViewController: self) :
                interstitial.load(.init())
        }
    }
}
