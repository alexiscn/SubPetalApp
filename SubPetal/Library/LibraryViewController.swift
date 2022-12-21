//
//  LibraryViewController.swift
//  SubPetal
//
//  Created by alexiscn on 2022/6/1.
//

import UIKit
import SubsonicKit
import MJRefresh

class LibraryViewController: UIViewController {
    
    let welcomeView = WelcomeView(frame: .zero)
    var collectionView: UICollectionView!
    var dataSource: UICollectionViewDiffableDataSource<LibrarySection, LibraryItem>!
    var loadingTask: Task<(), Never>?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupNavBar()
        setupCollectionView()
        setupDataSource()
        setupWelcomeView()
        loadCache()
        applySnapshot()
    }
    
    func applySnapshot() {
        welcomeView.isHidden = Context.current != nil
        guard let client = Context.current?.client else {
            endMJRefresh()
            return
        }
        
        let task = Task {
            await applyNewestAlbums(client: client)
            await applyRandomSongs(client: client)
            await applyStarred(client: client)
            await applyPlaylists(client: client)
            endMJRefresh()
        }
        loadingTask = task
    }
}

extension LibraryViewController {
    
    func configureMJRefresh() {
        let header = RefreshHeader { [unowned self] in
            loadingTask?.cancel()
            applySnapshot()
        }
        collectionView.mj_header = header
    }
    
    func endMJRefresh() {
        collectionView.mj_header?.endRefreshing()
    }
    
    func collectionView(_ collectionView: UICollectionView, previewForHighlightingContextMenuWithConfiguration configuration: UIContextMenuConfiguration) -> UITargetedPreview? {
        guard let identifier = configuration.identifier as? String else {
            return nil
        }
        let components = identifier.components(separatedBy: "#")
        if components.count == 2, let section = Int(components[0]), let row = Int(components[1]) {
            let indexPath = IndexPath(row: row, section: section)
            guard let cell = collectionView.cellForItem(at: indexPath) as? GridCell else {
                return nil
            }
            return UITargetedPreview(view: cell.imageView)
        }
        return nil
    }
    
    func collectionView(_ collectionView: UICollectionView, contextMenuConfigurationForItemAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        guard let item = dataSource.itemIdentifier(for: indexPath) else {
            return nil
        }
        let list = dataSource.snapshot(for: item.section).items.map { $0.value }
        let identifier = "\(indexPath.section)#\(indexPath.row)" as NSString
        return UIContextMenuConfiguration(identifier: identifier, previewProvider: nil) { [weak self] _ in
            guard let self = self else { return nil }
            let info = ContextMenuInfo(item: item.value, list: list, viewController: self)
            return ContextMenuProvider.contextMenu(for: info)
        }
    }
}

// MARK: - Cache
extension LibraryViewController {
    
    func loadCache() {
        guard let cache = Context.current?.libraryCache else {
            return
        }
        let sections: [LibrarySection] = [.newestAlbums, .randomSongs, .starredAlbums, .starredArtists]
        for section in sections {
            switch section {
            case .newestAlbums:
                let albums: [Album] = cache.load(section: section)
                let items = albums.map { LibraryItem(section: section, value: $0) }
                if !items.isEmpty {
                    applyItems(items, to: section)
                }
            case .randomSongs:
                let songs: [Song] = cache.load(section: section)
                let items = songs.map { LibraryItem(section: section, value: $0) }
                if !items.isEmpty {
                    applyItems(items, to: section)
                }
            case .starredAlbums:
                let albums: [Album] = cache.load(section: section)
                let items = albums.map { LibraryItem(section: section, value: $0) }
                if !items.isEmpty {
                    applyItems(items, to: section)
                }
            case .starredArtists:
                let artists: [Artist] = cache.load(section: section)
                let items = artists.map { LibraryItem(section: section, value: $0) }
                if !items.isEmpty {
                    applyItems(items, to: section)
                }
            case .starredSongs:
                let songs: [Song] = cache.load(section: section)
                let items = songs.map { LibraryItem(section: section, value: $0) }
                if !items.isEmpty {
                    applyItems(items, to: section)
                }
            default:
                break
            }
        }
    }
    
