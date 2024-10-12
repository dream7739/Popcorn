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
import RxCocoa

final class FavoriteViewController: BaseViewController {
    
    let disposeBag = DisposeBag()
    let viewModel = FavoriteViewModel()
    
    private lazy var favoriteTableView = UITableView().then {
        $0.register(MediaTableViewCell.self, forCellReuseIdentifier: MediaTableViewCell.identifier)
        $0.register(MediaTableHeaderView.self, forHeaderFooterViewReuseIdentifier: MediaTableHeaderView.identifier)
        $0.rowHeight = 90
        $0.backgroundColor = .black
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bind()
 
    }
    override func configureHierarchy() {
        view.addSubview(favoriteTableView)
    }
    
    override func configureLayout() {
        favoriteTableView.snp.makeConstraints { make in
            make.edges.equalTo(view.safeAreaLayoutGuide)
        }
    }
    override func configureUI() {
        navigationItem.title = "내가 찜한 리스트"
    }
    
    func bind() {
        
        let input = FavoriteViewModel.Input(
            viewWillAppear: rx.viewWillAppear.asObservable().map { _ in }, 
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

extension Reactive where Base: UIViewController {
    var viewDidLoad: ControlEvent<Void> {
        let source = self.methodInvoked(#selector(Base.viewDidLoad)).map { _ in }
        return ControlEvent(events: source)
    }
    
    var viewWillAppear: ControlEvent<Bool> {
        let source = self.methodInvoked(#selector(Base.viewWillAppear)).map { $0.first as? Bool ?? false }
        return ControlEvent(events: source)
    }
    var viewDidAppear: ControlEvent<Bool> {
        let source = self.methodInvoked(#selector(Base.viewDidAppear)).map { $0.first as? Bool ?? false }
        return ControlEvent(events: source)
    }
    
    var viewWillDisappear: ControlEvent<Bool> {
        let source = self.methodInvoked(#selector(Base.viewWillDisappear)).map { $0.first as? Bool ?? false }
        return ControlEvent(events: source)
    }
    var viewDidDisappear: ControlEvent<Bool> {
        let source = self.methodInvoked(#selector(Base.viewDidDisappear)).map { $0.first as? Bool ?? false }
        return ControlEvent(events: source)
    }
}
