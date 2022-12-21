//
//  AccountManager.swift
//  SubPetal
//
//  Created by alexiscn on 2022/6/2.
//

import Foundation

class AccountManager {
    
    enum Keys: String {
        case accounts = "Accounts"
        case currentAccountId = "CurrentAccountId"
    }
    
    var accountChangeHandler: (() -> Void)?
    
    static let shared = AccountManager()
    
    var accounts = [Account]()
    
    var currentAccountId: String? {
        get { return NSUbiquitousKeyValueStore.default.string(forKey: Keys.currentAccountId.rawValue) }
        set {
            NSUbiquitousKeyValueStore.default.set(newValue, forKey: Keys.currentAccountId.rawValue)
            _ = NSUbiquitousKeyValueStore.default.synchronize()
        }
    }
    
    private init() {
        loadAccounts()
    }
    
    private func loadAccounts() {
        if let data = NSUbiquitousKeyValueStore.default.data(forKey: Keys.accounts.rawValue),
            let items = try? JSONDecoder().decode([Account].self, from: data) {
            accounts = items
            if currentAccountId == nil {
                currentAccountId = items.first?.identfier
            }
        }
    }
    
    func upsert(_ account: Account) {
        if let index = accounts.firstIndex(where: { $0.identfier == account.identfier }) {
            accounts[index] = account
        } else {
            accounts.append(account)
        }
        saveAccounts()
    }
    
    func delete(_ account: Account) {
        if let index = accounts.firstIndex(where: { $0.identfier == account.identfier }) {
            accounts.remove(at: index)
            saveAccounts()
            
            if account.identfier == currentAccountId {
                currentAccountId = nil
            }
        }
    }
    
    @discardableResult
    func saveAccounts() -> Bool {
        do {
            let data = try JSONEncoder().encode(accounts)
            NSUbiquitousKeyValueStore.default.set(data, forKey: Keys.accounts.rawValue)
            return NSUbiquitousKeyValueStore.default.synchronize()
        } catch {
            print(error)
        }
        return false
    }
}
