//
//  SettingsViewController+iOS.swift
//  SubPetal
//
//  Created by alexiscn on 2022/6/1.
//

import UIKit

class SettingsViewController: UITableViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupNavBar()
    }
    
    private func setupNavBar() {
        navigationItem.title = "Settings"
        navigationController?.navigationBar.prefersLargeTitles = true
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = UITableViewCell()
        cell.textLabel?.text = "Account"
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = AccountsViewController()
        navigationController?.pushViewController(vc, animated: true)
    }
}
