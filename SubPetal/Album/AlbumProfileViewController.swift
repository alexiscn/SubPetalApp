//
//  AlbumProfileViewController.swift
//  SubPetal
//
//  Created by alexiscn on 2022/6/2.
//

import UIKit
import SubsonicKit

class AlbumProfileViewController: ContextViewController {
    
    enum Section: Int {
        case songs = 0
        case moreAlbums
        
        var title: String {
            switch self {
            case .songs: return ""
            case .moreAlbums: return "More Albums"
            }
        }
    }
    
    var album: Album
    
    
    var starItem: UIBarButtonItem!
    
    init(album: Album) {
        self.album = album
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupNavBar()
        
        loadAlbum()
    }
    
    override func createLayout() -> UICollectionViewLayout {
        return UICollectionViewCompositionalLayout { [weak self] sectionIndex, layoutEnvironment in
            
            guard let self = self else { return nil }
            let snapshot = self.dataSource.snapshot()
            guard sectionIndex < snapshot.sectionIdentifiers.count else { return nil }
            let sectionKind = snapshot.sectionIdentifiers[sectionIndex]
            
            let group: NSCollectionLayoutGroup
            switch sectionKind {
            case Section.songs.rawValue:
                let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0))
                let item = NSCollectionLayoutItem(layoutSize: itemSize)
                let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.85), heightDimension: .absolute(54))
                group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [item])
            case Section.moreAlbums.rawValue:
                let itemWidth = CGFloat(180)
                let itemHeight = itemWidth + 42
                
                let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0))
                let item = NSCollectionLayoutItem(layoutSize: itemSize)
                let groupSize = NSCollectionLayoutSize(widthDimension: .absolute(itemWidth), heightDimension: .absolute(itemHeight))
                group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
                group.interItemSpacing = .fixed(15)
            default:
                fatalError()
            }
            
            let section = NSCollectionLayoutSection(group: group)
            section.contentInsets = .init(top: 16, leading: 15, bottom: 16, trailing: 15)
            if sectionKind == Section.moreAlbums.rawValue {
                section.orthogonalScrollingBehavior = .continuous
                section.interGroupSpacing = 15
            }
            
            if sectionIndex == 0 {
                let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(450))
                let header = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: headerSize, elementKind: UICollectionView.elementKindSectionHeader, alignment: .top)
                section.boundarySupplementaryItems = [header]
            } else if sectionKind == Section.moreAlbums.rawValue {
                let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(60))
                let header = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: headerSize, elementKind: LibrarySectionHeaderView.reuseIdentifier, alignment: .top)
                section.boundarySupplementaryItems = [header]
            }
            
            return section
        }
    }
    
    override func setupDataSource() {
        let cellRegistration = UICollectionView.CellRegistration<GridCell, Item> { (cell, indexPath, item) in
            if let album = item.value as? Album {
                cell.render(album: album)
            }
        }
        let songCellRegistration = UICollectionView.CellRegistration<AlbumSongListCell, Item> { (cell, indexPath, item) in
            if let song = item.value as? Song {
                cell.render(song)
            }
        }
        let headerRegistration = UICollectionView.SupplementaryRegistration<AlbumProfileHeaderView>(elementKind: UICollectionView.elementKindSectionHeader) { [weak self] (supplementaryView, kind, indexPath) in
            guard let self = self else { return }
            supplementaryView.delegate = self
            supplementaryView.render(self.album)
        }
        let sectionHeaderRegistration = UICollectionView.SupplementaryRegistration<LibrarySectionHeaderView>(elementKind: LibrarySectionHeaderView.reuseIdentifier) { [weak self] (supplementaryView, kind, indexPath) in
            guard let self = self else { return }
            let snapshot = self.dataSource.snapshot()
            guard indexPath.section < snapshot.sectionIdentifiers.count else { return }
            let sectionKind = snapshot.sectionIdentifiers[indexPath.section]
            guard let section = Section(rawValue: sectionKind) else { return }
            supplementaryView.render(title: section.title)
        }
        dataSource = UICollectionViewDiffableDataSource<Int, Item>(collectionView: collectionView, cellProvider: { collectionView, indexPath, itemIdentifier in
            if itemIdentifier.section == Section.moreAlbums.rawValue {
                return collectionView.dequeueConfiguredReusableCell(using: cellRegistration, for: indexPath, item: itemIdentifier)
            }
            return collectionView.dequeueConfiguredReusableCell(using: songCellRegistration, for: indexPath, item: itemIdentifier)
        })
        dataSource.supplementaryViewProvider = { (collectionView, kind, indexPath) in
            if kind == LibrarySectionHeaderView.reuseIdentifier {
                return collectionView.dequeueConfiguredReusableSupplementary(using: sectionHeaderRegistration, for: indexPath)
            } else {
                return collectionView.dequeueConfiguredReusableSupplementary(using: headerRegistration, for: indexPath)
            }
        }
    }
    
    private func loadAlbum() {
        guard let client = Context.current?.client else { return }
        Task {
            activityIndicator.startAnimating()
            do {
                var snapshot = NSDiffableDataSourceSnapshot<Int, Item>()
                
                // load songs
                let response = try await client.getAlbum(id: album.id)
                if let songs = response.album.song, !songs.isEmpty {
                    album.song = songs
                    snapshot.appendSections([Section.songs.rawValue])
                    let items = songs.map { Item(section: Section.songs.rawValue, value: $0) }
                    snapshot.appendItems(items, toSection: Section.songs.rawValue)
                    await dataSource.apply(snapshot, animatingDifferences: false)
                }
                
                // load more albums from artist
                if let artistId = album.artistId {
                    let artistAlbums = try await client.getArtist(id: artistId).artist.album
                    if let artistAlbums = artistAlbums, !artistId.isEmpty {
                        snapshot.appendSections([Section.moreAlbums.rawValue])
                        let items = artistAlbums.map { Item(section: Section.moreAlbums.rawValue, value: $0) }
                        snapshot.appendItems(items, toSection: Section.moreAlbums.rawValue)
                        await dataSource.apply(snapshot, animatingDifferences: false)
                    }
                }
            } catch {
                print(error)
                
                HUD.show(error: error.localizedDescription)
            }
            activityIndicator.stopAnimating()
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let item = dataSource.itemIdentifier(for: indexPath) else {
            return
        }
        if item.section == Section.songs.rawValue, let song = item.value as? Song {
            let songs = dataSource.snapshot(for: Section.songs.rawValue).items.compactMap { $0.value as? Song }
            if let index = songs.firstIndex(where: { $0.id == song.id }) {
                AudioPlayerManager.shared.play(songs, at: index)
            }
        } else if item.section == Section.moreAlbums.rawValue, let album = item.value as? Album {
            let vc = AlbumProfileViewController(album: album)
            navigationController?.pushViewController(vc, animated: true)
        }
    }
}

