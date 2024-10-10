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
    private let genreLabel = UILabel().then {
        $0.font = Design.Font.primary
        $0.textColor = .white
        $0.textAlignment = .center
    }
    private let playButton = UIButton().then {
        $0.whiteBlackRadius("재생", Design.Image.play)
    }
    private let saveButton = UIButton().then {
        $0.blackWhiteRadius("내가 찜한 리스트", Design.Image.plus)
    }
    private let buttonStackView = UIStackView().then {
        $0.axis = .horizontal
        $0.distribution = .fillEqually
        $0.spacing = 10
    }
    private let collectionView = UICollectionView(
        frame: .zero,
        collectionViewLayout: .trendLayout()
    ).then {
        $0.register(
            MovieCollectionViewCell.self,
            forCellWithReuseIdentifier: MovieCollectionViewCell.identifier
        )
        $0.register(
            TrendCollectionHeaderView.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: "TrendCollectionHeaderView"
            // MARK: - ReuseIdentifier 프로토콜 수정 후 변경 예정
//            withReuseIdentifier: TrendCollectionHeaderView.identifier
        )
    }
    
    private let viewModel = TrendingViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bind()
    }
    
    private func bind() {
        let input = TrendingViewModel.Input()
        let output = viewModel.transform(input: input)
        
//        let dataSource = RxCollectionViewSectionedAnimatedDataSource<TrendSection> { dataSource, collectionView, indexPath, item in
//            guard let cell = collectionView.dequeueReusableCell(
//                withReuseIdentifier: MovieCollectionViewCell.identifier,
//                for: indexPath
//            ) as? MovieCollectionViewCell else {
//                return UICollectionViewCell()
//            }
//            cell.configureCell(item)
//            return cell
//            
//        } configureSupplementaryView: { dataSource, collectionView, kind, indexPath in
//            guard let header = collectionView.dequeueReusableSupplementaryView(
//                ofKind: kind,
//                withReuseIdentifier: SettingCollectionHeaderView.identifier,
//                for: indexPath
//            ) as? SettingCollectionHeaderView else {
//                return UICollectionReusableView()
//            }
//            let section = dataSource.sectionModels[indexPath.section]
//            header.configureHeader(section.model)
//            return header
//        }
//        
//        output.sections
//            .bind(to: collectionView.rx.items(dataSource: dataSource))
//            .disposed(by: disposeBag)
    }
    
    override func configureHierarchy() {
        [playButton, saveButton].forEach {
            buttonStackView.addArrangedSubview($0)
        }
        [posterImageView, genreLabel, buttonStackView].forEach {
            containerView.addSubview($0)
        }
        [containerView, collectionView].forEach {
            contentView.addSubview($0)
        }
        scrollView.addSubview(contentView)
        view.addSubview(scrollView)
        
        contentView.backgroundColor = .blue
        containerView.backgroundColor = .brown
        collectionView.backgroundColor = .green
        posterImageView.backgroundColor = .lightGray
        genreLabel.text = "jakflsjkdfjsdkalflsk"
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
        
        buttonStackView.snp.makeConstraints { make in
            make.horizontalEdges.bottom.equalToSuperview().inset(16)
            make.height.equalTo(40)
        }
        
        genreLabel.snp.makeConstraints { make in
            make.bottom.equalTo(buttonStackView.snp.top).offset(-8)
            make.horizontalEdges.equalToSuperview().inset(16)
        }
        
        collectionView.snp.makeConstraints { make in
            make.top.equalTo(containerView.snp.bottom).offset(20)
            make.horizontalEdges.equalToSuperview()
            make.height.equalTo(400)
            make.bottom.equalToSuperview().inset(20)
        }
    }
    
    override func configureUI() {
        navigationItem.leftBarButtonItem = logoBarButton
        navigationItem.rightBarButtonItems = [searchBarButton, tvBarButton]
    }
}

extension TrendingViewController: UICollectionViewDataSource, UICollectionViewDelegate {
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
