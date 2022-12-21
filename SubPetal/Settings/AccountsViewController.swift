//
//  AccountsViewController.swift
//  SubPetal
//
//  Created by alexiscn on 2022/6/5.
//

import UIKit

class AccountsViewController: UIViewController {
    
    enum Section { case main }
    
    var collectionView: UICollectionView!
    var dataSource: UICollectionViewDiffableDataSource<Section, Account>!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupNavBar()
        setupCollectionView()
        setupDataSource()
        applySnapshot()
    }
    
    private func applySnapshot() {
        var snapshot = NSDiffableDataSourceSnapshot<Section, Account>()
        snapshot.appendSections([.main])
        snapshot.appendItems(AccountManager.shared.accounts, toSection: .main)
        dataSource.apply(snapshot, animatingDifferences: false)
    }
    
}

extension AccountsViewController {
    
    private func setupNavBar() {
        navigationItem.title = "Accounts"
    }
    
    private func setupCollectionView() {
        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: createLayout())
        collectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(collectionView)
        collectionView.delegate = self
    }
    
    private func createLayout() -> UICollectionViewLayout {
        return UICollectionViewCompositionalLayout.list(using: .init(appearance: .insetGrouped))
    }
    
    private func setupDataSource() {
        let cellRegistration = UICollectionView.CellRegistration<UICollectionViewListCell, Account> { [weak self] (cell, indexPath, item) in
            guard let self = self else { return }
            var content = cell.defaultContentConfiguration()
            content.text = item.name
            cell.contentConfiguration = content
            cell.accessories = self.accessories(for: item)
        }
        dataSource = UICollectionViewDiffableDataSource<Section, Account>(collectionView: collectionView, cellProvider: { collectionView, indexPath, itemIdentifier in
            return collectionView.dequeueConfiguredReusableCell(using: cellRegistration, for: indexPath, item: itemIdentifier)
        })
    }
}

// MARK: -
extension AccountsViewController {
    
    private func accessories(for account: Account) -> [UICellAccessory] {
        
        let deleteAccessory = UICellAccessory.delete(displayed: .always, options: .init()) { [unowned self] in
            delete(account: account)
        }
        
        let editButton = UIButton(configuration: .plain(), primaryAction: UIAction(handler: { [unowned self] _ in
            edit(account: account)
        }))
        editButton.configuration?.image = UIImage(systemName: "pencil.circle.fill")
        
        if account.identfier == Context.current?.account.identfier {
            let checkmark = UICellAccessory.checkmark()
            let editAccessory = UICellAccessory.customView(configuration: .init(customView: editButton, placement: .trailing(displayed: .always, at: UICellAccessory.Placement.position(after: checkmark))))
            return [deleteAccessory, checkmark, editAccessory]
        } else {
            let editAccessory = UICellAccessory.customView(configuration: .init(customView: editButton, placement: .trailing()))
            return [deleteAccessory, editAccessory]
        }
    }
    
    private func edit(account: Account) {
        let vc = LoginViewController(account: account)
        let nav = UINavigationController(rootViewController: vc)
        present(nav, animated: true)
    }
    
    private func delete(account: Account) {
        let alert = UIAlertController(title: nil, message: "Do you want to delete \(account.name)", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { [weak self] _ in
            guard let self = self else { return }
            AccountManager.shared.delete(account)
            if account.identfier == Context.current?.account.identfier {
                AccountManager.shared.currentAccountId = AccountManager.shared.accounts.first?.identfier
                AccountManager.shared.accountChangeHandler?()
            } else {
                var snapshot = self.dataSource.snapshot(for: .main)
                snapshot.delete([account])
                self.dataSource.apply(snapshot, to: .main)
            }
        }))
        present(alert, animated: true)
    }
}

// MARK: - UICollectionViewDelegate
extension AccountsViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        
        guard let account = dataSource.itemIdentifier(for: indexPath) else {
            return
        }
        
        let alert = UIAlertController(title: nil, message: "Do you want to switch to \(account.name)", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in
            AccountManager.shared.currentAccountId = account.identfier
            Context.current = Context(account: account)
            AccountManager.shared.accountChangeHandler?()
        }))
        present(alert, animated: true)
    }
    
}
