//
//  ArtistListViewController.swift
//  SubPetal
//
//  Created by alexiscn on 2022/6/9.
//

import Foundation
import UIKit
import SubsonicKit
import MJRefresh

class ArtistListViewController: ContextViewController {
    
    let dataProvider: ArtistListDataProvider
    var loadingTask: Task<(), Never>?
    var offset = 0
    
    init(dataProvider: ArtistListDataProvider) {
        self.dataProvider = dataProvider
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavBar()
        configureMJRefresh()
        applyInitialSnapshot()
        applySnapshot()
    }
    
    override func createLayout() -> UICollectionViewLayout {
        return UICollectionViewCompositionalLayout { sectionIndex, layoutEnvironment in
            
            let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0))
            let item = NSCollectionLayoutItem(layoutSize: itemSize)
            let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(54))
            let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [item])
            
            let section = NSCollectionLayoutSection(group: group)
            section.contentInsets = .init(top: 16, leading: 15, bottom: 16, trailing: 15)
            return section
        }
    }
    
    override func setupDataSource() {
        let cellRegistration = UICollectionView.CellRegistration<ListCell, Item> { (cell, indexPath, item) in
            if let artist = item.value as? Artist {
                cell.render(artist)
            }
        }
        
        dataSource = UICollectionViewDiffableDataSource<Int, Item>(collectionView: collectionView, cellProvider: { collectionView, indexPath, itemIdentifier in
            return collectionView.dequeueConfiguredReusableCell(using: cellRegistration, for: indexPath, item: itemIdentifier)
        })
    }
}

extension ArtistListViewController {
    
    private func setupNavBar() {
        navigationController?.navigationBar.prefersLargeTitles = false
        navigationController?.navigationBar.sizeToFit()
        navigationItem.largeTitleDisplayMode = .never
    }
    
    func applyInitialSnapshot() {
        var snapshot = NSDiffableDataSourceSnapshot<Int, Item>()
        snapshot.appendSections([0])
        dataSource.apply(snapshot, animatingDifferences: false)
    }
    
    func applySnapshot(isLoadMore: Bool = false) {
        guard isViewLoaded else { return }
        Task {
            var snapshot = dataSource.snapshot()
            let artists = await dataProvider.loadData(offset: offset)
            if !artists.isEmpty {
                let items = artists.map { Item(section: 0, value: $0) }
                snapshot.appendItems(items, toSection: 0)
                await dataSource.apply(snapshot, animatingDifferences: false)
            }
            endMJRefresh()
        }
    }
}

extension ArtistListViewController {
    
    func configureMJRefresh() {
        let header = RefreshHeader { [unowned self] in
            loadingTask?.cancel()
            applySnapshot()
        }
        collectionView.mj_header = header
        
        let footer = MJRefreshAutoFooter { [unowned self] in
            applySnapshot(isLoadMore: true)
        }
        collectionView.mj_footer = footer
    }
    
    func endMJRefresh(hasMore: Bool = false) {
        collectionView.mj_header?.endRefreshing()
        if hasMore {
            collectionView.mj_footer?.resetNoMoreData()
        } else {
            collectionView.mj_footer?.endRefreshingWithNoMoreData()
        }
    }

}
