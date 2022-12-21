//
//  DownloadViewController.swift
//  SubPetal
//
//  Created by alexiscn on 2022/6/11.
//

import UIKit
import Tiercel

class DownloadViewController: UIViewController {
    
    lazy var downloadedVC: DownloadedViewController = {
        return DownloadedViewController()
    }()
    
    lazy var downloadingVC: DownloadingViewController = {
        return DownloadingViewController()
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupNavBar()
        
        addChildVC(downloadedVC)
    }
    
    private func addChildVC(_ vc: UIViewController) {
        addChild(vc)
        view.addSubview(vc.view)
        vc.view.frame = view.bounds
        vc.didMove(toParent: self)
    }
    
    private func removeChildVC(_ vc: UIViewController) {
        vc.removeFromParent()
        vc.view.removeFromSuperview()
        vc.didMove(toParent: nil)
    }
}

extension DownloadViewController {
    
    private func setupNavBar() {
        let segmentedControl = UISegmentedControl(items: ["Downloaded", "Downloading"])
        segmentedControl.autoresizingMask = [.flexibleWidth]
        segmentedControl.addTarget(self, action: #selector(onSegmentedControlValueChanged(_:)), for: .valueChanged)
        segmentedControl.selectedSegmentIndex = 0
        navigationItem.titleView = segmentedControl
    }
    
    @objc private func onSegmentedControlValueChanged(_ sender: UISegmentedControl) {
        
        if sender.selectedSegmentIndex == 0 {
            removeChildVC(downloadingVC)
            addChildVC(downloadedVC)
        } else {
            removeChildVC(downloadedVC)
            addChildVC(downloadingVC)
        }
    }
}
