//
//  PlaylistViewController.swift
//  SubPetal
//
//  Created by alexiscn on 2022/6/9.
//

import UIKit
import SubsonicKit

class PlaylistViewController: UIViewController {
    
    var playlist: Playlist
    var collectionView: UICollectionView!
    var dataSource: UICollectionViewDiffableDataSource<Section, Item>!
    
    enum Section {
        case songs
        case moreAlbums
        case similarAlbums
    }
    
    struct Item: Hashable {
        var section: Section
        var value: AnyHashable
    }
    
    init(playlist: Playlist) {
        self.playlist = playlist
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupNavBar()
        setupCollectionView()
        setupDataSource()
        
        loadPlaylist()
    }
    
    private func loadPlaylist() {
        Task {
            do {
                guard let client = Context.current?.client else { return }
                var snapshot = NSDiffableDataSourceSnapshot<Section, Item>()
                let response = try await client.getPlaylist(id: playlist.id)
                if let songs = response.playlist.entry, !songs.isEmpty {
                    playlist.entry = songs
                    snapshot.appendSections([.songs])
                    let items = songs.map { Item(section: .songs, value: $0) }
                    snapshot.appendItems(items, toSection: .songs)
                    await dataSource.apply(snapshot, animatingDifferences: false)
                }
            } catch {
                print(error)
                HUD.show(error: error.localizedDescription)
            }
        }
    }
}

// MARK: - Setup
extension PlaylistViewController {
    
    private func setupNavBar() {
        
    }
    
    private func setupCollectionView() {
        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: createLayout())
        collectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(collectionView)
        collectionView.delegate = self
    }
    
    private func createLayout() -> UICollectionViewLayout {
        return UICollectionViewCompositionalLayout { sectionIndex, layoutEnvironment in
            let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0))
            let item = NSCollectionLayoutItem(layoutSize: itemSize)
            let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.85), heightDimension: .absolute(54))
            let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [item])
            
            let section = NSCollectionLayoutSection(group: group)
            section.contentInsets = .init(top: 16, leading: 15, bottom: 16, trailing: 15)
            
            if sectionIndex == 0 {
                let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(450))
                let header = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: headerSize, elementKind: UICollectionView.elementKindSectionHeader, alignment: .top)
                section.boundarySupplementaryItems = [header]
            }
            return section
        }
    }
    
    private func setupDataSource() {
        let songCellRegistration = UICollectionView.CellRegistration<AlbumSongListCell, Item> { (cell, indexPath, item) in
            if let song = item.value as? Song {
                cell.render(song)
            }
        }
        let headerRegistration = UICollectionView.SupplementaryRegistration<PlaylistHeaderView>(elementKind: UICollectionView.elementKindSectionHeader) { [weak self] (supplementaryView, kind, indexPath) in
            guard let self = self else { return }
            supplementaryView.delegate = self
            supplementaryView.render(self.playlist)
        }
        dataSource = UICollectionViewDiffableDataSource<Section, Item>(collectionView: collectionView, cellProvider: { collectionView, indexPath, itemIdentifier in
            return collectionView.dequeueConfiguredReusableCell(using: songCellRegistration, for: indexPath, item: itemIdentifier)
        })
        dataSource.supplementaryViewProvider = { (collectionView, kind, indexPath) in
            return collectionView.dequeueConfiguredReusableSupplementary(using: headerRegistration, for: indexPath)
        }
    }
}

// MARK: - UICollectionViewDelegate
extension PlaylistViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
     
        guard let item = dataSource.itemIdentifier(for: indexPath) else {
            return
        }
        if item.section == .songs, let song = item.value as? Song {
            let songs = dataSource.snapshot(for: .songs).items.compactMap { $0.value as? Song }
            if let index = songs.firstIndex(where: { $0.id == song.id }) {
                AudioPlayerManager.shared.play(songs, at: index)
            }
        }
    }
    
}

// MARK: - AlbumProfileHeaderViewDelegate
extension PlaylistViewController: PlaylistHeaderViewDelegate {

    func playlistHeaderPlayAction() {
        guard let songs = playlist.entry, !songs.isEmpty else {
            return
        }
        AudioPlayerManager.shared.play(songs, at: 0)
    }

    func playlistHeaderShuffleAction() {
        guard let songs = playlist.entry, !songs.isEmpty else {
            return
        }
        let index = Int.random(in: 0 ..< songs.count)
        AudioPlayerManager.shared.play(songs, at: index)
    }
}
