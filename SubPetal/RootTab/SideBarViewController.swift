//
//  SideBarViewController.swift
//  SubPetal
//
//  Created by alexiscn on 2022/6/6.
//

import UIKit
import SubsonicKit

class SideBarViewController: UIViewController {
    
    var libraryViewController: UINavigationController?
    
    private lazy var settingsNav: UINavigationController = {
        let vc = SettingsViewController()
        return UINavigationController(rootViewController: vc)
    }()
    
    private lazy var searchNav: UINavigationController = {
        let vc = SearchViewController()
        return UINavigationController(rootViewController: vc)
    }()
    
    private let nowPlayingBar = PaletteVisualEffectView(frame: .zero)
    
    lazy var albumListProvider = AlbumListProvider(type: .newest)
    
    private lazy var albumListViewController: AlbumListViewController = {
        return AlbumListViewController(dataProvider: albumListProvider)
    }()
    private lazy var albumListNav: UINavigationController = {
        return UINavigationController(rootViewController: albumListViewController)
    }()
    
    enum Section: Int, Hashable, CaseIterable {
        case library
        case search
        case settings
        case album
        case artist
        case playlist
    }
    
    enum SidebarItemType {
        case header, row
    }
    
    struct SidebarItem: Hashable {
        var title: String
        let id: UUID
        let type: SidebarItemType
        var image: UIImage?
        
        static func header(title: String, id: UUID = UUID()) -> SidebarItem {
            return SidebarItem(title: title, id: id, type: .header)
        }
    }
    
    private struct RowIdentifier {
        static let library = UUID()
        static let settings = UUID()
        static let search = UUID()
        
        static let allAlbums = UUID()
        static let newestAlbums = UUID()
        static let rankedAlbums = UUID()
        static let starredAlbums = UUID()
        static let recentAddedAlbums = UUID()
        static let recentPlayedAlbums = UUID()
        static let mostPlayedAlbums = UUID()
        
        static let allArtists = UUID()
        static let starredArtists = UUID()
    }
    
    private enum AlbumIdentifier: String {
        case all
        case newest
        case random
        case ranked
        case starred
        case recentAdded
        case recentPlayed
        case mostPlayed
    }
    
    private var collectionView: UICollectionView!
    private var dataSource: UICollectionViewDiffableDataSource<Section, SidebarItem>!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupNavBar()
        setupCollectionView()
        setupDataSource()
        applySnapshot()
        setupNowPlayingBar()
    }
    
}

// MARK: - Setup
extension SideBarViewController {
    
    private func setupNavBar() {
        navigationItem.title = "SubPetal"
        navigationController?.navigationBar.prefersLargeTitles = true
    }
    
    private func setupCollectionView() {
        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: createLayout())
        collectionView.backgroundColor = .systemBackground
        collectionView.delegate = self
        view.addSubview(collectionView)
        
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.topAnchor.constraint(equalTo: view.topAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    private func createLayout() -> UICollectionViewLayout {
        return UICollectionViewCompositionalLayout { (section, layoutEnvironment) -> NSCollectionLayoutSection? in
            var config = UICollectionLayoutListConfiguration(appearance: .sidebar)
            config.showsSeparators = false
            config.headerMode = .firstItemInSection
            return NSCollectionLayoutSection.list(using: config, layoutEnvironment: layoutEnvironment)
        }
    }
    
    private func setupDataSource() {
        let headerRegistration = UICollectionView.CellRegistration<UICollectionViewListCell, SidebarItem> { (cell, indexPath, item) in
            var contentConfiguration = UIListContentConfiguration.sidebarHeader()
            contentConfiguration.text = item.title
            contentConfiguration.textProperties.font = .preferredFont(forTextStyle: .headline)
            contentConfiguration.textProperties.color = .secondaryLabel
            
            cell.contentConfiguration = contentConfiguration
            cell.accessories = [.outlineDisclosure()]
        }
        
        let cellRegistration = UICollectionView.CellRegistration<UICollectionViewListCell, SidebarItem> { (cell, indexPath, item) in
            var content = UIListContentConfiguration.sidebarSubtitleCell()
            content.text = item.title
            content.image = item.image
            cell.contentConfiguration = content
        }
        dataSource = UICollectionViewDiffableDataSource<Section, SidebarItem>(collectionView: collectionView) { (collectionView, indexPath, item) in
            if item.type == .header {
                return collectionView.dequeueConfiguredReusableCell(using: headerRegistration, for: indexPath, item: item)
            } else {
                return collectionView.dequeueConfiguredReusableCell(using: cellRegistration, for: indexPath, item: item)
            }
        }
    }
    
    private func applySnapshot() {
        dataSource.apply(librarySnapshot(), to: .library, animatingDifferences: false)
        dataSource.apply(albumSnapshot(), to: .album, animatingDifferences: false)
        dataSource.apply(artistSnapshot(), to: .artist, animatingDifferences: false)
        dataSource.apply(playlistSnapshot(), to: .playlist, animatingDifferences: false)
    }
    
    private func setupNowPlayingBar() {
        guard let container = splitViewController?.view else { return }
        splitViewController?.additionalSafeAreaInsets = UIEdgeInsets(top: 0, left: 0, bottom: NowPlayingBarViewController.barHeight, right: 0)
        container.addSubview(nowPlayingBar)
        nowPlayingBar.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            nowPlayingBar.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            nowPlayingBar.widthAnchor.constraint(equalTo: container.widthAnchor),
            nowPlayingBar.bottomAnchor.constraint(equalTo: container.bottomAnchor),
            nowPlayingBar.heightAnchor.constraint(equalToConstant: NowPlayingBarViewController.barHeight)
        ])
    }
}

