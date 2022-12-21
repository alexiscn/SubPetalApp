//
//  AlbumListViewController.swift
//  SubPetal
//
//  Created by alexiscn on 2022/6/6.
//

import Foundation
import UIKit
import SubsonicKit
import MJRefresh

class AlbumListViewController: ContextViewController {
    
    let dataProvider: AlbumListDataProvider
    var loadingTask: Task<(), Never>?
    
    init(dataProvider: AlbumListDataProvider) {
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
        applySnapshot()
    }
    
    override func createLayout() -> UICollectionViewLayout {
        return UICollectionViewCompositionalLayout { sectionIndex, layoutEnvironment in
            let contentSize = layoutEnvironment.container.effectiveContentSize
            let count = UIDevice.current.userInterfaceIdiom == .pad ? 5: 2
            let avaliableWidth = contentSize.width - 32 - 15
            let itemWidth = floor(avaliableWidth / CGFloat(count))
            let itemHeight = itemWidth + 42
            let itemSize = NSCollectionLayoutSize(widthDimension: .absolute(itemWidth), heightDimension: .absolute(itemHeight))
            let item = NSCollectionLayoutItem(layoutSize: itemSize)
            let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(itemHeight))
            let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitem: item, count: count)
            group.interItemSpacing = .fixed(15)
            group.edgeSpacing = NSCollectionLayoutEdgeSpacing(leading: .fixed(0), top: .fixed(0), trailing: .fixed(0), bottom: .fixed(15))
            let section = NSCollectionLayoutSection(group: group)
            section.contentInsets = .init(top: 15, leading: 16, bottom: 15, trailing: 16)
            return section
        }
    }
    
    override func setupDataSource() {
        let cellRegistration = UICollectionView.CellRegistration<GridCell, Item> { (cell, indexPath, item) in
            if let album = item.value as? Album {
                cell.render(album: album)
            }
        }
        dataSource = UICollectionViewDiffableDataSource<Int, Item>(collectionView: collectionView, cellProvider: { collectionView, indexPath, itemIdentifier in
            return collectionView.dequeueConfiguredReusableCell(using: cellRegistration, for: indexPath, item: itemIdentifier)
        })
    }
        
    func applySnapshot(isLoadMore: Bool = false) {
        guard isViewLoaded else { return }
        Task {
            if !isLoadMore {
                activityIndicator.startAnimating()
            }
            let offset = isLoadMore ? dataSource.snapshot().itemIdentifiers.count : 0
            let albums = await dataProvider.loadData(offset: offset)
            if !albums.isEmpty {
                if isLoadMore {
                    let oldItems = dataSource.snapshot().itemIdentifiers.compactMap { $0.value as? Album }
                    let newItems = albums.filter { album in
                        return !oldItems.contains(where: { $0.id == album.id })
                    }
                    
                    var snapshot = dataSource.snapshot(for: 0)
                    snapshot.append(newItems.map { Item(section: 0, value: $0) })
                    await dataSource.apply(snapshot, to: 0, animatingDifferences: false)
                } else {
                    var snapshot = NSDiffableDataSourceSectionSnapshot<Item>()
                    let items = albums.map { Item(section: 0, value: $0) }
                    snapshot.append(items)
                    await dataSource.apply(snapshot, to: 0, animatingDifferences: false)
                }
            }
            activityIndicator.stopAnimating()
            let hasMore = albums.count > 0
            endMJRefresh(hasMore: hasMore)
        }
    }
}

extension AlbumListViewController {
    
    private func setupNavBar() {
        navigationController?.navigationBar.prefersLargeTitles = false
        navigationController?.navigationBar.sizeToFit()
        navigationItem.largeTitleDisplayMode = .never
    }
    
    func configureMJRefresh() {
        let header = RefreshHeader { [unowned self] in
            loadingTask?.cancel()
            applySnapshot()
        }
        collectionView.mj_header = header
        
        let footer = MJRefreshAutoNormalFooter { [unowned self] in
            applySnapshot(isLoadMore: true)
        }
        footer.stateLabel?.isHidden = true
        footer.isRefreshingTitleHidden = true
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
