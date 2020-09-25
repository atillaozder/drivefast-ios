//
//  Toast.swift
//  DriveFast
//
//  Created by Atilla Özder on 20.08.2020.
//  Copyright © 2020 Atilla Özder. All rights reserved.
//

import UIKit

// MARK: - Toast

final class Toast {
    
    static let shared: Toast = .init()

    enum Position {
        case top, middle, bottom
    }
    
    private init() {}
    
    func present(in view: UIView,
                 with message: String,
                 on position: Position = .bottom,
                 duration: TimeInterval = 1.5) {
        if let container = view.viewWithTag(.toast) as? ToastContainer {
            container.setMessage(message)
            container.alpha = 0.0
            present(container, withDuration: duration)
        } else {
            let container = ToastContainer()
            container.pin(to: view, position: position)
            container.setMessage(message)
            present(container, withDuration: duration)
        }
    }
    
    private func present(_ view: UIView, withDuration duration: TimeInterval) {
        UIView.animate(withDuration: 0.15,
                       delay: 0.0,
                       options: .curveEaseOut,
                       animations:
            {
                view.alpha = 1.0
        }, completion: { _ in
            UIView.animate(withDuration: 0.10,
                           delay: duration,
                           options: .curveEaseIn,
                           animations:
                {
                    view.alpha = 0.0
            }, completion: nil)
        })
    }
}

// MARK: - ToastContainer

fileprivate class ToastContainer: View {
        
    lazy var messageLabel: UILabel = {
        let messageLabel = UILabel()
        messageLabel.textColor = .black2
        messageLabel.font = UIFont.systemFont(ofSize: 16)
        messageLabel.textAlignment = .center
        messageLabel.numberOfLines = 2
        messageLabel.lineBreakMode = .byWordWrapping
        messageLabel.preferredMaxLayoutWidth = UIScreen.main.bounds.width - 72
        return messageLabel
    }()
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.layer.cornerRadius = bounds.height / 2
    }
    
    override func setup() {
        super.setup()
        self.backgroundColor = .white
        self.alpha = 0.0
        self.clipsToBounds = true
        self.tag = Globals.Tags.toast.rawValue
        
        self.addSubview(messageLabel)
        let insets: UIEdgeInsets = .init(top: 12, left: 22, bottom: -12, right: -22)
        messageLabel.pinEdgesToSuperview(insets: insets)
    }
    
    fileprivate func pin(to superview: UIView, position: Toast.Position) {
        superview.addSubview(self)
        self.pinCenterX(to: superview.centerXAnchor)
        
        var constant: CGFloat = 32
        var safeAreaInsets: UIEdgeInsets = .zero
        if #available(iOS 11.0, *) {
            safeAreaInsets = superview.safeAreaInsets
        }
        
        switch position {
        case .top:
            constant += safeAreaInsets.top
            self.pinTop(to: superview.topAnchor, constant: constant)
        case .middle:
            self.pinCenterY(to: superview.centerYAnchor)
        case .bottom:
            constant += safeAreaInsets.bottom
            self.pinBottom(to: superview.bottomAnchor, constant: -constant)
        }
    }
    
    fileprivate func setMessage(_ message: String) {
        self.messageLabel.text = message
    }
}
