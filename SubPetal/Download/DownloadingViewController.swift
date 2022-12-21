//
//  DownloadingViewController.swift
//  SubPetal
//
//  Created by alexiscn on 2022/6/13.
//

import UIKit
import Tiercel

class DownloadingViewController: UIViewController {
    
    enum Section { case main }
    
    var collectionView: UICollectionView!
    var dataSource: UICollectionViewDiffableDataSource<Section, DownloadTask>!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupCollectionView()
        setupDataSource()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        applySnapshot()
    }
    
    private func applySnapshot() {
        
        var snapshot = NSDiffableDataSourceSnapshot<Section, DownloadTask>()
        snapshot.appendSections([.main])
        
        let items = Context.current?.sessionManager.tasks.filter { $0.status != .succeeded } ?? []
        snapshot.appendItems(items, toSection: .main)
        dataSource.apply(snapshot, animatingDifferences: false)
    }
}

// MARK: - Setup
extension DownloadingViewController {
    
    private func setupCollectionView() {
        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: createLayout())
        collectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(collectionView)
    }
    
    private func createLayout() -> UICollectionViewLayout {
        return UICollectionViewCompositionalLayout.list(using: .init(appearance: .plain))
    }
    
    private func setupDataSource() {
        let cellRegistration = UICollectionView.CellRegistration<DownloadingCell, DownloadTask> { (cell, indexPath, item) in
            cell.render(item)
        }
        dataSource = UICollectionViewDiffableDataSource<Section, DownloadTask>(collectionView: collectionView, cellProvider: { collectionView, indexPath, itemIdentifier in
            return collectionView.dequeueConfiguredReusableCell(using: cellRegistration, for: indexPath, item: itemIdentifier)
        })
    }
}
