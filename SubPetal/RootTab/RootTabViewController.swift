//
//  RootTabViewController.swift
//  SubPetal
//
//  Created by alexiscn on 2022/6/1.
//

import UIKit
import SubsonicKit
import Defaults

class RootTabViewController: UITabBarController {
    
    var nowPlayingBar: PaletteVisualEffectView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        delegate = self
        loadAccount()
        registerObservers()
        setupViewControllers()
        setupNowPlayingBar()
        setupDefaultTabIfNeeded()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        view.bringSubviewToFront(tabBar)
    }
    
    private func loadAccount() {
        guard let accountId = AccountManager.shared.currentAccountId,
              let account = AccountManager.shared.accounts.first(where: { $0.identfier == accountId }) else {
            return
        }
        Context.current = Context(account: account)
    }
    
    private func registerObservers() {
        AccountManager.shared.accountChangeHandler = { [weak self] in
            guard let self = self else { return }
            self.setupViewControllers()
        }
    }
    
    private func setupViewControllers() {
        let homeVC = makeHomeViewController()
        let searchVC = makeSearchViewController()
        let settingsVC = makeSettingsViewController()
        let downloadVC = makeDownloadViewController()
        viewControllers = [homeVC, searchVC, downloadVC, settingsVC]
    }
    
    private func setupNowPlayingBar() {
        nowPlayingBar = PaletteVisualEffectView(frame: .zero)
        view.addSubview(nowPlayingBar)
        nowPlayingBar.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            nowPlayingBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            nowPlayingBar.widthAnchor.constraint(equalTo: view.widthAnchor),
            nowPlayingBar.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            nowPlayingBar.heightAnchor.constraint(equalTo: tabBar.heightAnchor, constant: NowPlayingBarViewController.barHeight)
        ])
    }
    
    private func setupDefaultTabIfNeeded() {
        if Defaults[.rememberLastTab] {
            selectedIndex = Defaults[.lastSelectedTabIndex]
        }
    }
}

// MARK: - UITabBarControllerDelegate
extension RootTabViewController: UITabBarControllerDelegate {
    
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        Defaults[.lastSelectedTabIndex] = selectedIndex
    }
}

extension RootTabViewController {
    
    private func makeHomeViewController() -> UINavigationController {
        let vc = LibraryViewController()
        vc.tabBarItem = UITabBarItem(title: "Library", image: UIImage(systemName: "square.grid.2x2.fill"), tag: 0)
        let nav = UINavigationController(rootViewController: vc)
        nav.additionalSafeAreaInsets = navigationAdditionalSafeAreaInsets
        return nav
    }
    
    private func makeSearchViewController() -> UINavigationController {
        let vc = SearchViewController()
        vc.tabBarItem = UITabBarItem(title: "Search", image: UIImage(systemName: "magnifyingglass"), tag: 0)
        let nav = UINavigationController(rootViewController: vc)
        nav.additionalSafeAreaInsets = navigationAdditionalSafeAreaInsets
        return nav
    }
    
    private func makeDownloadViewController() -> UINavigationController {
        let vc = DownloadViewController()
        vc.tabBarItem = UITabBarItem(title: "Downloads", image: UIImage(systemName: "internaldrive"), tag: 0)
        let nav = UINavigationController(rootViewController: vc)
        nav.additionalSafeAreaInsets = navigationAdditionalSafeAreaInsets
        return nav
    }
    
    private func makeSettingsViewController() -> UINavigationController {
        let vc = SettingsViewController()
        vc.tabBarItem = UITabBarItem(title: "Settings", image: UIImage(systemName: "gearshape.fill"), tag: 0)
        let nav = UINavigationController(rootViewController: vc)
        nav.additionalSafeAreaInsets = navigationAdditionalSafeAreaInsets
        return nav
    }
    
    private var navigationAdditionalSafeAreaInsets: UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 0, bottom: 58, right: 0)
    }
}
