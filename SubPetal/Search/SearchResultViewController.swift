//
//  SearchResultViewController.swift
//  SubPetal
//
//  Created by alexiscn on 2022/6/3.
//

import UIKit
import SubsonicKit
import MJRefresh

protocol SearchResultViewControllerDelegate: AnyObject {
    func searchResultViewControllerDidSelect(item: AnyHashable)
    func searchResultViewControllerLoadMoreTriggered()
}

class SearchResultViewController: ContextViewController {
    
    enum Section: Int {
        case main
    }
    
    weak var delegate: SearchResultViewControllerDelegate?
    let emptyView = EmptyView(frame: .zero)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.keyboardDismissMode = .onDrag
        configureLoadMore()
        setupEmptyView()
    }
    
    func update(_ items: [AnyHashable]) {
        var snapshot = NSDiffableDataSourceSnapshot<Int, Item>()
        snapshot.appendSections([Section.main.rawValue])
        snapshot.appendItems(items.map { Item(section: Section.main.rawValue, value: $0) }, toSection: Section.main.rawValue)
        dataSource.apply(snapshot, animatingDifferences: false)
        
        emptyView.isHidden = !items.isEmpty
    }
    
    override func createLayout() -> UICollectionViewLayout {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(70))
        let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [item])
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = .init(top: 0, leading: 16, bottom: 15, trailing: 16)
        return UICollectionViewCompositionalLayout(section: section)
    }
    
    override func setupDataSource() {
        let cellRegistration = UICollectionView.CellRegistration<ListCell, Item> { (cell, indexPath, item) in
            if let artist = item.value as? Artist {
                cell.render(artist)
            } else if let album = item.value as? Album {
                cell.render(album)
            } else if let song = item.value as? Song {
                cell.render(song)
            }
        }
        dataSource = UICollectionViewDiffableDataSource<Int, Item>(collectionView: collectionView, cellProvider: { collectionView, indexPath, itemIdentifier in
            return collectionView.dequeueConfiguredReusableCell(using: cellRegistration, for: indexPath, item: itemIdentifier)
        })
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let item = dataSource.itemIdentifier(for: indexPath) else {
            return
        }
        if let song = item.value as? Song {
            let songs = dataSource.snapshot().itemIdentifiers.compactMap { $0.value as? Song }
            if let index = songs.firstIndex(where: { $0.id == song.id }) {
                AudioPlayerManager.shared.play(songs, at: index)
            }
        } else {
            delegate?.searchResultViewControllerDidSelect(item: item.value)
        }
    }
}

// MARK: - Setup
extension SearchResultViewController {
    
    private func configureLoadMore() {
        let footer = MJRefreshAutoFooter { [unowned self] in
            delegate?.searchResultViewControllerLoadMoreTriggered()
        }
        collectionView.mj_footer = footer
    }
    
    private func setupEmptyView() {
        emptyView.label.text = "No results found"
        emptyView.imageView.image = UIImage(named: "logo_80x80_")?.withTintColor(.quaternaryLabel)
        emptyView.isHidden = true
        view.addSubview(emptyView)
        emptyView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            emptyView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyView.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
}
