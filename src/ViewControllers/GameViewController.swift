//
//  GameViewController.swift
//  DriveFast
//
//  Created by Atilla Özder on 10.10.2019.
//  Copyright © 2019 Atilla Özder. All rights reserved.
//

import UIKit
import SpriteKit
import GoogleMobileAds

// MARK: - GameState
enum GameState: Int {
    case playing = 0
    case advertisement = 1
    case advPresenting = 2
    case paused = 3
    case home
    case settings
    case achievements
    case continued
    case garage
}

// MARK: - GameViewController
class GameViewController: UIViewController {
    
    // MARK: - Properties
    var skView: SKView {
        return self.view as! SKView
    }
    
    var gameScene: GameScene {
        return skView.scene as? GameScene ?? .init()
    }
    
    private lazy var adHelper = AdHelper(rootViewController: self)
    private var previousGameState: GameState = .playing
    
    private var menus: [UIView] {
        return [
            playingMenu, pauseMenu, advertisementMenu,
            achievementsMenu, settingsMenu, garageMenu,
            homeMenu]
    }
    
    var gameState: GameState = .home {
        didSet {
            menus.forEach { $0.isHidden = true }
            let shouldPresentNewMenu = previousGameState.rawValue < 4 && gameState == .home
            
            if shouldPresentNewMenu {
                homeMenu.isHidden = false
                presentMenuScene()
            } else {
                switch gameState {
                case .home:
                    homeMenu.isHidden = false
                case .advertisement:
                    playingMenu.isHidden = false
                    advertisementMenu.isHidden = false
                case .achievements:
                    achievementsMenu.isHidden = false
                case .settings:
                    settingsMenu.isHidden = false
                case .playing:
                    presentGameScene()
                case .advPresenting:
                    playingMenu.isHidden = false
                    adHelper.presentRewardedAd()
                case .paused:
                    gameScene.isPaused = true
                    gameScene.didChangePauseState()
                    playingMenu.isHidden = false
                    pauseMenu.isHidden = false
                case .continued:
                    gameScene.isPaused = false
                    gameScene.didChangePauseState()
                    playingMenu.isHidden = false
                case .garage:
                    garageMenu.isHidden = false
                }
            }
            
            previousGameState = gameState
        }
    }
    
    private lazy var homeMenu = HomeMenu()
    private lazy var advertisementMenu = AdvertisementMenu()
    private lazy var settingsMenu = SettingsMenu()
    private lazy var achievementsMenu = AchievementsMenu()
    private lazy var playingMenu = PlayingMenu()
    private lazy var pauseMenu = PauseMenu()
    private lazy var garageMenu = GarageMenu()
    
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
            gameScene.insets = view.safeAreaInsets
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.presentEmptyScene()
        self.registerRemoteNotifications()
        self.setupMenus()
        gameState = .home
        adHelper.delegate = self
        
        AudioPlayer.shared.playMusic(.race)
        checkSession()
        
        NotificationCenter.default.addObserver(self, selector: #selector(setStayPaused), name: .shouldStayPausedNotification, object: nil)
    }
    
    @objc
    func setStayPaused() {
        if gameState == .paused || gameState == .advertisement {
            gameScene.setStayPaused()
        }
    }
    
    // MARK: - Private Helper Methods
    private func setupMenus() {
        menus.forEach { (menu) in
            self.view.addSubview(menu)
            menu.pinEdgesToSuperview()
        }

        homeMenu.delegate = self
        advertisementMenu.delegate = self
        achievementsMenu.delegate = self
        playingMenu.delegate = self
        pauseMenu.delegate = self
        settingsMenu.delegate = self
        garageMenu.delegate = self
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
    
    private func presentEmptyScene() {
        let scene = SKScene(size: skView.frame.size)
        scene.backgroundColor = .roadColor
        scene.scaleMode = .aspectFit
        skView.presentScene(scene)
    }
    
    private func presentMenuScene() {
        let scene = MenuScene(size: skView.frame.size)
        scene.scaleMode = .aspectFit
        if #available(iOS 11.0, *) {
            scene.insets = skView.safeAreaInsets
        }
        
        skView.ignoresSiblingOrder = true
        skView.presentScene(scene)
    }
    
