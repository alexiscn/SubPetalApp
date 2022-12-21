//
//  ContextViewController.swift
//  SubPetal
//
//  Created by alexiscn on 2022/6/11.
//

import UIKit
import SubsonicKit

class ContextViewController: UIViewController, UICollectionViewDelegate {
    
    struct Item: Hashable {
        let section: Int
        let value: AnyHashable
    }
    
    var collectionView: UICollectionView!
    var dataSource: UICollectionViewDiffableDataSource<Int, Item>!
    let activityIndicator = UIActivityIndicatorView(style: .medium)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupCollectionView()
        setupActivityView()
        setupDataSource()
    }
    
    func setupCollectionView() {
        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: createLayout())
        collectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(collectionView)
        collectionView.delegate = self
    }
                                                    
    func setupActivityView() {
        view.addSubview(activityIndicator)
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    func createLayout() -> UICollectionViewLayout {
        fatalError("subclass must implement createLayout")
    }
    
    func setupDataSource() {
        fatalError("subclass must implement setupDataSource")
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let item = dataSource.itemIdentifier(for: indexPath) else {
            return
        }
        
        if let album = item.value as? Album {
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
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
    }
}
