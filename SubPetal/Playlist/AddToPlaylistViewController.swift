//
//  AddToPlaylistViewController.swift
//  SubPetal
//
//  Created by alexiscn on 2022/6/10.
//

import UIKit
import SubsonicKit

class AddToPlaylistViewController: UIViewController {
    
    enum Section { case main }
    
    var collectionView: UICollectionView!
    var dataSource: UICollectionViewDiffableDataSource<Section, Playlist>!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupNavBar()
        setupCollectionView()
        setupDataSource()
    }
    
}

// MARK: - Setup
extension AddToPlaylistViewController {
    
    private func setupNavBar() {
        
    }
    
    private func setupCollectionView() {
        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: createLayout())
        collectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(collectionView)
        collectionView.delegate = self
    }
    
    private func createLayout() -> UICollectionViewLayout {
        return UICollectionViewCompositionalLayout.list(using: .init(appearance: .insetGrouped))
    }
    
    private func setupDataSource() {
        
    }
}

// MARK: - UICollectionViewDelegate
extension AddToPlaylistViewController: UICollectionViewDelegate {
    
}
