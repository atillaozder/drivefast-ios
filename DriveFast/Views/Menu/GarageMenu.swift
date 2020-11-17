//
//  GarageMenu.swift
//  DriveFast
//
//  Created by Atilla Özder on 21.04.2020.
//  Copyright © 2020 Atilla Özder. All rights reserved.
//

import UIKit

// MARK: - GarageMenu

final class GarageMenu: Menu {
    
    // MARK: - Properties
    
    weak var delegate: MenuDelegate?
    
    private var dataSource: [Car] = [] {
        didSet {
            DispatchQueue.main.async {
                self.collectionView.reloadData()
            }
        }
    }
    
    private var itemSize: CGSize {
        return UIDevice.current.isPad ?
            .init(width: 120, height: 180) :
            .init(width: 80, height: 140)
    }
    
    private lazy var collectionView: UICollectionView = buildCollectionView()
    
    override func setup() {
        setupCollectionView()
        setupHorizontalStackView()
        setupButtonStackView()
        loadData()
        
        verticalStackView.spacing = 30
        self.isHidden = true
        super.setup()
    }
    
    // MARK: - Tap Handling
    
    @objc
    private func didTapChoose(_ sender: UIButton) {
        guard let indexPath = collectionView.indexPathsForVisibleItems.first else { return }
        let selectedCar = dataSource[indexPath.item]
        UserDefaults.standard.setPlayerCar(selectedCar)
        delegate?.menu(self, didUpdateGameState: .home)
    }
    
    @objc
    private func didTapBack(_ sender: UIButton) {
        delegate?.menu(self, didUpdateGameState: .home)
    }
    
    @objc
    private func didTapRightButton() {
        guard let ip = collectionView.indexPathsForVisibleItems.first else { return }
        let item = ip.item + 1
        guard item < dataSource.count else { return }
        scroll(at: .init(item: item, section: 0))
    }
    
    @objc
    private func didTapLeftButton() {
        guard let ip = collectionView.indexPathsForVisibleItems.first else { return }
        let item = ip.item - 1
        guard item >= 0 else { return }
        scroll(at: .init(item: item, section: 0))
    }
    
    // MARK: - Private Helper Methods
    
    private func scroll(at indexPath: IndexPath) {
        UIView.animate(withDuration: 0.1) {
            self.collectionView.scrollToItem(
                at: indexPath, at: .centeredHorizontally, animated: false)
        }
    }
    
    private func setupCollectionView() {
        collectionView.register(GarageCollectionViewCell.self,
                                forCellWithReuseIdentifier: GarageCollectionViewCell.reuseId)
        collectionView.dataSource = self
        addSubview(collectionView)
        collectionView.pinSize(to: itemSize)
    }
    
    private func setupHorizontalStackView() {
        let horizontalStackView = UIStackView()
        horizontalStackView.alignment = .center
        horizontalStackView.axis = .horizontal
        horizontalStackView.spacing = 16
        horizontalStackView.distribution = .fill
        
        let leftButton = buildNavigationImageView(for: .left)
        let rightButton = buildNavigationImageView(for: .right)
        
        horizontalStackView.addArrangedSubview(leftButton)
        horizontalStackView.addArrangedSubview(collectionView)
        horizontalStackView.addArrangedSubview(rightButton)
        
        verticalStackView.addArrangedSubview(horizontalStackView)
        leftButton.pinWidth(to: rightButton.widthAnchor)
        leftButton.pinHeight(to: rightButton.heightAnchor)
    }
    
    private func setupButtonStackView() {
        let chooseButton = buildButton(title: .choose)
        chooseButton.addTarget(self, action: #selector(didTapChoose(_:)), for: .touchUpInside)
        backButton.addTarget(self, action: #selector(didTapBack(_:)), for: .touchUpInside)
        
        let buttonVerticalStackView = UIStackView()
        buttonVerticalStackView.alignment = .fill
        buttonVerticalStackView.axis = .vertical
        buttonVerticalStackView.spacing = spacing
        buttonVerticalStackView.distribution = .fill
        buttonVerticalStackView.addArrangedSubview(chooseButton)
        buttonVerticalStackView.addArrangedSubview(backButton)
                
        verticalStackView.addArrangedSubview(buttonVerticalStackView)
    }

    private func buildNavigationImageView(for position: ArrowPosition) -> UIImageView {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.image = position.image
        imageView.tintColor = .systemGray
        
        switch position {
        case .left:
            imageView.addTapGesture(target: self, action: #selector(didTapLeftButton))
        case .right:
            imageView.addTapGesture(target: self, action: #selector(didTapRightButton))
        }
        
        return imageView
    }
    
    private func loadData() {
        DispatchQueue.global().async {
            let player = UserDefaults.standard.playerCar
            var cars = [Car]()
            for idx in 0..<20 {
                let car = Car(index: idx)
                car == player ? cars.insert(car, at: 0) : cars.append(car)
            }
            self.dataSource = cars
        }
    }
    
    private func buildCollectionView() -> UICollectionView {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.itemSize = itemSize
        flowLayout.minimumLineSpacing = 16
        flowLayout.minimumInteritemSpacing = 0
        flowLayout.footerReferenceSize = .zero
        flowLayout.headerReferenceSize = .zero
        flowLayout.scrollDirection = .horizontal
        flowLayout.sectionInset = .zero
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: flowLayout)
        collectionView.bounces = false
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.backgroundColor = .clear
        collectionView.isPagingEnabled = true
        collectionView.isScrollEnabled = false
        return collectionView
    }
}

// MARK: - UICollectionViewDataSource

extension GarageMenu: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: GarageCollectionViewCell.reuseId,
            for: indexPath) as? GarageCollectionViewCell else {
                return .init()
        }

        cell.configure(with: dataSource[indexPath.item])
        return cell
    }
}

// MARK: - ArrowPosition

enum ArrowPosition {
    case left, right
    
    var asset: Asset {
        switch self {
        case .left:
            return .leftArrow
        case .right:
            return .rightArrow
        }
    }
    
    var image: UIImage? {
        return asset.imageRepresentation()?
            .withRenderingMode(.alwaysTemplate)
    }
}
