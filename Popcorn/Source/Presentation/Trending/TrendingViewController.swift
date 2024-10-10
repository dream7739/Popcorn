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
    
    // 네비게이션 바 버튼
    // TODO: - tv, search 간격 조절
    private lazy var logoBarButton = UIBarButtonItem().then {
        let image = UIImage(resource: .logo).withRenderingMode(.alwaysOriginal)
        $0.image = image
    }
    private let tvBarButton = UIBarButtonItem(image: Design.Image.tv).then {
        $0.tintColor = .white
    }
    private let searchBarButton = UIBarButtonItem(image: Design.Image.search).then {
        $0.tintColor = .white
    }
    
    private let scrollView = UIScrollView()
    
    private let contentView = UIView()
    
    private let containerView = UIView().then {
        $0.clipsToBounds = true
        $0.layer.cornerRadius = 10
    }
    
    private let posterImageView = UIImageView().then {
        $0.contentMode = .scaleAspectFill
        $0.backgroundColor = .black
    }
    
    private let collectionView = UICollectionView(
        frame: .zero,
        collectionViewLayout: .trendLayout()
    ).then {
        $0.register(
            SearchCollectionViewCell.self,
            forCellWithReuseIdentifier: SearchCollectionViewCell.identifier
        )
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bind()
    }
    
    private func bind() {
        
    }
    
    override func configureHierarchy() {
        containerView.addSubview(posterImageView)
        contentView.addSubview(containerView)
        contentView.addSubview(collectionView)
        scrollView.addSubview(contentView)
        view.addSubview(scrollView)
    }
    
    override func configureLayout() {
        scrollView.snp.makeConstraints { make in
            make.edges.equalTo(view.safeAreaLayoutGuide)
        }
        
        contentView.snp.makeConstraints { make in
            make.edges.equalTo(scrollView)
            make.width.equalTo(view.safeAreaLayoutGuide)
        }
        
        containerView.snp.makeConstraints { make in
            make.top.horizontalEdges.equalToSuperview().inset(20)
            make.height.equalTo(500)
        }
        
        posterImageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
    }
    
    override func configureUI() {
        navigationItem.leftBarButtonItem = logoBarButton
        navigationItem.rightBarButtonItems = [searchBarButton, tvBarButton]
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
