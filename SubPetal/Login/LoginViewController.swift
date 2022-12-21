//
//  LoginViewController.swift
//  SubPetal
//
//  Created by alexiscn on 2022/6/1.
//

import UIKit
import Defaults
import SubsonicKit

protocol LoginViewControllerDelegate: AnyObject {
    
    func loginViewController(_ controller: LoginViewController, didConnectedAccount account: Account)
    
}

class LoginViewController: UIViewController {
    
    weak var delegate: LoginViewControllerDelegate?
    
    enum Section { case main }
    
    class Item: Hashable {
        enum Kind { case name, server, username, password }
        
        let kind: Kind
        let title: String
        let placeholder: String
        var value: String?
        var isPassword = false
        
        init(kind: Kind, title: String, placeholder: String, value: String?) {
            self.kind = kind
            self.title = title
            self.placeholder = placeholder
            self.value = value
        }
        static func == (lhs: LoginViewController.Item, rhs: LoginViewController.Item) -> Bool {
            return lhs.title == rhs.title
        }
        
        func hash(into hasher: inout Hasher) {
            hasher.combine(title)
        }
    }
    
    private var account: Account?
    
    init(account: Account? = nil) {
        self.account = account
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private var saveItem: UIBarButtonItem!
    private var collectionView: UICollectionView!
    private var dataSource: UICollectionViewDiffableDataSource<Section, Item>!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .secondarySystemBackground
        
        setupNavBar()
        setupCollectionView()
        setupDataSource()
        applySnapshot()
    }
    
    override var canBecomeFirstResponder: Bool {
        return true
    }
    
    private func applySnapshot() {
        let nameItem = Item(kind: .name, title: "Name", placeholder: "remark", value: account?.name)
        let serverItem = Item(kind: .server, title: "Server", placeholder: "https://example.com", value: account?.baseURL.absoluteString)
        let usernameItem = Item(kind: .username, title: "Account", placeholder: "account", value: account?.username)
        let passwordItem = Item(kind: .password, title: "Password", placeholder: "password", value: account?.password)
        passwordItem.isPassword = true
        
        var snapshot = NSDiffableDataSourceSnapshot<Section, Item>()
        snapshot.appendSections([.main])
        snapshot.appendItems([nameItem, serverItem, usernameItem, passwordItem], toSection: .main)
        dataSource.apply(snapshot, animatingDifferences: false)
    }
}

// MARK: - Setup
extension LoginViewController {
    
    private func setupNavBar() {
        
        let cancelItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(onCancelItemClicked))
        navigationItem.leftBarButtonItem = cancelItem
        
        saveItem = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(onSaveItemClicked))
        saveItem.isEnabled = false
        navigationItem.rightBarButtonItem = saveItem        
    }
    
    private func setupCollectionView() {
        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: createLayout())
        collectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        collectionView.backgroundColor = .systemGroupedBackground
        collectionView.keyboardDismissMode = .onDrag
        view.addSubview(collectionView)
        collectionView.delegate = self
    }
    
    private func createLayout() -> UICollectionViewLayout {
        return UICollectionViewCompositionalLayout.list(using: .init(appearance: .insetGrouped))
    }
    
    private func setupDataSource() {
        let cellRegistration = UICollectionView.CellRegistration<LoginCell, Item> { [weak self] (cell, indexPath, item) in
            cell.delegate = self
            cell.render(item)
        }
        dataSource = UICollectionViewDiffableDataSource<Section, Item>(collectionView: collectionView, cellProvider: { (collectionView, indexPath, item) -> UICollectionViewCell? in
            return collectionView.dequeueConfiguredReusableCell(using: cellRegistration, for: indexPath, item: item)
        })
    }
}

// MARK: - UICollectionViewDelegate
extension LoginViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        return false
    }
    
}

// MARK: - LoginCellDelegate
extension LoginViewController: LoginCellDelegate {
    
    func editingTextChanged() {
        checkSaveItem()
    }
}

extension LoginViewController {
    
    @objc private func onCancelItemClicked() {
        presentingViewController?.dismiss(animated: true)
    }
    
    @objc private func onSaveItemClicked() {
        guard let account = getAccount() else {
            return
        }
        
        Task {
            _ = self.becomeFirstResponder()
            let activity = UIActivityIndicatorView(style: .medium)
            activity.startAnimating()
            
            navigationItem.rightBarButtonItem = .init(customView: activity)
            
            do {
                let client = account.makeSonicClient()
                let response = try await client.ping()
                if let error = response.error?.asNSError() {
                    HUD.show(error: error.localizedDescription)
                } else {
                    AccountManager.shared.upsert(account)
                    delegate?.loginViewController(self, didConnectedAccount: account)
                }
            } catch {
                HUD.show(error: error.localizedDescription)
            }
            navigationItem.rightBarButtonItem = saveItem
        }
    }
    
    private func checkSaveItem() {
        saveItem.isEnabled = getAccount() != nil
    }
    
    private func getAccount() -> Account? {
        let items = dataSource.snapshot().itemIdentifiers
        guard let nameItem = items.first(where: { $0.kind == .name }),
              let serverItem = items.first(where: { $0.kind == .server }),
              let accountItem = items.first(where: { $0.kind == .username }),
              let passwordItem = items.first(where: { $0.kind == .password }) else {
            return nil
        }
        guard let server = serverItem.value, let url = URL(string: server), let username = accountItem.value else {
            return nil
        }
        let name = nameItem.value ?? nameItem.placeholder
        let account = self.account ?? Account(baseURL: url, name: name)
        account.name = name
        account.username = username
        account.password = passwordItem.value ?? ""
        return account
    }
}

protocol LoginCellDelegate: AnyObject {
    func editingTextChanged()
}

class LoginCell: UICollectionViewCell {
    
    weak var delegate: LoginCellDelegate?
    let titleLabel = UILabel()
    let textField = UITextField()
    var item: LoginViewController.Item?
 
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        titleLabel.textColor = .label
        titleLabel.font = .preferredFont(forTextStyle: .body)
        
        contentView.addSubview(titleLabel)
        contentView.addSubview(textField)
        
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        textField.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            titleLabel.widthAnchor.constraint(equalTo: contentView.widthAnchor, multiplier: 0.33),
            titleLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            textField.leadingAnchor.constraint(equalTo: titleLabel.trailingAnchor),
            textField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            textField.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
        backgroundConfiguration = .listGroupedCell()
        textField.addTarget(self, action: #selector(onTextFieldValueChanged(_:)), for: .editingChanged)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc private func onTextFieldValueChanged(_ sender: UITextField) {
        item?.value = sender.text
        delegate?.editingTextChanged()
    }
    
    func render(_ item: LoginViewController.Item) {
        self.item = item
        titleLabel.text = item.title
        textField.placeholder = item.placeholder
        textField.text = item.value
        textField.isSecureTextEntry = item.isPassword
    }
}