// MARK: - Setup
extension AlbumProfileViewController {
    
    private func setupNavBar() {
        let starred = album.starred != nil
        let image = starred ? UIImage(systemName: "heart.fill"): UIImage(systemName: "heart")
        starItem = UIBarButtonItem(image: image, style: .plain, target: self, action: #selector(onStarItemClicked))
        navigationItem.rightBarButtonItem = starItem
    }
}

// MARK: - Events
extension AlbumProfileViewController {
    
    @objc private func onStarItemClicked() {
        Task {
            do {
                let indicator = UIActivityIndicatorView(style: .medium)
                indicator.startAnimating()
                navigationItem.rightBarButtonItem = UIBarButtonItem(customView: indicator)
                
                if album.starred == nil {
                    try await Context.current?.client.star(albumId: album.id)
                    album.starred = ISO3601DateFormatter.shared.string(from: Date())
                } else {
                    try await Context.current?.client.unstar(albumId: album.id)
                    album.starred = nil
                }
                setupNavBar()
            } catch {
                HUD.show(error: error.localizedDescription)
            }
        }
    }
    
}

// MARK: - AlbumProfileHeaderViewDelegate
extension AlbumProfileViewController: AlbumProfileHeaderViewDelegate {
    
    func albumProfileHeaderArtistAction() {
        guard let id = album.artistId, let client = Context.current?.client else {
            return
        }
        Task {
            do {
                let response = try await client.getArtist(id: id)
                let vc = ArtistProfileViewController(artist: response.artist)
                navigationController?.pushViewController(vc, animated: true)
            } catch {
                HUD.show(error: error.localizedDescription)
            }
        }
    }
    
    func albumProfileHeaderPlayAction() {
        guard let songs = album.song, !songs.isEmpty else {
            return
        }
        AudioPlayerManager.shared.play(songs, at: 0)
    }
    
    func albumProfileHeaderShuffleAction() {
        guard let songs = album.song, !songs.isEmpty else {
            return
        }
        let index = Int.random(in: 0 ..< songs.count)
        AudioPlayerManager.shared.play(songs, at: index)
    }
}
