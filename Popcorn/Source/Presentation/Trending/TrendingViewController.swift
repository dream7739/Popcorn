//
//  TrendingViewController.swift
//  Popcorn
//
//  Created by 홍정민 on 10/9/24.
//
import Alamofire
import UIKit
import SnapKit
import Then
import RxSwift
import RxCocoa

final class TrendingViewController: BaseViewController {

    private let disposeBag = DisposeBag()
    
    private lazy var movieCollectionView = UICollectionView(
        frame: .zero,
        collectionViewLayout: .trendLayout()
    ).then {
        $0.delegate = self
        $0.dataSource = self
        $0.register(
            SearchCollectionViewCell.self,
            forCellWithReuseIdentifier: SearchCollectionViewCell.identifier
        )
    }
    
    private lazy var seriesCollectionView = UICollectionView(
        frame: .zero,
        collectionViewLayout: .trendLayout()
    ).then {
        $0.delegate = self
        $0.dataSource = self
        $0.register(
            SearchCollectionViewCell.self,
            forCellWithReuseIdentifier: SearchCollectionViewCell.identifier
        )
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupRx()
    }
    
    private func setupRx() {
        movieCollectionView.rx.itemSelected
            .subscribe { [weak self] _ in
                self?.fetchTrendingMovie()
            }
            .disposed(by: disposeBag)
        
        seriesCollectionView.rx.itemSelected
            .subscribe { [weak self] _ in
                self?.fetchTrendingTV()
            }
            .disposed(by: disposeBag)
    }
    
    private func fetchTrendingMovie() {
        let router = Router.trending(type: .movie, language: .korean)
        NetworkManager.shared.fetchData(with: router, as: MovieResponse.self)
            .subscribe(onSuccess: { result in
                switch result {
                case .success(let response):
                    print("Trending \(response)")
                case .failure(let error):
                    print("Error fetching trending  \(error)")
                }
            })
            .disposed(by: disposeBag)
    }
    private func fetchTrendingTV() {
        let router = Router.trending(type: .tv, language: .korean)
        NetworkManager.shared.fetchData(with: router, as: TVResponse.self)
            .subscribe(onSuccess: { result in
                switch result {
                case .success(let response):
                    print("Trending \(response)")
                case .failure(let error):
                    print("Error fetching trending  \(error)")
                }
            })
            .disposed(by: disposeBag)
    }
    
    private func fetchTrending(type: Router.ContentType) {
            let router = Router.trending(type: type, language: .korean)
            
            switch type {
            case .movie:
                NetworkManager.shared.fetchData(with: router, as: MovieResponse.self)
                    .subscribe(onSuccess: { result in
                        switch result {
                        case .success(let response):
                            print("Trending \(response)")
                        case .failure(let error):
                            print("Error fetching trending  \(error)")
                        }
                    })
                    .disposed(by: disposeBag)
            case .tv:
                NetworkManager.shared.fetchData(with: router, as: TVResponse.self)
                    .subscribe(onSuccess: { result in
                        switch result {
                        case .success(let response):
                            print("Trending \(response)")
                        case .failure(let error):
                            print("Error fetching trending  \(error)")
                        }
                    })
                    .disposed(by: disposeBag)
            }
        }
        
    private func fetchData<T: Decodable>(router: Router, responseType: T.Type) {
        NetworkManager.shared.fetchData(with: router, as: responseType)
            .subscribe(onSuccess: { result in
                switch result {
                case .success(let response):
                    print("Trending \(response)")
                case .failure(let error):
                    print("Error fetching trending  \(error)")
                }
            })
            .disposed(by: disposeBag)
    }
    
    
    override func configureHierarchy() {
        view.addSubview(movieCollectionView)
        view.addSubview(seriesCollectionView)
        movieCollectionView.backgroundColor = .blue
        seriesCollectionView.backgroundColor = .red
    }
    
    override func configureLayout() {
        movieCollectionView.snp.makeConstraints { make in
            make.top.horizontalEdges.equalTo(view.safeAreaLayoutGuide)
            make.height.equalTo(150)
        }
        
        seriesCollectionView.snp.makeConstraints { make in
            make.top.equalTo(movieCollectionView.snp.bottom).offset(20)
            make.horizontalEdges.equalTo(view.safeAreaLayoutGuide)
            make.height.equalTo(150)
        }
    }
}

extension TrendingViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 30
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: SearchCollectionViewCell.identifier,
            for: indexPath
        ) as? SearchCollectionViewCell else {
            return UICollectionViewCell()
        }
        cell.configureCell(.checkmark)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print("셀 탭", indexPath)
    }
}
