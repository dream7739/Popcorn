//
//  BaseViewController.swift
//  Popcorn
//
//  Created by 홍정민 on 10/8/24.
//

import UIKit

class BaseViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        configureHierarchy()
        configureLayout()
        configureUI()
        configureNav()
        view.backgroundColor = .black
    }
    
    func configureHierarchy() { }
    func configureLayout() { }
    func configureUI() { }
    func configureNav() {
        let backButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        backButtonItem.tintColor = .white
        navigationItem.backBarButtonItem = backButtonItem
    }
}
