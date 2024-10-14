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
        $0.text = "영화 시리즈".localized
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
            make.top.equalTo(view.safeAreaLayoutGuide)
            make.leading.equalTo(view.safeAreaLayoutGuide).offset(10)
        }
        favoriteTableView.snp.makeConstraints { make in
            make.top.equalTo(headerLabel.snp.bottom)
            make.horizontalEdges.bottom.equalTo(view.safeAreaLayoutGuide)
        }
    }
    override func configureUI() {
        navigationItem.title = "내가 찜한 리스트".localized
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
                
                cell.playButton.rx.tap
                    .bind(with: self) { owner, _ in
                        let trailerVM = TrailerViewModel(realmMedia: media)
                        let trailerVC = TrailerViewController(viewModel: trailerVM)
                        owner.navigationController?.pushViewController(trailerVC, animated: true)
                    }
                    .disposed(by: cell.disposeBag)
            }
            .disposed(by: disposeBag)
        
        favoriteTableView.rx.modelSelected(RealmMedia.self)
            .bind(with: self) { owner, value in
                let detailVC = DetailViewController(viewModel: DetailViewModel(realmMedia: value))
                let detailNav = UINavigationController(rootViewController: detailVC)
                owner.present(detailNav, animated: true)
            }
            .disposed(by: disposeBag)
    }
}
