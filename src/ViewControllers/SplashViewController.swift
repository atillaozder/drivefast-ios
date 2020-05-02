//
//  SplashViewController.swift
//  DriveFast
//
//  Created by Atilla Özder on 2.05.2020.
//  Copyright © 2020 Atilla Özder. All rights reserved.
//

import UIKit
import Firebase

class SplashViewController: UIViewController {
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    let loadingProgress: UIProgressView = {
        let pv = UIProgressView(progressViewStyle: .default)
        pv.progressTintColor = .systemYellow
        pv.trackTintColor = UIColor.systemRed.withAlphaComponent(0.6)
        pv.layer.cornerRadius = 13
        pv.layer.borderColor = UIColor.systemRed.cgColor
        pv.layer.borderWidth = 1
        pv.layer.masksToBounds = true
        pv.progress = 0.0
        return pv
    }()
    
    var progress: Float {
        get { return loadingProgress.progress }
        set {
            self.loadingProgress.progress = newValue
            if newValue > 1 {
                guard presentedViewController == nil else { return }
                self.presentGameController()
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .roadColor
                
        let stackView = UIStackView()
        stackView.alignment = .center
        stackView.distribution = .fill
        stackView.axis = .vertical
        stackView.spacing = 12
        
        let imageView = UIImageView(image: Asset.splash.imageRepresentation())
        imageView.contentMode = .scaleAspectFit
        imageView.pinSize(to: .initialize(160))
        imageView.layer.cornerRadius = 16
        imageView.layer.borderWidth = 1
        imageView.layer.borderColor = UIColor(red: 250, green: 250, blue: 250).cgColor
        imageView.clipsToBounds = true
        stackView.addArrangedSubview(imageView)

        let titleLabel = UILabel()
        titleLabel.text = "DRIVE FAST"
        titleLabel.font = .buildFont(AmericanTypeWriter.bold, withSize: 24)
        titleLabel.textAlignment = .center
        titleLabel.textColor = .white
        stackView.addArrangedSubview(titleLabel)
        
        let spacer = UIView()
        spacer.pinHeight(to: 24)
        stackView.addArrangedSubview(spacer)
        
        let loadingTitleLabel = UILabel()
        loadingTitleLabel.text = MainStrings.loadingTitle.localized
        loadingTitleLabel.font = .buildFont(AmericanTypeWriter.semibold, withSize: 18)
        loadingTitleLabel.textAlignment = .center
        loadingTitleLabel.textColor = .white
        
        let rootStackView = UIStackView()
        rootStackView.alignment = .fill
        rootStackView.distribution = .fill
        rootStackView.axis = .vertical
        rootStackView.spacing = 12
        
        rootStackView.addArrangedSubview(stackView)
        rootStackView.addArrangedSubview(loadingProgress)
        rootStackView.addArrangedSubview(loadingTitleLabel)

        loadingProgress.pinHeight(to: 26)
        
        view.addSubview(rootStackView)
        rootStackView.pinCenterOfSuperview()
        rootStackView.pinWidth(to: view.heightAnchor, multiplier: 1/2)
        
        startLoading()
    }
    
    private func startLoading() {
        FirebaseApp.configure()
        GADMobileAds.sharedInstance().start(completionHandler: nil)
        
        UserDefaults.standard.setSession()
        GameManager.shared.preloadExplosion()
        GameManager.shared.preloadCars { [weak self] (value) in
            guard let `self` = self else { return }
            self.progress += 0.05
        }
    }
    
    private func presentGameController() {
        let viewController = GameViewController()
        viewController.modalTransitionStyle = .crossDissolve
        viewController.modalPresentationStyle = .fullScreen
        self.present(viewController, animated: true, completion: nil)
    }
}