    private func saveCache<T: Encodable>(_ items: [T], section: LibrarySection) {
        guard let cache = Context.current?.libraryCache else { return }
        cache.save(items: items, section: section)
    }
}

extension LibraryViewController {
    
    private func applyNewestAlbums(client: SubsonicClient) async {
        do {
            let section = LibrarySection.newestAlbums
            let albumList = try await client.getAlbumList2(type: .newest, size: 20, offset: 0).albumList2.album.uniqued()
            if !albumList.isEmpty {
                let items = albumList.map { LibraryItem(section: section, value: $0) }
                saveCache(albumList, section: section)
                applyItems(items, to: section)
            }
        } catch {
            HUD.show(error: error.localizedDescription)
        }
    }
    
    private func applyRandomSongs(client: SubsonicClient) async {
        do {
            let section = LibrarySection.randomSongs
            let randomSongs = try await client.getRandomSongs(size: 24).randomSongs.song.uniqued()
            if !randomSongs.isEmpty {
                let items = randomSongs.map { LibraryItem(section: section, value: $0) }
                saveCache(randomSongs, section: section)
                applyItems(items, to: section)
            }
        } catch {
            HUD.show(error: error.localizedDescription)
        }
    }
    
    private func applyStarred(client: SubsonicClient) async {
        do {
            
            let starred = try await client.getStarred2().starred2
            if let albums = starred.album?.uniqued(), !albums.isEmpty {
                let section = LibrarySection.starredAlbums
                let items = albums.map { LibraryItem(section: section, value: $0) }
                saveCache(albums, section: section)
                applyItems(items, to: section)
            }
            
            if let artists = starred.artist?.uniqued(), !artists.isEmpty {
                let section = LibrarySection.starredArtists
                let items = artists.map { LibraryItem(section: section, value: $0) }
                saveCache(artists, section: section)
                applyItems(items, to: section)
            }
            
            if let songs = starred.song?.uniqued(), !songs.isEmpty {
                let section = LibrarySection.starredSongs
                let items = songs.map { LibraryItem(section: section, value: $0) }
                saveCache(songs, section: section)
                applyItems(items, to: section)
            }
            
        } catch {
            HUD.show(error: error.localizedDescription)
        }
    }
    
    private func applyPlaylists(client: SubsonicClient) async {
        do {
            let playlists = try await client.getPlaylists().playlists?.playlist?.uniqued().filter { $0.public == false }
            if let playlists = playlists, !playlists.isEmpty {
                let section = LibrarySection.playlists
                let items = playlists.map { LibraryItem(section: section, value: $0) }
                saveCache(playlists, section: section)
                applyItems(items, to: section)
            }
        } catch {
            print(error)
        }
    }
    
    private func applyItems(_ items: [LibraryItem], to section: LibrarySection) {
        var snapshot = dataSource.snapshot()
        if snapshot.indexOfSection(section) == nil {
            snapshot.appendSections([section])
        } else {
            var sectionSnapshot = dataSource.snapshot(for: section)
            sectionSnapshot.deleteAll()
        }
        
        var sectionSnaphot = NSDiffableDataSourceSectionSnapshot<LibraryItem>()
        sectionSnaphot.append(items)
        dataSource.apply(sectionSnaphot, to: section)
    }
    
}

extension LibraryViewController {
    
    private func setupNavBar() {
        navigationItem.title = Context.current?.account.name
        
        let addItem = UIBarButtonItem(image: UIImage(systemName: "person.badge.plus"), style: .plain, target: self, action: #selector(onAddItemClicked))
        navigationItem.rightBarButtonItem = addItem
    }
    
    private func setupCollectionView() {
        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: createLayout())
        collectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(collectionView)
        collectionView.delegate = self
        
        configureMJRefresh()
    }
    
