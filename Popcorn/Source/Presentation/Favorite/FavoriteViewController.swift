//
//  FavoriteViewController.swift
//  Popcorn
//
//  Created by 홍정민 on 10/9/24.
//

import UIKit
import SnapKit
import Then

final class FavoriteViewController: BaseViewController {
    private lazy var favoriteTableView = UITableView().then {
        $0.delegate = self
        $0.dataSource = self
        $0.register(MovieTableViewCell.self, forCellReuseIdentifier: MovieTableViewCell.identifier)
        $0.register(MovieTableHeaderView.self, forHeaderFooterViewReuseIdentifier: MovieTableHeaderView.identifier)
        $0.rowHeight = 90
        $0.backgroundColor = .black
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "내가 찜한 리스트"
    }
    
    override func configureHierarchy() {
        view.addSubview(favoriteTableView)
    }
    
    override func configureLayout() {
        favoriteTableView.snp.makeConstraints { make in
            make.edges.equalTo(view.safeAreaLayoutGuide)
        }
    }
    
}

extension FavoriteViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 30
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: MovieTableViewCell.identifier, for: indexPath) as? MovieTableViewCell else {
            return UITableViewCell()
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: MovieTableHeaderView.identifier) as? MovieTableHeaderView else {
            return UITableViewHeaderFooterView()
        }
        headerView.setHeaderTitle("영화 시리즈")
        return headerView
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let delete = UIContextualAction(style: .normal, title: "") { _, _, success in
            // 액션 정의
            success(true)
        }
        delete.backgroundColor = .pointRed
        delete.image = Design.Image.trash
        
        return UISwipeActionsConfiguration(actions: [delete])
    }
}
