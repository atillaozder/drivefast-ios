//
//  GarageCollectionViewCell.swift
//  DriveFast
//
//  Created by Atilla Özder on 25.09.2020.
//  Copyright © 2020 Atilla Özder. All rights reserved.
//

import UIKit

// MARK: - GarageCollectionViewCell

final class GarageCollectionViewCell: UICollectionViewCell {
    
    static var reuseId: String {
        "GarageCollectionViewCell"
    }

    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.backgroundColor = .clear
        return imageView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    private func setup() {
        contentView.addSubview(imageView)
        imageView.pinEdgesToSuperview()
    }
    
    func configure(with car: Car) {
        imageView.image = UIImage(named: car.imageName)
    }
}