    private func createLayout() -> UICollectionViewLayout {
        return UICollectionViewCompositionalLayout { [weak self] sectionIndex, layoutEnvironment in
            guard let self = self else { return nil }
            let snapshot = self.dataSource.snapshot()
            guard sectionIndex < snapshot.sectionIdentifiers.count else { return nil }
            let sectionKind = snapshot.sectionIdentifiers[sectionIndex]
            
            let group: NSCollectionLayoutGroup
            switch sectionKind {
            case .randomSongs, .starredSongs, .playlists:
                let numbers = snapshot.numberOfItems(inSection: sectionKind)
                let count = min(4, numbers)
                let height = 70.0 * CGFloat(count)
                let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0))
                let item = NSCollectionLayoutItem(layoutSize: itemSize)
                let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.85), heightDimension: .estimated(height))
                group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitem: item, count: count)
            case .starredArtists:
                let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0))
                let item = NSCollectionLayoutItem(layoutSize: itemSize)
                let groupSize = NSCollectionLayoutSize(widthDimension: .absolute(105), heightDimension: .absolute(145))
                group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
            default:
//                let viewSize = layoutEnvironment.container.effectiveContentSize
//                let count = UIDevice.current.userInterfaceIdiom == .pad ? 4: 2
                //let width = viewSize.width - 32 - 30
                let itemWidth: CGFloat = 180//width / CGFloat(count)
                let itemHeight = itemWidth + 42
                
                let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0))
                let item = NSCollectionLayoutItem(layoutSize: itemSize)
                let groupSize = NSCollectionLayoutSize(widthDimension: .absolute(itemWidth), heightDimension: .absolute(itemHeight))
                group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
                group.interItemSpacing = .fixed(15)
            }
            
            let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(60))
            let header = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: headerSize, elementKind: UICollectionView.elementKindSectionHeader, alignment: .top)
            
            let section = NSCollectionLayoutSection(group: group)
            section.contentInsets = .init(top: 0, leading: 16, bottom: 16, trailing: 16)
            section.interGroupSpacing = 15
            section.orthogonalScrollingBehavior = sectionKind.orthogonalScrollingBehavior
            if !snapshot.itemIdentifiers.isEmpty {
                section.boundarySupplementaryItems = [header]
            }
            
            return section
        }
    }
    
    private func setupDataSource() {
        
        let cellRegistration = UICollectionView.CellRegistration<GridCell, LibraryItem> { (cell, indexPath, item) in
            if let album = item.value as? Album {
                cell.render(album: album)
            }
        }
        
        let listCellRegistration = UICollectionView.CellRegistration<ListCell, LibraryItem> { (cell, indexPath, item) in
            if let song = item.value as? Song {
                cell.render(song)
            } else if let playlist = item.value as? Playlist {
                cell.render(playlist)
            }
        }
        
        let artistCellRegistration = UICollectionView.CellRegistration<ArtistListCell, LibraryItem> { (cell, indexPath, item) in
            if let artist = item.value as? Artist {
                cell.render(artist)
            }
        }
        
        let headerRegistration = UICollectionView.SupplementaryRegistration<LibrarySectionHeaderView>(elementKind: UICollectionView.elementKindSectionHeader) { [weak self] (supplementaryView, kind, indexPath) in
            guard let self = self else { return }
            let snapshot = self.dataSource.snapshot()
            guard indexPath.section < snapshot.sectionIdentifiers.count else { return }
            let sectionKind = snapshot.sectionIdentifiers[indexPath.section]
            supplementaryView.render(title: sectionKind.title, actionText: sectionKind.actionText)
            supplementaryView.actionHandler = {
                self.handleViewAllSection(sectionKind)
            }
        }
        dataSource = UICollectionViewDiffableDataSource<LibrarySection, LibraryItem>(collectionView: collectionView, cellProvider: { collectionView, indexPath, itemIdentifier in
            if itemIdentifier.value is Song || itemIdentifier.value is Playlist {
                return collectionView.dequeueConfiguredReusableCell(using: listCellRegistration, for: indexPath, item: itemIdentifier)
            } else if itemIdentifier.value is Artist {
                return collectionView.dequeueConfiguredReusableCell(using: artistCellRegistration, for: indexPath, item: itemIdentifier)
            }
            return collectionView.dequeueConfiguredReusableCell(using: cellRegistration, for: indexPath, item: itemIdentifier)
        })
        dataSource.supplementaryViewProvider = { (collectionView, kind, indexPath) in
            return collectionView.dequeueConfiguredReusableSupplementary(using: headerRegistration, for: indexPath)
        }
    }
    
    private func setupWelcomeView() {
        welcomeView.isHidden = true
        view.addSubview(welcomeView)
        welcomeView.addButton.addTarget(self, action: #selector(onAddItemClicked), for: .touchUpInside)
        
        welcomeView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            welcomeView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            welcomeView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            welcomeView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            welcomeView.heightAnchor.constraint(equalToConstant: 300)
        ])
    }
}

