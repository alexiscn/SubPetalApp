//
//  SearchViewController.swift
//  SubPetal
//
//  Created by alexiscn on 2022/5/31.
//

import UIKit
import SubsonicKit

class SearchViewController: UIViewController {
    
    var searchController: UISearchController!
    
    lazy var resultViewController: SearchResultViewController = {
        let vc = SearchResultViewController()
        vc.delegate = self
        return vc
    }()
    
    let throttler = Throttler(seconds: 0.3)
    
    var scope: SearchResultScope = .artist
    
    var response: SearchResult3Response?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .systemBackground
        setupNavBar()
        setupSearchController()
    }
    
    private func performSearch(query: String) {
        Task {
            resultViewController.activityIndicator.startAnimating()
            do {
                response = try await Context.current?.client.search3(query: query)
                updateResult()
            } catch {
                print(error)
            }
            resultViewController.activityIndicator.stopAnimating()
        }
    }
    
    private func updateResult() {
        guard let response = response else {
            return
        }
        var items = [AnyHashable]()
        switch scope {
        case .artist:
            items = response.searchResult3.artist ?? []
        case .album:
            items = response.searchResult3.album ?? []
        case .song:
            items = response.searchResult3.song ?? []
        }
        resultViewController.update(items)
    }
    
    override var canBecomeFirstResponder: Bool {
        return true
    }
    
}

// MARK: - Setup
extension SearchViewController {
    
    private func setupNavBar() {
        navigationItem.title = "Search"
        navigationController?.navigationBar.prefersLargeTitles = true
        
    }
    
    private func setupSearchController() {
        searchController = UISearchController(searchResultsController: resultViewController)
        searchController.searchBar.autocapitalizationType = .none
        searchController.searchBar.returnKeyType = .search
        searchController.searchResultsUpdater = self
        searchController.searchBar.delegate = self
        #if targetEnvironment(macCatalyst)
        searchController.automaticallyShowsScopeBar = true
        #endif
        searchController.searchBar.scopeButtonTitles = SearchResultScope.allCases.map { $0.title }
        navigationItem.searchController = searchController
    }
}

// MARK: - UISearchResultsUpdating
extension SearchViewController: UISearchResultsUpdating {
    
    func updateSearchResults(for searchController: UISearchController) {
        let text = (searchController.searchBar.text ?? "")
        throttler.throttle {
            DispatchQueue.main.async {
             
                if text.isEmpty {
                    
                } else {
                    self.performSearch(query: text)
                }
            }
        }
    }
}

// MARK: - UISearchBarDelegate
extension SearchViewController: UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
        _ = becomeFirstResponder()
        scope = SearchResultScope.allCases[selectedScope]
        updateResult()
    }
    
}

// MARK: - SearchResultViewControllerDelegate
extension SearchViewController: SearchResultViewControllerDelegate {
    
    func searchResultViewControllerDidSelect(item: AnyHashable) {
        if let album = item as? Album {
            let vc = AlbumProfileViewController(album: album)
            navigationController?.pushViewController(vc, animated: true)
        } else if let artist = item as? Artist {
            let vc = ArtistProfileViewController(artist: artist)
            navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    func searchResultViewControllerLoadMoreTriggered() {
        
    }
}

enum SearchResultScope: CaseIterable {
    case artist
    case album
    case song
    
    var title: String {
        switch self {
        case .artist: return "Artists"
        case .album: return "Albums"
        case .song: return "Songs"
        }
    }
}
