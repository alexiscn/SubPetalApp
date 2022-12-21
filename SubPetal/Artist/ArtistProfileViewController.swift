//
//  ArtistProfileViewController.swift
//  SubPetal
//
//  Created by alexiscn on 2022/6/3.
//

import UIKit
import SubsonicKit

class ArtistProfileViewController: ContextViewController {
    
    enum Section: Int {
        case header
        case topSongs
        case albums
        case similarArtists
        
        var title: String {
            switch self {
            case .header: return ""
            case .topSongs: return "Top Songs"
            case .albums: return "Albums"
            case .similarArtists: return "Similar Artists"
            }
        }
        
        var orthogonalScrollingBehavior: UICollectionLayoutSectionOrthogonalScrollingBehavior {
            switch self {
            case .topSongs: return .groupPaging
            default: return .continuous
            }
        }
    }
    
    var artist: Artist
    
    let fakeNavigationBar = UIView()
    var starItem: UIBarButtonItem!
    
    init(artist: Artist) {
        self.artist = artist
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.contentInsetAdjustmentBehavior = .never
        collectionView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 120, right: 0)
        
        setupNavBar()
        setupFakeNavigationBar()
        applySnapshot()
    }
    
    override func createLayout() -> UICollectionViewLayout {
        return UICollectionViewCompositionalLayout { [weak self] sectionIndex, layoutEnvoirnment in
            guard let self = self else { return nil }
            let snapshot = self.dataSource.snapshot()
            guard sectionIndex < snapshot.sectionIdentifiers.count else { return nil }
            guard let sectionKind = Section(rawValue: snapshot.sectionIdentifiers[sectionIndex]) else { return nil }
            
            let group: NSCollectionLayoutGroup
            switch sectionKind {
            case .header:
                let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0))
                let item = NSCollectionLayoutItem(layoutSize: itemSize)
                let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalWidth(1.0))
                group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
            case .topSongs:
                let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0))
                let item = NSCollectionLayoutItem(layoutSize: itemSize)
                let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.85), heightDimension: .estimated(280))
                group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitem: item, count: 4)
            case .similarArtists:
                let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0))
                let item = NSCollectionLayoutItem(layoutSize: itemSize)
                let groupSize = NSCollectionLayoutSize(widthDimension: .absolute(105), heightDimension: .absolute(145))
                group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
            default:
                let viewSize = layoutEnvoirnment.container.effectiveContentSize
                let width = viewSize.width - 32 - 30
                let itemWidth = width / 2.0
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
            section.interGroupSpacing = 15
            section.orthogonalScrollingBehavior = sectionKind.orthogonalScrollingBehavior
            if sectionKind != .header {
                section.contentInsets = .init(top: 0, leading: 16, bottom: 16, trailing: 16)
                section.boundarySupplementaryItems = [header]
            }
            return section
        }
    }
    
    override func setupDataSource() {
        let headerCellRegistration = UICollectionView.CellRegistration<ArtistProfileHeaderCell, Item> { (cell, indexPath, item) in
            if let artist = item.value as? Artist {
                cell.render(artist)
            }
        }
        let cellRegistration = UICollectionView.CellRegistration<GridCell, Item> { (cell, indexPath, item) in
            if let album = item.value as? Album {
                cell.render(album: album)
            }
        }
        
        let listCellRegistration = UICollectionView.CellRegistration<ListCell, Item> { (cell, indexPath, item) in
            if let song = item.value as? Song {
                cell.render(song)
            }
        }
        let artistCellRegistration = UICollectionView.CellRegistration<ArtistListCell, Item> { (cell, indexPath, item) in
            if let artist = item.value as? Artist {
                cell.render(artist)
            }
        }
        
        let headerRegistration = UICollectionView.SupplementaryRegistration<LibrarySectionHeaderView>(elementKind: UICollectionView.elementKindSectionHeader) { [weak self] (supplementaryView, kind, indexPath) in
            guard let self = self else { return }
            let snapshot = self.dataSource.snapshot()
            guard indexPath.section < snapshot.sectionIdentifiers.count else { return }
            guard let sectionKind = Section(rawValue: snapshot.sectionIdentifiers[indexPath.section]) else { return }
            if sectionKind == .albums {
                supplementaryView.render(title: sectionKind.title, actionText: "See All")
            } else {
                supplementaryView.render(title: sectionKind.title)
            }
            supplementaryView.actionHandler = { [weak self] in
                self?.handleHeaderAction(at: sectionKind)
            }
        }
        dataSource = UICollectionViewDiffableDataSource<Int, Item>(collectionView: collectionView, cellProvider: { collectionView, indexPath, itemIdentifier in
            switch itemIdentifier.section {
            case Section.header.rawValue:
                return collectionView.dequeueConfiguredReusableCell(using: headerCellRegistration, for: indexPath, item: itemIdentifier)
            case Section.topSongs.rawValue:
                return collectionView.dequeueConfiguredReusableCell(using: listCellRegistration, for: indexPath, item: itemIdentifier)
            case Section.albums.rawValue:
                return collectionView.dequeueConfiguredReusableCell(using: cellRegistration, for: indexPath, item: itemIdentifier)
            case Section.similarArtists.rawValue:
                return collectionView.dequeueConfiguredReusableCell(using: artistCellRegistration, for: indexPath, item: itemIdentifier)
            default: fatalError("not such section")
            }
        })
        dataSource.supplementaryViewProvider = { (collectionView, kind, indexPath) in
            return collectionView.dequeueConfiguredReusableSupplementary(using: headerRegistration, for: indexPath)
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        fakeNavigationBar.frame = CGRect(x: 0, y: 0, width: view.bounds.width, height: view.safeAreaInsets.top)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController?.navigationBar.shadowImage = UIImage()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.navigationBar.setBackgroundImage(nil, for: .default)
        navigationController?.navigationBar.shadowImage = nil
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let item = dataSource.itemIdentifier(for: indexPath) else {
            return
        }
        if item.section == Section.topSongs.rawValue, let song = item.value as? Song {
            let songs = dataSource.snapshot(for: Section.topSongs.rawValue).items.compactMap { $0.value as? Song }
            let index = songs.firstIndex(where: { $0.id == song.id }) ?? 0
            AudioPlayerManager.shared.play(songs, at: index)
        } else {
            super.collectionView(collectionView, didSelectItemAt: indexPath)
        }
    }
    
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let y = scrollView.contentOffset.y - 44
        let maxOffset = scrollView.bounds.height * 0.2
        let progress = max(min(y/maxOffset, 1), 0)
        fakeNavigationBar.alpha = progress
        navigationItem.title = progress == 1.0 ? artist.name : ""
    }
}