extension LibraryViewController {
    
    @objc private func onAddItemClicked() {
        let vc = LoginViewController()
        vc.delegate = self
        let nav = UINavigationController(rootViewController: vc)
        present(nav, animated: true)
    }
    
    private func handleViewAllSection(_ section: LibrarySection) {
        if section == .newestAlbums {
            let provider = AlbumListProvider(type: .newest)
            let vc = AlbumListViewController(dataProvider: provider)
            vc.navigationItem.title = "Newest Albums"
            navigationController?.pushViewController(vc, animated: true)
        } else if section == .starredAlbums {
            let provider = StarredAlbumListProvider()
            let vc = AlbumListViewController(dataProvider: provider)
            vc.navigationItem.title = "Starred Albums"
            navigationController?.pushViewController(vc, animated: true)
        } else if section == .starredArtists {
            let provider = StarredArtistListProvider()
            let vc = ArtistListViewController(dataProvider: provider)
            vc.navigationItem.title = "Starred Artists"
            navigationController?.pushViewController(vc, animated: true)
        } else if section == .randomSongs || section == .starredSongs {
            let songs = dataSource.snapshot(for: section).items.compactMap { $0.value as? Song }.shuffled()
            if !songs.isEmpty {
                AudioPlayerManager.shared.play(songs, at: 0)
            }
        }
    }
}

// MARK: - UICollectionViewDelegate
extension LibraryViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let item = dataSource.itemIdentifier(for: indexPath) else {
            return
        }
        
        if item.section == .randomSongs || item.section == .starredSongs {
            let songs = dataSource.snapshot(for: item.section).items.compactMap { $0.value as? Song }
            AudioPlayerManager.shared.play(songs, at: indexPath.item)
        } else if let album = item.value as? Album {
            let vc = AlbumProfileViewController(album: album)
            navigationController?.pushViewController(vc, animated: true)
        } else if let artist = item.value as? Artist {
            let vc = ArtistProfileViewController(artist: artist)
            navigationController?.pushViewController(vc, animated: true)
        } else if let playlist = item.value as? Playlist {
            let vc = PlaylistViewController(playlist: playlist)
            navigationController?.pushViewController(vc, animated: true)
        }
    }
    
}

// MARK: - LoginViewControllerDelegate
extension LibraryViewController: LoginViewControllerDelegate {
    
    func loginViewController(_ controller: LoginViewController, didConnectedAccount account: Account) {
        controller.presentingViewController?.dismiss(animated: true)
        
        navigationItem.title = account.name
        
        changeAccount(account)
        
        applySnapshot()
    }
    
    private func changeAccount(_ account: Account) {
        Context.current = Context(account: account)
    }
}
