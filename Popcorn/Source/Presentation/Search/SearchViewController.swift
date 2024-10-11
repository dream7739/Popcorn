//
//  SearchViewController.swift
//  Popcorn
//
//  Created by 홍정민 on 10/9/24.
//

import UIKit
import SnapKit
import Then
import RxSwift
import RxCocoa
import RxDataSources

final class SearchViewController: BaseViewController {
    
    private let searchTextField = UITextField().then {
        $0.tintColor = .white
        $0.leftView = UIView(frame: CGRect(x: 0.0, y: 0.0, width: 16.0, height: 0.0))
        $0.leftViewMode = .always
        $0.clipsToBounds = true
        $0.textColor = .lightGray
        $0.font = Design.Font.primary
        $0.attributedPlaceholder = NSAttributedString(string: "게임, 시리즈, 영화를 검색하세요..", attributes: [.foregroundColor: UIColor.lightGray])
        $0.backgroundColor = .darkGray

    }
    
    private lazy var trendTableView = UITableView(
        frame: .zero,
        style: .grouped
    ).then {
        $0.delegate = self
        $0.dataSource = self
        $0.register(MovieTableViewCell.self, forCellReuseIdentifier: MovieTableViewCell.identifier)
        $0.register(MovieTableHeaderView.self, forHeaderFooterViewReuseIdentifier: MovieTableHeaderView.identifier)
        $0.rowHeight = 90
        $0.backgroundColor = .black  
    }
    
    private lazy var collectionView = UICollectionView(
        frame: .zero,
        collectionViewLayout: .searchLayout()
    ).then {
        $0.register(
            MovieCollectionViewCell.self,
            forCellWithReuseIdentifier: MovieCollectionViewCell.identifier
        )
    }
    
    private let viewModel: SearchViewModel
    private let disposeBag = DisposeBag()
    
    init(viewModel: SearchViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bind()
    }
    
    override func configureHierarchy() {
        view.addSubview(searchTextField)
        view.addSubview(trendTableView)
        view.addSubview(collectionView)
    }
    
    override func configureLayout() {
        searchTextField.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide)
            make.horizontalEdges.equalTo(view.safeAreaLayoutGuide).inset(10)
            make.height.equalTo(30)
        }
        
        trendTableView.snp.makeConstraints { make in
            make.top.equalTo(searchTextField.snp.bottom).offset(10)
            make.horizontalEdges.bottom.equalTo(view.safeAreaLayoutGuide)
        }
        
        collectionView.snp.makeConstraints { make in
            make.top.equalTo(searchTextField.snp.bottom).offset(10)
            make.horizontalEdges.bottom.equalTo(view.safeAreaLayoutGuide)
        }
    }
    
    override func configureUI() {
        collectionView.isHidden = true
        searchTextField.layer.cornerRadius = 5
    }
    
    private func bind() {
        let input = SearchViewModel.Input(
            searchText: searchTextField.rx.text.orEmpty
        )
        
        let output = viewModel.transform(input: input)
        
        output.trendMovieList
            .bind(with: self) { owner, _ in
                owner.trendTableView.reloadData()
            }
            .disposed(by: disposeBag)
    }
}

extension SearchViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.trendMovieList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: MovieTableViewCell.identifier, for: indexPath) as? MovieTableViewCell else {
            return UITableViewCell()
        }
        let data = viewModel.trendMovieList[indexPath.row]
        cell.configureData(data)
        return cell
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: MovieTableHeaderView.identifier) as? MovieTableHeaderView else {
            return UITableViewHeaderFooterView()
        }
        headerView.setHeaderTitle("추천 시리즈 & 영화")
        return headerView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50
    }
}

extension SearchViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 30
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: MovieCollectionViewCell.identifier,
            for: indexPath
        ) as? MovieCollectionViewCell else {
            return UICollectionViewCell()
        }
        cell.configureCell(.checkmark)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print("셀 탭", indexPath)
    }
}