// MARK: - Snapshot
extension SideBarViewController {
    
    func librarySnapshot() -> NSDiffableDataSourceSectionSnapshot<SidebarItem> {
        let header = SidebarItem.header(title: "Home")
        let items: [SidebarItem] = [
            SidebarItem(title: "Library", id: RowIdentifier.library, type: .row, image: UIImage(systemName: "square.grid.2x2.fill")),
            SidebarItem(title: "Search", id: RowIdentifier.search, type: .row, image: UIImage(systemName: "magnifyingglass")),
            SidebarItem(title: "Settings", id: RowIdentifier.settings, type: .row, image: UIImage(systemName: "gearshape.fill"))
        ]
        var snapshot = NSDiffableDataSourceSectionSnapshot<SidebarItem>()
        snapshot.append([header])
        snapshot.append(items, to: header)
        snapshot.expand([header])
        return snapshot
    }
    
    func albumSnapshot() -> NSDiffableDataSourceSectionSnapshot<SidebarItem> {
        let header = SidebarItem.header(title: "Albums")
        let items: [SidebarItem] = [
            SidebarItem(title: "All", id: RowIdentifier.allAlbums, type: .row, image: UIImage(systemName: "rectangle.stack.fill")),
            SidebarItem(title: "Newest", id: RowIdentifier.newestAlbums, type: .row, image: UIImage(systemName: "shuffle")),
            SidebarItem(title: "Starred", id: RowIdentifier.starredAlbums, type: .row, image: UIImage(systemName: "heart.fill")),
            SidebarItem(title: "Ranked", id: RowIdentifier.rankedAlbums, type: .row, image: UIImage(systemName: "star.fill")),
            SidebarItem(title: "Recent Added", id: RowIdentifier.recentAddedAlbums, type: .row, image: UIImage(systemName: "plus.rectangle.fill.on.rectangle.fill")),
            SidebarItem(title: "Recent Played", id: RowIdentifier.recentPlayedAlbums, type: .row, image: UIImage(systemName: "play.rectangle.on.rectangle.fill")),
            SidebarItem(title: "Most Played", id: RowIdentifier.mostPlayedAlbums, type: .row, image: UIImage(systemName: "rectangle.stack.badge.play"))
        ]
        var snapshot = NSDiffableDataSourceSectionSnapshot<SidebarItem>()
        snapshot.append([header])
        snapshot.append(items, to: header)
        snapshot.expand([header])
        return snapshot
    }
    
    func artistSnapshot() -> NSDiffableDataSourceSectionSnapshot<SidebarItem> {
        let header = SidebarItem.header(title: "Artists")
        let items: [SidebarItem] = [
            SidebarItem(title: "All Artists", id: RowIdentifier.allArtists, type: .row, image: UIImage(systemName: "person.2.fill")),
            SidebarItem(title: "Starred", id: RowIdentifier.starredArtists, type: .row, image: UIImage(systemName: "person.crop.circle"))
        ]
        var snapshot = NSDiffableDataSourceSectionSnapshot<SidebarItem>()
        snapshot.append([header])
        snapshot.append(items, to: header)
        snapshot.expand([header])
        return snapshot
    }
    
    func playlistSnapshot() -> NSDiffableDataSourceSectionSnapshot<SidebarItem> {
        let header = SidebarItem.header(title: "Playlists")
        var snapshot = NSDiffableDataSourceSectionSnapshot<SidebarItem>()
        snapshot.append([header])
        //snapshot.append(items, to: header)
        snapshot.expand([header])
        return snapshot
    }
    
}

// MARK: - UICollectionViewDelegate
extension SideBarViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let sidebarItem = dataSource.itemIdentifier(for: indexPath) else { return }
            
        switch sidebarItem.id {
        case RowIdentifier.library:
            if splitViewController?.viewController(for: .secondary) == libraryViewController {
                libraryViewController?.popToRootViewController(animated: true)
            } else {
                splitViewController?.setViewController(libraryViewController, for: .secondary)
            }
        case RowIdentifier.search:
            if splitViewController?.viewController(for: .secondary) == searchNav {
                searchNav.popToRootViewController(animated: true)
            } else {
                splitViewController?.setViewController(searchNav, for: .secondary)
            }
        case RowIdentifier.settings:
            if splitViewController?.viewController(for: .secondary) == settingsNav {
                settingsNav.popToRootViewController(animated: true)
            } else {
                splitViewController?.setViewController(settingsNav, for: .secondary)
            }
        case
            RowIdentifier.allAlbums,
            RowIdentifier.mostPlayedAlbums,
            RowIdentifier.newestAlbums,
            RowIdentifier.recentAddedAlbums:
            
            let type: AlbumListType
            if sidebarItem.id == RowIdentifier.newestAlbums {
                type = .newest
            } else if sidebarItem.id == RowIdentifier.recentAddedAlbums {
                type = .recent
            } else if sidebarItem.id == RowIdentifier.allAlbums {
                type = .alphabeticalByName
            } else if sidebarItem.id == RowIdentifier.mostPlayedAlbums {
                type = .frequent
            } else {
                type = .alphabeticalByName
            }
            albumListProvider.type = type
            
            if splitViewController?.viewController(for: .secondary) == albumListNav {
                albumListNav.popToRootViewController(animated: true)
            } else {
                splitViewController?.setViewController(albumListNav, for: .secondary)
            }
            albumListViewController.applySnapshot()
        default:
            break
        }
    }
}
