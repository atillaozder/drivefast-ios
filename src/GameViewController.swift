//
//  GameViewController.swift
//  Retro
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
    
    override func loadView() {
        view = SKView(frame: UIScreen.main.bounds)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if #available(iOS 11.0, *) {
            guard let view = self.view as? SKView else { return }
            if let scene = view.scene as? GameScene {
                scene.insets = view.safeAreaInsets
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .roadColor
        self.registerRemoteNotifications()
        interstitial = createInterstitial()
        GADRewardBasedVideoAd.sharedInstance().delegate = self
    }
    
    private func presentMenuScene() {
        if let view = self.view as? SKView {
            let scene = MenuScene(size: view.frame.size)
            scene.backgroundColor = UIColor.roadColor
            scene.sceneDelegate = self
            scene.scaleMode = .aspectFit
            if #available(iOS 11.0, *) {
                scene.insets = view.safeAreaInsets
            }
            view.ignoresSiblingOrder = true
            view.presentScene(scene)
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
            .requestAuthorization(options: options) { [weak self] (_, _) in
                guard let strongSelf = self else { return }

                DispatchQueue.main.async {
                    UIApplication.shared.registerForRemoteNotifications()
                    strongSelf.presentMenuScene()
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
        UserDefaults.standard.setScore(score)
        
        if gameCount.remainder(dividingBy: 2) == 0 {
            interstitial.isReady ?
                interstitial.present(fromRootViewController: self) :
                interstitial.load(.init())
        }
    }
    
    func scene(_ scene: GameScene, shouldPresentMenuScene present: Bool) {
        presentMenuScene()
    }
}