    private func presentGameScene() {
        let scene = GameScene(size: skView.frame.size)
        scene.scaleMode = .aspectFit
        scene.sceneDelegate = self

        if let menuScene = skView.scene as? MenuScene {
            scene.insets = menuScene.insets
        } else {
            if #available(iOS 11.0, *) {
                scene.insets = skView.safeAreaInsets
            }
        }
        
        skView.ignoresSiblingOrder = true
        skView.presentScene(scene)
        playingMenu.setScore(0)
        playingMenu.setLifeCount(3)
        playingMenu.isHidden = false
    }
    
    private func rateTapped() {
        if #available(iOS 10.3, *) {
            DispatchQueue.main.async {
                SKStoreReviewController.requestReview()
            }
        } else {
            let urlString = "https://itunes.apple.com/app/id\(1483121139)?action=write-review"
            URLNavigator.shared.open(urlString)
        }
    }
    
    private func shareTapped() {
        if let url = URL(string: "https://apps.apple.com/app/id\(1483121139)") {
            let viewController = UIActivityViewController(
                activityItems: [url], applicationActivities: nil)
            viewController.popoverPresentationController?.sourceView = self.view
            viewController.popoverPresentationController?.sourceRect = .zero
            self.present(viewController, animated: true, completion: nil)
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

extension GameViewController: AdHelperDelegate {
    private func setStateHome() {
        gameState = .home
    }
    
    func adHelper(_ adHelper: AdHelper, userDidEarn reward: GADAdReward?) {
        AudioPlayer.shared.playMusic(.race)
        reward == nil ? setStateHome() : gameScene.didGetReward()
    }
    
    func adHelper(_ adHelper: AdHelper, willPresentRewardedAd isReady: Bool) {
        AudioPlayer.shared.pauseMusic()
        isReady ? gameScene.willPresentRewardBasedVideoAd() : setStateHome()
    }
}

extension GameViewController: SceneDelegate {
    func scene(_ scene: GameScene, didUpdateScore score: Double) {
        playingMenu.setScore(score)
    }
    
    func scene(_ scene: GameScene, willUpdateLifeCount count: Int) {
        playingMenu.setLifeCount(count)
    }
    
    func scene(_ scene: GameScene, didFinishGameWithScore score: Double) {
        UserDefaults.standard.setScore(Int(score))
        let gameCount = GameManager.shared.gameCount
        if gameCount.remainder(dividingBy: 2) == 0 {
            adHelper.presentInterstitial()
        }
    }
    
    func scene(_ scene: GameScene, didUpdateGameState state: GameState) {
        gameState = state
    }
}

// MARK: - MenuDelegate
extension GameViewController: MenuDelegate {
    func menu(_ menu: Menu, didUpdateGameState gameState: GameState) {
        self.gameState = gameState
    }
    
    func menu(_ menu: Menu, didSelectOption option: MenuOption) {
        switch option {
        case .rate:
            rateTapped()
        }
    }
}

// MARK: - SettingsMenuDelegate
extension GameViewController: SettingsMenuDelegate {
    func settingsMenu(_ settingsMenu: SettingsMenu, didSelectOption option: SettingsMenuOption) {
        switch option {
        case .moreApp:
            let urlString = "itms-apps://itunes.apple.com/developer/atilla-ozder/id1440770128?mt=8"
            URLNavigator.shared.open(urlString)
        case .privacy:
            let urlString = "http://www.atillaozder.com/privacy-policy"
            URLNavigator.shared.open(urlString)
        case .share:
            shareTapped()
        case .support:
            let urlString = "http://www.atillaozder.com"
            URLNavigator.shared.open(urlString)
        case .back:
            gameState = .home
        }
    }
}