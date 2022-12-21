//
//  NowPlayingBarStepView.swift
//  SubPetal
//
//  Created by alexiscn on 2022/6/3.
//

import UIKit
import SubsonicKit

protocol NowPlayingBarStepViewDelegate: AnyObject {
 
    func nowPlayingStepViewDidChangeItem(_ item: Song)
    
}

class NowPlayingBarStepView: UIView {
    
    weak var delegate: NowPlayingBarStepViewDelegate?
    
    enum Section { case main }
    
    private var collectionView: UICollectionView!
    
    private var dataSource: [Song] {
        return AudioPlayerManager.shared.queue.songs
    }
    
    private var currentIndex = 0
    
    var isScrollEnabled: Bool = true {
        didSet {
            collectionView.isScrollEnabled = isScrollEnabled
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupCollectionView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupCollectionView() {
     
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.showsVerticalScrollIndicator = false
        collectionView.alwaysBounceVertical = false
        collectionView.alwaysBounceHorizontal = false
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.isPagingEnabled = true
        collectionView.register(UICollectionViewListCell.self,
                                forCellWithReuseIdentifier: NSStringFromClass(UICollectionViewListCell.self))
        addSubview(collectionView)
        
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            collectionView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            collectionView.topAnchor.constraint(equalTo: self.topAnchor),
            collectionView.widthAnchor.constraint(equalTo: self.widthAnchor),
            collectionView.heightAnchor.constraint(equalTo: self.heightAnchor)
        ])
    }
    
    func updatePlayingItem(_ item: Song) {
        guard let index = dataSource.firstIndex(where: { $0.id == item.id }) else { return }
        currentIndex = index
        let indexPath = IndexPath(item: index, section: 0)
        collectionView.scrollToItem(at: indexPath, at: .centeredVertically, animated: false)
    }
    
    func invalidateLayout() {
        collectionView.collectionViewLayout.invalidateLayout()
        DispatchQueue.main.async {
            let offsetX = self.collectionView.bounds.width * CGFloat(self.currentIndex)
            self.collectionView.setContentOffset(CGPoint(x: offsetX, y: 0), animated: false)
        }
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        invalidateLayout()
    }
}

extension NowPlayingBarStepView: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let item = dataSource[indexPath.item]
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: NSStringFromClass(UICollectionViewListCell.self), for: indexPath) as! UICollectionViewListCell
        
        var content = cell.defaultContentConfiguration()
        content.text = item.title
        content.secondaryTextProperties.color = .secondaryLabel
        cell.contentConfiguration = content
        cell.backgroundConfiguration = .clear()
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return collectionView.bounds.size
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let index = Int(scrollView.contentOffset.x / scrollView.bounds.width)
        if index >= 0 && index < dataSource.count {
            delegate?.nowPlayingStepViewDidChangeItem(dataSource[index])
        }
        currentIndex = index
    }
}
