//
//  TrendingViewController.swift
//  Popcorn
//
//  Created by 홍정민 on 10/9/24.
//

import UIKit
import Alamofire
import SnapKit
import Then
import RxSwift
import RxCocoa
import RxDataSources

final class TrendingViewController: BaseViewController {
    
    // TODO: - tv, search 버튼 간격 조절
    private lazy var logoBarButton = UIBarButtonItem().then {
        let image = UIImage(resource: .logo).withRenderingMode(.alwaysOriginal)
        let imageView = UIImageView(image: image)
        imageView.contentMode = .scaleAspectFit
        $0.customView = imageView
    }
    private let tvBarButton = UIBarButtonItem(image: Design.Image.tv).then {
        $0.tintColor = .white
    }
    private let searchBarButton = UIBarButtonItem(image: Design.Image.search).then {
        $0.tintColor = .white
    }
    
    private let collectionView = UICollectionView(
        frame: .zero,
        collectionViewLayout: .trendLayout()
    ).then {
        $0.register(
            PosterCollectionHeaderView.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: PosterCollectionHeaderView.identifier
        )
        $0.register(
            TrendCollectionHeaderView.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: TrendCollectionHeaderView.identifier
        )
        $0.register(
            MovieCollectionViewCell.self,
            forCellWithReuseIdentifier: MovieCollectionViewCell.identifier
        )
    }
    
    private let viewModel = TrendingViewModel()
    private let disposeBag = DisposeBag()
    override func viewDidLoad() {
        super.viewDidLoad()
        bind()
    }
    
    private func bind() {
        let input = TrendingViewModel.Input()
        let output = viewModel.transform(input: input)
        
        let dataSource = RxCollectionViewSectionedAnimatedDataSource<TrendSection> { dataSource, collectionView, indexPath, item in
            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: MovieCollectionViewCell.identifier,
                for: indexPath
            ) as? MovieCollectionViewCell else {
                return UICollectionViewCell()
            }
            cell.configureCell(item.poster_path)
            return cell
        } configureSupplementaryView: { dataSource, collectionView, kind, indexPath in
            switch indexPath.item {
            case 0: // 메인 포스터
                guard let header = collectionView.dequeueReusableSupplementaryView(
                    ofKind: kind,
                    withReuseIdentifier: PosterCollectionHeaderView.identifier,
                    for: indexPath
                ) as? PosterCollectionHeaderView else {
                    return UICollectionReusableView()
                }
                let section = dataSource.sectionModels[indexPath.section]
                header.configureHeader(section.items.first)
                return header
                
            case 1,2: // 지금 뜨는 영화 / 지금 뜨는 TV
                guard let header = collectionView.dequeueReusableSupplementaryView(
                    ofKind: kind,
                    withReuseIdentifier: TrendCollectionHeaderView.identifier,
                    for: indexPath
                ) as? TrendCollectionHeaderView else {
                    return UICollectionReusableView()
                }
                let section = dataSource.sectionModels[indexPath.section]
                header.configureHeader(section.model)
                return header
                
            default:
                return UICollectionReusableView()
            }
        }
        
        output.sections
            .bind(to: collectionView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)
    }
    
    override func configureHierarchy() {
        view.addSubview(collectionView)
    }
    
    override func configureLayout() {
        collectionView.snp.makeConstraints { make in
            make.edges.equalTo(view.safeAreaLayoutGuide)
        }
    }
    
    override func configureUI() {
        navigationItem.leftBarButtonItem = logoBarButton
        navigationItem.rightBarButtonItems = [searchBarButton, tvBarButton]
    }
}
