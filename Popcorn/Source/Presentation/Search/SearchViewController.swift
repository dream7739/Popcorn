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

final class SearchViewController: BaseViewController {
    
    private let searchTextField = UITextField().then {
        $0.tintColor = .white
        $0.leftView = UIView(frame: CGRect(x: 0.0, y: 0.0, width: 16.0, height: 0.0))
        $0.leftViewMode = .always
        $0.clipsToBounds = true
        $0.textColor = .lightGray
        $0.font = Design.Font.primary
        $0.attributedPlaceholder = NSAttributedString(string: "게임, 시리즈, 영화를 검색하세요..".localized, attributes: [.foregroundColor: UIColor.lightGray])
        $0.backgroundColor = .darkGray
        
    }
    
    private lazy var trendTableView = UITableView(
        frame: .zero,
        style: .grouped
    ).then {
        $0.delegate = self
        $0.dataSource = self
        $0.register(
            MediaTableViewCell.self,
            forCellReuseIdentifier: MediaTableViewCell.identifier
        )
        $0.register(
            MediaTableHeaderView.self,
            forHeaderFooterViewReuseIdentifier: MediaTableHeaderView.identifier
        )
        $0.keyboardDismissMode = .onDrag
        $0.rowHeight = 90
        $0.backgroundColor = .black
    }
    
    private lazy var collectionView = UICollectionView(
        frame: .zero,
        collectionViewLayout: .searchLayout()
    ).then {
        $0.delegate = self
        $0.dataSource = self
        $0.prefetchDataSource = self
        $0.keyboardDismissMode = .onDrag
        $0.register(
            MediaCollectionViewCell.self,
            forCellWithReuseIdentifier: MediaCollectionViewCell.identifier
        )
        $0.register(
            TrendCollectionHeaderView.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: TrendCollectionHeaderView.identifier
        )
        $0.backgroundColor = .black
    }
    
    private let emptyView = SearchEmpyView()
    
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
        view.addSubview(emptyView)
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
        
        emptyView.snp.makeConstraints { make in
            make.top.equalTo(searchTextField.snp.bottom).offset(10)
            make.horizontalEdges.bottom.equalTo(view.safeAreaLayoutGuide)
        }
        
    }
    
    override func configureUI() {
        searchTextField.layer.cornerRadius = 5
    }
}

extension SearchViewController {
    private func bind() {
        let input = SearchViewModel.Input(
            searchText: searchTextField.rx.text.orEmpty
        )
        
        let output = viewModel.transform(input: input)
        
        output.trendMovieList
            .bind(with: self) { owner, value in
                owner.emptyView.isHidden = true
                owner.collectionView.isHidden = true
                owner.trendTableView.reloadData()
            }
            .disposed(by: disposeBag)
        
        output.showTableView
            .bind(with: self) { owner, value in
                owner.collectionView.isHidden = true
                owner.emptyView.isHidden = true
                owner.trendTableView.isHidden = false
                
                if !owner.viewModel.trendMovieList.isEmpty {
                    owner.trendTableView.scrollToRow(
                        at: IndexPath(row: 0, section: 0),
                        at: .bottom,
                        animated: true
                    )
                }
            }
            .disposed(by: disposeBag)
        
        output.searchMovieList
            .bind(with: self) { owner, value in
                let searchText = owner.searchTextField.text ?? ""
                
                if searchText.isEmpty {
                    output.showTableView.accept(())
                    return
                }
                
                if !value.isEmpty {
                    owner.emptyView.isHidden = true
                    owner.collectionView.isHidden = false
                    owner.collectionView.reloadData()
                    
                    if owner.viewModel.searchPage == 1 {
                        owner.collectionView.scrollToItem(
                            at: IndexPath(item: 0, section: 0),
                            at: .bottom,
                            animated: true)
                    }
                } else {
                    owner.emptyView.isHidden = false
                    owner.collectionView.isHidden = true
                }
            }
            .disposed(by: disposeBag)
    }
}

extension SearchViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.trendMovieList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: MediaTableViewCell.identifier, for: indexPath) as? MediaTableViewCell else {
            return UITableViewCell()
        }
        let data = viewModel.trendMovieList[indexPath.row]
        cell.configureData(data)
        cell.playButton.tag = indexPath.row
        cell.playButton.addTarget(self, action: #selector(playButtonClicked), for: .touchUpInside)
        return cell
    }
    
    @objc private func playButtonClicked(_ sender: UIButton) {
        let index = sender.tag
        let data = viewModel.trendMovieList[index]
        let trailerVM = TrailerViewModel(media: data)
        let trailerVC = TrailerViewController(viewModel: trailerVM)
        navigationController?.pushViewController(trailerVC, animated: true)
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let headerView = tableView.dequeueReusableHeaderFooterView(
            withIdentifier: MediaTableHeaderView.identifier
        ) as? MediaTableHeaderView else {
            return UITableViewHeaderFooterView()
        }
        headerView.setHeaderTitle("추천 시리즈 & 영화".localized)
        return headerView
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let data = viewModel.trendMovieList[indexPath.row]
        let viewModel = DetailViewModel(media: data)
        let detailVC = DetailViewController(viewModel: viewModel)
        let naviDetailVC = UINavigationController(rootViewController: detailVC)
        self.present(naviDetailVC, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50
    }
}

extension SearchViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDataSourcePrefetching {
    func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
        for index in indexPaths where index.item == viewModel.searchMovieList.count - 4 &&
        viewModel.searchPage + 1 <= viewModel.searchMovieResponse?.total_pages ?? 0 {
            viewModel.searchPage += 1
            viewModel.callSearchMovieMore.accept(())
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.searchMovieList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: MediaCollectionViewCell.identifier,
            for: indexPath
        ) as? MediaCollectionViewCell else {
            return UICollectionViewCell()
        }
        let posterPath = viewModel.searchMovieList[indexPath.item].posterPath
        cell.configureCell(posterPath)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let data = viewModel.searchMovieList[indexPath.item]
        let viewModel = DetailViewModel(media: data)
        let detailVC = DetailViewController(viewModel: viewModel)
        let naviDetailVC = UINavigationController(rootViewController: detailVC)
        self.present(naviDetailVC, animated: true)
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        viewForSupplementaryElementOfKind kind: String,
        at indexPath: IndexPath
    ) -> UICollectionReusableView {
        guard let header = collectionView.dequeueReusableSupplementaryView(
            ofKind: kind,
            withReuseIdentifier: TrendCollectionHeaderView.identifier,
            for: indexPath
        ) as? TrendCollectionHeaderView else {
            return UICollectionReusableView()
        }
        header.configureHeader("영화 & 시리즈".localized)
        header.configureLeftPadding()
        return header
    }
}
