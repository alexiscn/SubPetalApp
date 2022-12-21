//
//  DownloadedViewController.swift
//  SubPetal
//
//  Created by alexiscn on 2022/6/13.
//

import UIKit
import SubsonicKit

class DownloadedViewController: UIViewController {
    
    enum Section { case main }
    
    var collectionView: UICollectionView!
    var dataSource: UICollectionViewDiffableDataSource<Section, Song>!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupNavBar()
        setupCollectionView()
        setupDataSource()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        applySnapshot()
    }
    
    private func applySnapshot() {
        var snapshot = NSDiffableDataSourceSnapshot<Section, Song>()
        snapshot.appendSections([.main])
        
        let songs = Context.current?.streamCache.loadDownloaded() ?? []
        snapshot.appendItems(songs, toSection: .main)
        dataSource.apply(snapshot, animatingDifferences: false)
    }
}

// MARK: - Setup
extension DownloadedViewController {
    
    private func setupNavBar() {
        navigationItem.title = "Local Storage"
    }
    
    private func setupCollectionView() {
        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: createLayout())
        collectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(collectionView)
        collectionView.delegate = self
    }
    
    private func createLayout() -> UICollectionViewLayout {
        var config = UICollectionLayoutListConfiguration(appearance: .plain)
        config.showsSeparators = false
        config.trailingSwipeActionsConfigurationProvider = { [weak self] indexPath in
            guard let self = self else { return nil }
            guard let item = self.dataSource.itemIdentifier(for: indexPath) else { return nil }
            return self.trailingSwipeActionConfigurations(for: item)
        }
        return UICollectionViewCompositionalLayout { (sectionIndex, layoutEnvironment) in
            
            let section = NSCollectionLayoutSection.list(using: config, layoutEnvironment: layoutEnvironment)
            section.contentInsets = .init(top: 0, leading: 16, bottom: 15, trailing: 16)
            return section
        }
    }
    
    private func setupDataSource() {
        let cellRegistration = UICollectionView.CellRegistration<ListCell, Song> { (cell, indexPath, item) in
            cell.render(item)
        }
        dataSource = UICollectionViewDiffableDataSource<Section, Song>(collectionView: collectionView, cellProvider: { collectionView, indexPath, itemIdentifier in
            return collectionView.dequeueConfiguredReusableCell(using: cellRegistration, for: indexPath, item: itemIdentifier)
        })
    }
}

// MARK: - UICollectionViewDelegate
extension DownloadedViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let item = dataSource.itemIdentifier(for: indexPath) else {
            return
        }
        let songs = dataSource.snapshot(for: .main).items
        if !songs.isEmpty, let index = songs.firstIndex(where: { $0.id == item.id }) {
            AudioPlayerManager.shared.play(songs, at: index)
        }
    }
}

extension DownloadedViewController {
    
    private func trailingSwipeActionConfigurations(for song: Song) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .destructive, title: nil) { [unowned self] _, _, completion in
            delete(song: song)
            completion(true)
        }
        deleteAction.image = UIImage(systemName: "trash")
        
        return UISwipeActionsConfiguration(actions: [deleteAction])
    }
    
}

extension DownloadedViewController {
    
    private func delete(song: Song) {
        Context.current?.streamCache.delete(song: song)
        var snapshot = self.dataSource.snapshot(for: .main)
        snapshot.delete([song])
        dataSource.apply(snapshot, to: .main, animatingDifferences: true, completion: nil)
    }
    
}