// MARK: - Setup
extension ArtistProfileViewController {
    
    private func setupNavBar() {
        let starred = artist.starred != nil
        let image = starred ? UIImage(systemName: "heart.fill"): UIImage(systemName: "heart")
        starItem = UIBarButtonItem(image: image, style: .plain, target: self, action: #selector(onStarItemClicked))
        navigationItem.rightBarButtonItem = starItem
    }
    
    private func setupFakeNavigationBar() {
        fakeNavigationBar.backgroundColor = UIColor.secondarySystemBackground
        fakeNavigationBar.alpha = 0
        view.addSubview(fakeNavigationBar)
    }
}

extension ArtistProfileViewController {
    
    private func applySnapshot() {
        guard let client = Context.current?.client else { return }
        Task {
            var snapshot = NSDiffableDataSourceSnapshot<Int, Item>()
            
            // apply header
            snapshot.appendSections([Section.header.rawValue])
            snapshot.appendItems([Item(section: Section.header.rawValue, value: self.artist)], toSection: Section.header.rawValue)
            await dataSource.apply(snapshot, animatingDifferences: false)
            
            await applyTopSongs(client: client)
            await applyAlbums(client: client)
            await applySimilarArtists(client: client)
        }
    }
    
    private func applyTopSongs(client: SubsonicClient) async {
        do {
            // load top songs
            let topSongs = try await client.getTopSongs(artist: artist.name ?? "", count: 30).topSongs.song?.uniqued()
            if let songs = topSongs, !songs.isEmpty {
                var snapshot = NSDiffableDataSourceSectionSnapshot<Item>()
                snapshot.append(songs.map { Item(section: Section.topSongs.rawValue,value: $0) })
                await dataSource.apply(snapshot, to: Section.topSongs.rawValue, animatingDifferences: false)
            }
        } catch {
            print(error)
        }
    }
    
    private func applyAlbums(client: SubsonicClient) async {
        do {
            // load albums
            let albums = try await client.getArtist(id: artist.id).artist.album?.uniqued()
            if let albums = albums, !albums.isEmpty {
                var snapshot = NSDiffableDataSourceSectionSnapshot<Item>()
                snapshot.append(albums.map { Item(section: Section.albums.rawValue,value: $0) })
                await dataSource.apply(snapshot, to: Section.albums.rawValue, animatingDifferences: false)
            }
        } catch {
            print(error)
        }
    }
    
    private func applySimilarArtists(client: SubsonicClient) async {
        do {
            // load similar artist
            let artists = try await client.getArtistInfo2(id: artist.id, count: 30).artistInfo2.similarArtist?.uniqued()
            if let similarArtists = artists, !similarArtists.isEmpty {
                var snapshot = NSDiffableDataSourceSectionSnapshot<Item>()
                let items = similarArtists.map { Item(section: Section.similarArtists.rawValue, value: $0) }
                snapshot.append(items)
                await dataSource.apply(snapshot, to: Section.similarArtists.rawValue, animatingDifferences: false)
            }
        } catch {
            print(error)
        }
    }
}

// MARK: - Events
extension ArtistProfileViewController {
    
    @objc private func onStarItemClicked() {
        Task {
            do {
                let indicator = UIActivityIndicatorView(style: .medium)
                indicator.startAnimating()
                navigationItem.rightBarButtonItem = UIBarButtonItem(customView: indicator)
                
                if artist.starred == nil {
                    try await Context.current?.client.star(artistId: artist.id)
                    artist.starred = ISO3601DateFormatter.shared.string(from: Date())
                } else {
                    try await Context.current?.client.unstar(artistId: artist.id)
                    artist.starred = nil
                }
                setupNavBar()
            } catch {
                HUD.show(error: error.localizedDescription)
            }
        }
    }
    
    private func handleHeaderAction(at section: Section) {
        if section == .albums {
            let provider = ArtistAlbumListProvider(artistId: artist.id)
            let vc = AlbumListViewController(dataProvider: provider)
            vc.title = "Albums"
            navigationController?.pushViewController(vc, animated: true)
        }
    }
}
