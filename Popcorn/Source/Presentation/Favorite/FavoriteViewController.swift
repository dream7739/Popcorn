//
//  FavoriteViewController.swift
//  Popcorn
//
//  Created by 홍정민 on 10/9/24.
//

import UIKit
import SnapKit
import Then
import RxSwift

final class FavoriteViewController: BaseViewController {
    
    let disposeBag = DisposeBag()
    let viewModel = FavoriteViewModel()
    
    let headerLabel = UILabel().then {
        $0.text = "영화 시리즈"
        $0.font = .systemFont(ofSize: 16, weight: .bold)
        $0.textColor = .white
    }
    private lazy var favoriteTableView = UITableView().then {
        $0.register(MediaTableViewCell.self, forCellReuseIdentifier: MediaTableViewCell.identifier)
        $0.rowHeight = 90
        $0.backgroundColor = .black
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bind()
 
    }
    override func configureHierarchy() {
        view.addSubview(headerLabel)
        view.addSubview(favoriteTableView)
    }
    
    override func configureLayout() {
        headerLabel.snp.makeConstraints { make in
            make.top.leading.equalTo(view.safeAreaLayoutGuide)
        }
        favoriteTableView.snp.makeConstraints { make in
            make.top.equalTo(headerLabel.snp.bottom)
            make.horizontalEdges.bottom.equalTo(view.safeAreaLayoutGuide)
        }
    }
    override func configureUI() {
        navigationItem.title = "내가 찜한 리스트"
    }
    
    func bind() {
        
        let input = FavoriteViewModel.Input(
            itemDeleted: favoriteTableView.rx.modelDeleted(RealmMedia.self)
        )
        
        let output = viewModel.transform(input: input)
        
        output.favoriteList
            .bind(to: favoriteTableView.rx.items(
                cellIdentifier: MediaTableViewCell.identifier,
                cellType: MediaTableViewCell.self
            )) { (row, media, cell) in
                cell.configureData(media)
            }
            .disposed(by: disposeBag)
    }
}
