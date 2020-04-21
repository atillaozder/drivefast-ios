//
//  GarageMenu.swift
//  Retro
//
//  Created by Atilla Özder on 21.04.2020.
//  Copyright © 2020 Atilla Özder. All rights reserved.
//

import UIKit

class GarageMenu: Menu {
    
    weak var delegate: MenuDelegate?
    
    private let cellID = "cellID"
    
    private var dataSource: [Car] = [] {
        didSet {
            collectionView.reloadData()
        }
    }
    
    private var itemSize: CGSize {
        return UIDevice.current.isPad ?
            .init(width: 120, height: 180) :
            .init(width: 80, height: 140)
    }
    
    lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = itemSize
        layout.minimumLineSpacing = 16
        layout.minimumInteritemSpacing = 0
        layout.footerReferenceSize = .zero
        layout.headerReferenceSize = .zero
        layout.scrollDirection = .horizontal
        layout.sectionInset = .zero
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.bounces = false
        cv.showsVerticalScrollIndicator = false
        cv.showsHorizontalScrollIndicator = false
        cv.backgroundColor = .clear
        cv.isPagingEnabled = true
        cv.isScrollEnabled = false
        return cv
    }()
    
    override func setup() {
        collectionView.register(GarageCollectionCell.self, forCellWithReuseIdentifier: cellID)
        collectionView.dataSource = self
        addSubview(collectionView)
        collectionView.pinSize(to: itemSize)
        
        let arrowGenerator: (_ image: String) -> UIImageView = { (imageName) -> UIImageView in
            let imageView = UIImageView()
            imageView.contentMode = .scaleAspectFit
            imageView.image = UIImage(named: imageName)?.withRenderingMode(.alwaysTemplate)
            imageView.tintColor = .systemGray
            return imageView
        }

        let leftArrow = arrowGenerator("left-arrow")
        leftArrow.addTapGesture(target: self, action: #selector(scrollLeft))

        let rightArrow = arrowGenerator("right-arrow")
        rightArrow.addTapGesture(target: self, action: #selector(scrollRight))
                
        let carStack = UIStackView()
        carStack.alignment = .center
        carStack.axis = .horizontal
        carStack.spacing = 16
        carStack.distribution = .fill
        carStack.addArrangedSubview(leftArrow)
        carStack.addArrangedSubview(collectionView)
        carStack.addArrangedSubview(rightArrow)

        stackView.addArrangedSubview(carStack)
        leftArrow.pinWidth(to: rightArrow.widthAnchor)
        leftArrow.pinHeight(to: rightArrow.heightAnchor)
        
        let chooseButton = buildButton(withTitle: .chooseTitle)
        chooseButton.addTarget(self, action: #selector(didTapChoose(_:)), for: .touchUpInside)
        backButton.addTarget(self, action: #selector(didTapBack(_:)), for: .touchUpInside)

        let buttons = UIStackView()
        buttons.alignment = .fill
        buttons.axis = .vertical
        buttons.spacing = UIDevice.current.isPad ? 22 : 12
        buttons.distribution = .fill
        buttons.addArrangedSubview(chooseButton)
        buttons.addArrangedSubview(backButton)
                
        stackView.addArrangedSubview(buttons)
        stackView.spacing = UIDevice.current.isPad ? 40 : 30
        
        let playersCar = UserDefaults.standard.playersCar
        var cars = [Car]()
        for idx in 0..<20 {
            let aCar = Car(index: idx)
            aCar == playersCar ? cars.insert(aCar, at: 0) : cars.append(aCar)
        }
        
        self.dataSource = cars
        self.isHidden = true
        super.setup()
    }
    
    @objc
    private func scrollRight() {
        guard let ip = collectionView.indexPathsForVisibleItems.first else { return }
        let item = ip.item + 1
        guard item < dataSource.count else { return }
        let indexPath = IndexPath(item: item, section: 0)
        collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
    }
    
    @objc
    private func scrollLeft() {
        guard let ip = collectionView.indexPathsForVisibleItems.first else { return }
        let item = ip.item - 1
        guard item >= 0 else { return }
        let indexPath = IndexPath(item: item, section: 0)
        collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
    }
    
    @objc
    func didTapChoose(_ sender: UIButton) {
        guard let indexPath = collectionView.indexPathsForVisibleItems.first else { return }
        let selectedCar = dataSource[indexPath.item]
        UserDefaults.standard.setPlayersCar(selectedCar)
        delegate?.menu(self, didUpdateGameState: .home)
    }
    
    @objc
    func didTapBack(_ sender: UIButton) {
        delegate?.menu(self, didUpdateGameState: .home)
    }
}

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
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellID, for: indexPath) as? GarageCollectionCell else {
            return .init()
        }

        cell.configure(with: dataSource[indexPath.item])
        return cell
    }
}

class GarageCollectionCell: UICollectionViewCell {
    
    let imageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFit
        iv.backgroundColor = .clear
        return iv
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
