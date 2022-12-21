//
//  SimilarSongsViewController.swift
//  SubPetal
//
//  Created by alexiscn on 2022/6/12.
//

import UIKit
import SubsonicKit

class SimilarSongsViewController: ContextViewController {
    
    let song: Song
    
    init(song: Song) {
        self.song = song
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavBar()
        applySnapshot()
    }
    
    func setupNavBar() {
        navigationItem.title = "Similar Songs"
        
//        let addToPlaylistItem = UIBarButtonItem(image: UIImage(systemName: "text.badge.plus"), style: .plain, target: self, action: #selector(handleAddToPlaylist))
//        let shuffleItem = UIBarButtonItem(image: UIImage(systemName: "shuffle"), style: .plain, target: self, action: #selector(handleShuffle))
//        navigationItem.rightBarButtonItems = [shuffleItem, addToPlaylistItem]
    }
    
    @objc private func handleAddToPlaylist() {
        presentingViewController?.dismiss(animated: true)
    }
    
    @objc private func handleShuffle() {
        presentingViewController?.dismiss(animated: true)
    }
    
    override func createLayout() -> UICollectionViewLayout {
        return UICollectionViewCompositionalLayout { sectionIndex, layoutEnvironment in
            let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0))
            let item = NSCollectionLayoutItem(layoutSize: itemSize)
            let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(70))
            let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [item])
            group.interItemSpacing = .fixed(15)
            
            let section = NSCollectionLayoutSection(group: group)
            section.contentInsets = .init(top: 0, leading: 16, bottom: 16, trailing: 16)
            return section
        }
    }
    
    override func setupDataSource() {
        let cellRegistration = UICollectionView.CellRegistration<ListCell, Item> { (cell, indexPath, item) in
            if let song = item.value as? Song {
                cell.render(song)
            }
        }
        dataSource = UICollectionViewDiffableDataSource<Int, Item>(collectionView: collectionView, cellProvider: { collectionView, indexPath, itemIdentifier in
            return collectionView.dequeueConfiguredReusableCell(using: cellRegistration, for: indexPath, item: itemIdentifier)
        })
    }
    
    func applySnapshot() {
        
        Task { @MainActor in
            activityIndicator.startAnimating()
            do {
                
                let response = try await Context.current?.client.getSimilarSongs2(id: song.id, count: 30).similarSongs2
                if let songs = response?.song, !songs.isEmpty {
                    var snapshot = NSDiffableDataSourceSnapshot<Int, Item>()
                    snapshot.appendSections([0])
                    snapshot.appendItems(songs.map { Item(section: 0, value: $0) }, toSection: 0)
                    await dataSource.apply(snapshot)
                }
            } catch {
                HUD.show(error: error.localizedDescription)
            }
            activityIndicator.stopAnimating()
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let song = dataSource.itemIdentifier(for: indexPath)?.value as? Song else {
            return
        }
        let songs = dataSource.snapshot().itemIdentifiers.compactMap { $0.value as? Song }
        let index = songs.firstIndex(where: { $0.id == song.id }) ?? 0
        AudioPlayerManager.shared.play(songs, at: index)
    }
}
