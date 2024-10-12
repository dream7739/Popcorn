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
    
    // TODO: - (옵션) 메인 포스터 탭 했을 시 디테일 화면 이동
    
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
        $0.backgroundColor = .black
        
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
            MediaCollectionViewCell.self,
            forCellWithReuseIdentifier: MediaCollectionViewCell.identifier
        )
    }
    
    private let viewModel = TrendingViewModel()
    private let disposeBag = DisposeBag()
    override func viewDidLoad() {
        super.viewDidLoad()
        bind()
    }
    
    private func bind() {
        let playButtonTap = PublishSubject<Void>()
        let saveButtonTap = PublishSubject<UIImage?>()
        
        let input = TrendingViewModel.Input(
            playButtonTap: playButtonTap,
            saveButtonTap: saveButtonTap,
            cellTap: collectionView.rx.itemSelected
        )
        let output = viewModel.transform(input: input)
        
        let dataSource = RxCollectionViewSectionedAnimatedDataSource<TrendSection> { dataSource, collectionView, indexPath, item in
            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: MediaCollectionViewCell.identifier,
                for: indexPath
            ) as? MediaCollectionViewCell else {
                return UICollectionViewCell()
            }
            cell.configureCell(item.posterPath)
            return cell
        } configureSupplementaryView: { dataSource, collectionView, kind, indexPath in
            switch indexPath.section {
            case 0: // 메인 포스터
                guard let header = collectionView.dequeueReusableSupplementaryView(
                    ofKind: kind,
                    withReuseIdentifier: PosterCollectionHeaderView.identifier,
                    for: indexPath
                ) as? PosterCollectionHeaderView else {
                    return UICollectionReusableView()
                }
                let section = dataSource.sectionModels[indexPath.section]
                let media = section.items.first
                header.configureHeader(media, section.model)
                header.playButton.rx.tap
                    .bind(to: playButtonTap)
                    .disposed(by: header.disposeBag)
                header.saveButton.rx.tap
                    .bind(with: self) { owner, _ in
                        saveButtonTap.onNext(header.posterImageView.imageView.image)
                    }
                    .disposed(by: header.disposeBag)
                
                return header
                
            case 1, 2: // 지금 뜨는 영화 / 지금 뜨는 TV
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
        
        output.toDetailTrigger
            .subscribe(with: self) { owner, media in
                let vc = DetailViewController(media: media, realmMedia: nil)
                owner.present(vc, animated: true)
            }
            .disposed(by: disposeBag)
        
        output.toTrailerTrigger
            .subscribe(with: self) { owner, media in
                let vm = TrailerViewModel(media: media)
                let vc = TrailerViewController(viewModel: vm)
                owner.navigationController?.pushViewController(vc, animated: true)
            }
            .disposed(by: disposeBag)
        
        output.popUpViewTrigger
            .subscribe(with: self) { owner, message in
                // TODO: - 팝업 뷰 띄우기
                print(message)
            }
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
