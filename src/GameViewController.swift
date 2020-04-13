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

// MARK: - GameViewController
class GameViewController: UIViewController {
    
    // MARK: - Properties
    
    private var reward: GADAdReward?
    private var interstitial: GADInterstitial!
    
    var skView: SKView {
        return self.view as! SKView
    }
    
    private lazy var menuView = MenuView(frame: view.frame)
    private lazy var advView = AdvView(frame: view.frame)
    private lazy var settingsView = SettingsView(frame: view.frame)
    private lazy var achievementsView = AchievementsView(frame: view.frame)
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    // MARK: - View Life Cycle
    
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
        let scene = SKScene(size: skView.frame.size)
        scene.backgroundColor = .roadColor
        scene.scaleMode = .aspectFit
        skView.presentScene(scene)
        
        self.registerRemoteNotifications()
        self.setupMenuView()
        self.presentMenu()

        self.interstitial = createInterstitial()
        GADRewardBasedVideoAd.sharedInstance().delegate = self
        
        checkSession()
        setupObservers()
    }
    
    // MARK: - Tap Handling
    @objc
    func didTapBack(_ sender: UIButton) {
        sender.scale()
        hideAllMenus(except: menuView)
    }
    
    // MARK: - Private Helper Methods
    private func setupMenuView() {
        self.view.addSubview(menuView)
        menuView.pinEdgesToSuperview()
        menuView.delegate = self
        
        self.view.addSubview(advView)
        advView.pinEdgesToSuperview()
        advView.delegate = self
        advView.backButton.addTarget(
            self, action: #selector(didTapBack(_:)), for: .touchUpInside)
        
        self.view.addSubview(achievementsView)
        achievementsView.pinEdgesToSuperview()
        achievementsView.backButton.addTarget(
            self, action: #selector(didTapBack(_:)), for: .touchUpInside)
        
        self.view.addSubview(settingsView)
        settingsView.pinEdgesToSuperview()
        settingsView.delegate = self
        settingsView.backButton.addTarget(
            self, action: #selector(didTapBack(_:)), for: .touchUpInside)
    }
    
    private func checkSession() {
        if #available(iOS 10.3, *) {
            let session = UserDefaults.standard.session
            guard session > 0 &&
                session.truncatingRemainder(dividingBy: 4) == 0 else {
                    return
            }
            
            DispatchQueue.main.async {
                SKStoreReviewController.requestReview()
            }
        }
    }
    
    private func setupObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(willResignActive), name: UIApplication.willResignActiveNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(didBecomeActive), name: UIApplication.willEnterForegroundNotification, object: nil)
    }
    
    @objc
    private func willResignActive() {
        #warning("willResignActive")
    }
    
    @objc
    private func didBecomeActive() {
        #warning("didBecomeActive")
    }
    
    private func hideAllMenus(except: UIView? = nil) {
        [menuView, advView, settingsView, achievementsView].forEach { (menu) in
            menu.isHidden = menu != except
        }
    }
    
    private func presentMenu() {
        hideAllMenus(except: menuView)
        
        let scene = MenuScene(size: skView.frame.size)
        scene.sceneDelegate = self
        scene.scaleMode = .aspectFit
        if #available(iOS 11.0, *) {
            scene.insets = skView.safeAreaInsets
        }
        
        skView.ignoresSiblingOrder = true
        skView.presentScene(scene)
    }
    
    private func createInterstitial() -> GADInterstitial {
        let interstitial = GADInterstitial(adUnitID: AdvHelper.interstitialIdentifier)
        interstitial.delegate = self
        interstitial.load(.init())
        return interstitial
    }
    
    private func rate() {
        if #available(iOS 10.3, *) {
            SKStoreReviewController.requestReview()
        } else {
            let urlString = "https://itunes.apple.com/app/id\(1483121139)?action=write-review"
            URLNavigator.shared.open(urlString)
        }
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
            .load(.init(), withAdUnitID: AdvHelper.rewardBasedVideoAdIdentifier)
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
        case .advMenu:
            hideAllMenus(except: advView)
        }
    }
}

// MARK: - MenuViewDelegate
extension GameViewController: MenuViewDelegate {
    func menuView(_ menuView: MenuView, didTapMenuButton button: MenuButton) {
        switch button {
        case .newGame:
            hideAllMenus()
            if let scene = skView.scene as? GameScene {
                scene.presentNewGame()
            }
        case .settings:
            hideAllMenus(except: settingsView)
        case .achievements:
            hideAllMenus(except: achievementsView)
        }
    }
}

// MARK: - AdvViewDelegate
extension GameViewController: AdvViewDelegate {
    func advViewDidTapAdvertisement(_ advView: AdvView) {
        let rewardBasedVideoAd = GADRewardBasedVideoAd.sharedInstance()
        if rewardBasedVideoAd.isReady {
            if let scene = skView.scene as? GameScene {
                scene.willPresentRewardBasedVideoAd()
            }
            rewardBasedVideoAd.present(fromRootViewController: self)
        } else {
            presentMenu()
            rewardBasedVideoAd
                .load(.init(), withAdUnitID: AdvHelper.rewardBasedVideoAdIdentifier)
        }
    }
}

// MARK: - SettingsViewDelegate
extension GameViewController: SettingsViewDelegate {
    func settingsView(_ settingsView: SettingsView, didTapSettingButton button: SettingButton) {
        switch button {
        case .rate:
            rate()
        case .moreApp:
            let urlString = "itms-apps://itunes.apple.com/developer/atilla-ozder/id1440770128?mt=8"
            URLNavigator.shared.open(urlString)
        case .privacy:
            let urlString = "http://www.atillaozder.com/privacy-policy"
            URLNavigator.shared.open(urlString)
        case .share:
            if let url = URL(string: "https://apps.apple.com/app/id\(1483121139)") {
                let viewController = UIActivityViewController(
                    activityItems: [url], applicationActivities: nil)
                viewController.popoverPresentationController?.sourceView = self.view
                viewController.popoverPresentationController?.sourceRect = .zero
                self.present(viewController, animated: true, completion: nil)
            }
        case .support:
            let urlString = "http://www.atillaozder.com"
            URLNavigator.shared.open(urlString)
        }
    }
}
