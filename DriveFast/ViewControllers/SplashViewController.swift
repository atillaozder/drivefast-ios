//
//  SplashViewController.swift
//  DriveFast
//
//  Created by Atilla Özder on 2.05.2020.
//  Copyright © 2020 Atilla Özder. All rights reserved.
//

import UIKit
import FirebaseCore
import GoogleMobileAds

// MARK: - SplashViewController

final class SplashViewController: UIViewController {
    
    override var preferredStatusBarStyle: UIStatusBarStyle { .lightContent }
    override var prefersStatusBarHidden: Bool { true }
    
    private lazy var loadingProgressView: UIProgressView = {
        buildLoadingProgressView()
    }()
    
    var progress: Float {
        get { return loadingProgressView.progress }
        set {
            self.loadingProgressView.setProgress(newValue, animated: true)
            if newValue >= 1 {
                guard presentedViewController == nil else { return }
                self.presentGameController()
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .road
        
        let innerVerticalStackView = buildInnerVerticalStackView()
        let loadingTitleLabel = buildLoadingTitleLabel()
        
        setupVerticalStackView([innerVerticalStackView, loadingProgressView, loadingTitleLabel])
        loadingProgressView.pinHeight(to: 26)
        startLoading()
    }
    
    // MARK: - Private Helper Methods
    
    private func startLoading() {
        FirebaseApp.configure()
        let adService = GADMobileAds.sharedInstance()
        adService.start(completionHandler: nil)
        #if DEBUG
        adService.requestConfiguration.testDeviceIdentifiers = ["54763374aaf9208f4336c270dfdb1caf"]
        #endif
        
        UserDefaults.standard.setSession()
        GameManager.shared.startLoading()
        GameManager.shared.authenticatePlayer(presentingViewController: self)
        
        GameManager.shared.progress = { [weak self] (progress) in
            guard let `self` = self else { return }
            self.progress = progress
        }
    }
    
    private func presentGameController() {
        let viewController = GameViewController()
        viewController.modalTransitionStyle = .crossDissolve
        viewController.modalPresentationStyle = .fullScreen
        self.present(viewController, animated: true, completion: nil)
    }
    
    private func setupVerticalStackView(_ arrangedSubviews: [UIView]) {
        let verticalStackView = buildVerticalStackView()
        arrangedSubviews.forEach(verticalStackView.addArrangedSubview(_:))
        
        view.addSubview(verticalStackView)
        verticalStackView.pinCenterOfSuperview()
        
        if UIDevice.current.isPad {
            verticalStackView.pinWidth(to: 300)
        } else {
            verticalStackView.pinEdgesToView(
                view, insets: .viewEdge(32), exclude: [.top, .bottom])
        }
    }
    
    private func buildLoadingTitleLabel() -> UILabel {
        let loadingTitleLabel = UILabel()
        loadingTitleLabel.text = Strings.loading.localized
        loadingTitleLabel.font = .systemFont(ofSize: 18, weight: .semibold)
        loadingTitleLabel.textAlignment = .center
        loadingTitleLabel.textColor = .white
        return loadingTitleLabel
    }
    
    private func buildInnerVerticalStackView() -> UIStackView {
        let innerVerticalStackView = buildVerticalStackView(alignment: .center)
        
        let imageView = UIImageView(image: Asset.splash.imageRepresentation())
        imageView.contentMode = .scaleAspectFit
        imageView.pinSize(to: .initialize(160))
        imageView.layer.cornerRadius = 16
        imageView.layer.borderWidth = 1
        imageView.layer.borderColor = UIColor(red: 250, green: 250, blue: 250).cgColor
        imageView.clipsToBounds = true
        innerVerticalStackView.addArrangedSubview(imageView)

        let titleLabel = UILabel()
        titleLabel.text = "DRIVE FAST"
        titleLabel.font = .systemFont(ofSize: 24, weight: .black)
        titleLabel.textAlignment = .center
        titleLabel.textColor = .white
        innerVerticalStackView.addArrangedSubview(titleLabel)
        
        let spacer = UIView()
        spacer.pinHeight(to: 24)
        innerVerticalStackView.addArrangedSubview(spacer)
        
        return innerVerticalStackView
    }
    
    private func buildVerticalStackView(alignment: UIStackView.Alignment = .fill) -> UIStackView {
        let verticalStackView = UIStackView()
        verticalStackView.alignment = alignment
        verticalStackView.distribution = .fill
        verticalStackView.axis = .vertical
        verticalStackView.spacing = 12
        return verticalStackView
    }
    
    private func buildLoadingProgressView() -> UIProgressView {
        let progressView = UIProgressView(progressViewStyle: .default)
        progressView.progressTintColor = .systemYellow
        progressView.trackTintColor = UIColor.systemRed.withAlphaComponent(0.6)
        progressView.layer.cornerRadius = 13
        progressView.layer.borderColor = UIColor.systemRed.cgColor
        progressView.layer.borderWidth = 2
        progressView.layer.masksToBounds = true
        progressView.progress = 0.0
        return progressView
    }
}
