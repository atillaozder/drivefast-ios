//
//  GameViewController.swift
//  DriveFast
//
//  Created by Atilla Özder on 10.10.2019.
//  Copyright © 2019 Atilla Özder. All rights reserved.
//

import UIKit
import SpriteKit
import GameKit
import GoogleMobileAds
import UserMessagingPlatform

// MARK: - GameState

enum GameState: Int {
    case playing = 0
    case advertisement = 1
    case adPresented = 2
    case paused = 3
    case continued = 4
    case home
    case settings
    case leaderboard
    case garage
}

// MARK: - GameViewController

final class GameViewController: UIViewController {
    
    // MARK: - Properties
    
    override var preferredStatusBarStyle: UIStatusBarStyle { .lightContent }
    override var prefersStatusBarHidden: Bool { true }
    override var prefersHomeIndicatorAutoHidden: Bool { true }
    
    var skView: SKView {
        return self.view as! SKView
    }
    
    var gameScene: GameScene {
        return skView.scene as? GameScene ?? .init()
    }
    
    private lazy var adManager = AdManager(rootViewController: self)
    private var previousGameState: GameState = .playing
    private var consentManager: ConsentManager!
    
    private var menus: [UIView] {
        return [
            playingMenu, pauseMenu, advertisementMenu,
            settingsMenu, garageMenu, homeMenu]
    }
    
    var gameState: GameState = .home {
        didSet {
            didChangeGameState()
        }
    }
    
    private lazy var homeMenu = HomeMenu()
    private lazy var advertisementMenu = AdvertisementMenu()
    private lazy var settingsMenu = SettingsMenu()
    private lazy var playingMenu = PlayingMenu()
    private lazy var pauseMenu = PauseMenu()
    private lazy var garageMenu = GarageMenu()
    
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
        presentEmptyScene()
        consentManager = ConsentManager()
        consentManager.requestConsent { [weak self] (form) in
            guard let self = self else { return }
            self.handleForm(form)
        }

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(setStayPaused),
            name: .shouldStayPausedNotification,
            object: nil)
    }
            
    @objc
    func setStayPaused() {
        if gameState == .paused || gameState == .advertisement {
            gameScene.setStayPaused()
        }
    }
    
    // MARK: - Private Helper Methods
    
    private func handleForm(_ form: UMPConsentForm?) {
        if let form = form {
            form.present(from: self, completionHandler: { [unowned self] (error) in
                self.loadGame()
                if let err = error {
                    print(err.localizedDescription)
                }
            })
        } else {
            loadGame()
        }
    }
    
    private func loadGame() {
        registerRemoteNotifications()
        setupMenus()
        gameState = .home
        adManager.delegate = self
        requestReviewIfNeeded()
    }
    
    private func didChangeGameState() {
        menus.forEach { $0.isHidden = true }
        let shouldPresentNewMenu = previousGameState.rawValue < 5 && gameState == .home
        
        switch gameState {
        case .advertisement, .adPresented, .paused:
            AudioPlayer.shared.pauseMusic()
        default:
            AudioPlayer.shared.playMusic()
        }
                    
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
            case .leaderboard:
                homeMenu.isHidden = false
                presentLeaderboard()
            case .settings:
                settingsMenu.isHidden = false
            case .playing:
                presentGameScene()
            case .adPresented:
                playingMenu.isHidden = false
                adManager.presentRewardedAd()
            case .paused:
                gameScene.setPausedAndNotify(true)
                playingMenu.isHidden = false
                pauseMenu.isHidden = false
            case .continued:
                gameScene.setPausedAndNotify(false)
                playingMenu.isHidden = false
            case .garage:
                garageMenu.isHidden = false
            }
        }
        
        previousGameState = gameState
    }
    
    private func setupMenus() {
        menus.forEach { (menu) in
            self.view.addSubview(menu)
            menu.pinEdgesToUnsafeArea()
        }

        homeMenu.delegate = self
        advertisementMenu.delegate = self
        playingMenu.delegate = self
        pauseMenu.delegate = self
        settingsMenu.delegate = self
        garageMenu.delegate = self
    }
            
    private func requestReviewIfNeeded() {
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
    
    private func presentLeaderboard() {
        if GameManager.shared.gcEnabled {
            let viewController = GKGameCenterViewController()
            viewController.gameCenterDelegate = self
            viewController.viewState = .leaderboards
            viewController.leaderboardIdentifier = Globals.leaderboardID
            self.present(viewController, animated: true, completion: nil)
        } else {
            let alertController = UIAlertController(
                title: "Drive Fast",
                message: Strings.gcErrorMessage.localized,
                preferredStyle: .alert)
            
            let action = UIAlertAction(title: Strings.ok.capitalized, style: .cancel, handler: nil)
            alertController.addAction(action)
            self.present(alertController, animated: true, completion: nil)
        }
    }
    
    private func presentEmptyScene() {
        let scene = SKScene(size: skView.frame.size)
        scene.backgroundColor = .road
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
        playingMenu.reset()
    }
    
    private func setStateHome() {
        gameState = .home
    }
    
    private func rate() {
        if #available(iOS 10.3, *) {
            DispatchQueue.main.async {
                SKStoreReviewController.requestReview()
            }
        } else {
            let urlString = "https://itunes.apple.com/app/id\(Globals.appID)?action=write-review"
            URLNavigator().open(urlString)
        }
    }
    
    private func share() {
        if let url = URL(string: "https://apps.apple.com/app/id\(Globals.appID)") {
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

// MARK: - AdManagerDelegate

extension GameViewController: AdManagerDelegate {
    func adManager(_ adManager: AdManager, userDidEarn reward: GADAdReward?) {
        reward == nil ? setStateHome() : gameScene.didGetReward()
    }
    
    func adManager(_ adManager: AdManager, willPresentRewardedAd isReady: Bool) {
        isReady ? gameScene.willPresentRewardBasedVideoAd() : setStateHome()
    }
}

// MARK: - SceneDelegate

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
            adManager.presentInterstitial()
        }
    }
    
    func scene(_ scene: GameScene, didUpdateGameState state: GameState) {
        gameState = state
    }
    
    func scene(_ scene: GameScene, didUpdateRemainingFuel fuel: Float) {
        let progress = fuel / 100
        playingMenu.setFuelProgress(progress, animated: progress != 1.0)
    }
}

// MARK: - MenuDelegate

extension GameViewController: MenuDelegate {
    func menu(_ menu: Menu, didUpdateGameState gameState: GameState) {
        self.gameState = gameState
    }
    
    func menu(_ menu: Menu, didSelectOption option: Menu.MenuOption) {
        switch option {
        case .rate:
            rate()
        }
    }
}

// MARK: - SettingsMenuDelegate

extension GameViewController: SettingsMenuDelegate {
    func settingsMenu(_ settingsMenu: SettingsMenu, didSelectOption option: SettingsMenu.Option) {
        switch option {
        case .otherApps, .privacy, .support:
            guard let url = option.url else { return }
            URLNavigator().open(url)
        case .share:
            share()
        case .back:
            gameState = .home
        }
    }
}

// MARK: - GKGameCenterControllerDelegate

extension GameViewController: GKGameCenterControllerDelegate {
    func gameCenterViewControllerDidFinish(_ gameCenterViewController: GKGameCenterViewController) {
        gameCenterViewController.dismiss(animated: true, completion: nil)
    }
}
