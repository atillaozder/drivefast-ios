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
    
    var skView: SKView {
        return self.view as! SKView
    }
    
    private lazy var menuView = MenuView(frame: view.frame)
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override func loadView() {
        view = SKView(frame: UIScreen.main.bounds)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if #available(iOS 11.0, *) {
            if let scene = skView.scene as? GameScene {
                scene.insets = view.safeAreaInsets
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .roadColor
        self.registerRemoteNotifications()
        self.setupMenuView()
        self.presentMenu()

        self.interstitial = createInterstitial()
        GADRewardBasedVideoAd.sharedInstance().delegate = self
    }
    
    private func setupMenuView() {
        self.view.addSubview(menuView)
        self.menuView.newGameButton.addTarget(
            self, action: #selector(didTapNewGame), for: .touchUpInside)
        self.menuView.advertisementButton.addTarget(
            self, action: #selector(didTapAdvertisement), for: .touchUpInside)
    }
    
    @objc
    func didTapNewGame() {
        menuView.isHidden = true
        if let scene = skView.scene as? GameScene {
            scene.presentNewGame()
        }
    }
    
    @objc
    func didTapAdvertisement() {
        menuView.setAdvertisementButtonHidden(true)
        let rewardBasedVideoAd = GADRewardBasedVideoAd.sharedInstance()

        if rewardBasedVideoAd.isReady {
            if let scene = skView.scene as? GameScene {
                scene.willPresentRewardBasedVideoAd()
            }
            rewardBasedVideoAd.present(fromRootViewController: self)
        } else {
            presentMenu()
            rewardBasedVideoAd
                .load(.init(), withAdUnitID: AppDelegate.rewardBasedVideoAdIdentifier)
        }
    }
    
    private func presentMenu() {
        menuView.setScores()
        menuView.isHidden = false
        
        let scene = MenuScene(size: skView.frame.size)
        scene.backgroundColor = UIColor.roadColor
        scene.sceneDelegate = self
        scene.scaleMode = .aspectFit
        if #available(iOS 11.0, *) {
            scene.insets = skView.safeAreaInsets
        }
        skView.ignoresSiblingOrder = true
        skView.presentScene(scene)
    }
    
    func createInterstitial() -> GADInterstitial {
        let interstitial = GADInterstitial(adUnitID: AppDelegate.interstitialIdentifier)
        interstitial.delegate = self
        interstitial.load(.init())
        return interstitial
    }
    
    private func registerRemoteNotifications() {
        if #available(iOS 10.0, *) {
            let options: UNAuthorizationOptions = [.alert, .badge, .sound]
            UNUserNotificationCenter.current()
                .requestAuthorization(options: options) { (_, _) in
                    DispatchQueue.main.async {
                        UIApplication.shared.registerForRemoteNotifications()
                    }
            }
        } else {
            let options: UIUserNotificationType = [.alert, .badge, .sound]
            let settings = UIUserNotificationSettings(types: options, categories: nil)
            UIApplication.shared.registerUserNotificationSettings(settings)
        }
    }
}

extension GameViewController: GADRewardBasedVideoAdDelegate {
    func rewardBasedVideoAd(_ rewardBasedVideoAd: GADRewardBasedVideoAd,
                            didRewardUserWith reward: GADAdReward) {
        self.reward = reward
    }

    func rewardBasedVideoAdDidClose(_ rewardBasedVideoAd: GADRewardBasedVideoAd) {
        if reward != nil {
            if let scene = skView.scene as? GameScene {
                scene.continueGame()
            }
            reward = nil
        } else {
            presentMenu()
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
    func scene(_ scene: GameScene, didFinishGameWithScore score: Double) {
        UserDefaults.standard.setScore(Int(score))
        
        if gameCount.remainder(dividingBy: 2) == 0 {
            interstitial.isReady ?
                interstitial.present(fromRootViewController: self) :
                interstitial.load(.init())
        }
    }
    
    func scene(_ scene: GameScene, didSetGameState state: GameState) {
        switch state {
        case .menu:
            presentMenu()
        case .advertisementMenu:
            menuView.setAdvertisementButtonHidden(false)
        }
    }
}
