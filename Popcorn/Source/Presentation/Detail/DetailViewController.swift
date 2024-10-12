//
//  DetailViewController.swift
//  Popcorn
//
//  Created by 홍정민 on 10/9/24.
//

import UIKit
import SnapKit
import Then
import RxSwift
import RxCocoa
import Kingfisher

final class DetailViewController: BaseViewController {
    
    private let playImage = UIImageView().then {
        $0.contentMode = .scaleAspectFill
        $0.clipsToBounds = true
    }
    
    private let tvButton = UIButton().then {
        $0.clipsToBounds = true
        $0.blackWhiteRadius("", Design.Image.tv)
        $0.layer.cornerRadius = 12
    }
    
    private let closeButton = UIButton().then {
        $0.clipsToBounds = true
        $0.blackWhiteRadius("", Design.Image.close)
        $0.layer.cornerRadius = 12
    }
    
    private let scrollView = UIScrollView().then {
        $0.showsVerticalScrollIndicator = false
    }
    
    private let contentView = UIView().then {
        $0.backgroundColor = .black
    }
    
    private let titleLabel = UILabel().then {
        $0.textColor = .white
        $0.font = Design.Font.title
    }
    
    private let rateLabel = UILabel().then {
        $0.textColor = .white
        $0.font = Design.Font.secondary
    }
    
    private let playButton = UIButton().then {
        $0.whiteBlackRadius("재생", Design.Image.play)
    }
    
    private let saveButton = UIButton().then {
        $0.blackWhiteRadius("저장", Design.Image.download)
    }
    
    private let descriptionLabel = UILabel().then {
        $0.textColor = .white
        $0.font = Design.Font.primary
        $0.numberOfLines = 0
    }
    
    private let castStackView = UIStackView().then {
        $0.axis = .vertical
        $0.distribution = .fillEqually
        $0.spacing = 2
    }
    
    private let castLabel = UILabel().then {
        $0.textColor = .lightGray
        $0.font = Design.Font.primary
    }
    
    private let creatorLabel = UILabel().then {
        $0.textColor = .lightGray
        $0.font = Design.Font.primary
    }
    
    private lazy var collectionView = UICollectionView(
        frame: .zero,
        collectionViewLayout: .searchLayout()
    ).then {
        $0.delegate = self
        $0.dataSource = self
        $0.register(
            MediaCollectionViewCell.self,
            forCellWithReuseIdentifier: MediaCollectionViewCell.identifier
        )
        $0.isScrollEnabled = false
    }
    
    // MARK: - 둘 중에 한 값만 사용
    // 트렌드나 서치에서 들어올 경우 media 값 사용
    // 내가 찜한 리스트에서 들어올 경우 realmMedia 값 사용
    
    private let disposeBag = DisposeBag()
    let viewModel: DetailViewModel
    
    init(viewModel: DetailViewModel) {
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
        view.addSubview(playImage)
        view.addSubview(tvButton)
        view.addSubview(closeButton)
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(rateLabel)
        contentView.addSubview(playButton)
        contentView.addSubview(saveButton)
        contentView.addSubview(descriptionLabel)
        contentView.addSubview(castStackView)
        castStackView.addArrangedSubview(castLabel)
        castStackView.addArrangedSubview(creatorLabel)
        contentView.addSubview(collectionView)
    }
    
    override func configureLayout() {
        playImage.snp.makeConstraints { make in
            make.top.horizontalEdges.equalTo(view.safeAreaLayoutGuide)
            make.height.equalTo(200)
        }
        
        tvButton.snp.makeConstraints { make in
            make.top.equalTo(playImage).inset(10)
            make.trailing.equalTo(closeButton.snp.leading).offset(-10)
            make.size.equalTo(25)
        }
        
        closeButton.snp.makeConstraints { make in
            make.top.equalTo(tvButton)
            make.trailing.equalTo(playImage.snp.trailing).inset(10)
            make.size.equalTo(25)
        }
        
        scrollView.snp.makeConstraints { make in
            make.top.equalTo(playImage.snp.bottom)
            make.horizontalEdges.bottom.equalTo(view.safeAreaLayoutGuide)
        }
        
        contentView.snp.makeConstraints { make in
            make.edges.equalTo(scrollView)
            make.width.equalTo(view.safeAreaLayoutGuide)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.top.horizontalEdges.equalTo(contentView.safeAreaLayoutGuide).inset(10)
        }
        
        rateLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(2)
            make.horizontalEdges.equalTo(titleLabel)
        }
        
        playButton.snp.makeConstraints { make in
            make.top.equalTo(rateLabel.snp.bottom).offset(8)
            make.horizontalEdges.equalTo(titleLabel)
        }
        
        saveButton.snp.makeConstraints { make in
            make.top.equalTo(playButton.snp.bottom).offset(8)
            make.horizontalEdges.equalTo(titleLabel)
        }
        
        descriptionLabel.snp.makeConstraints { make in
            make.top.equalTo(saveButton.snp.bottom).offset(8)
            make.horizontalEdges.equalTo(titleLabel)
        }
        
        castStackView.snp.makeConstraints { make in
            make.top.equalTo(descriptionLabel.snp.bottom).offset(8)
            make.horizontalEdges.equalTo(titleLabel)
        }
        
        collectionView.snp.makeConstraints { make in
            make.top.equalTo(castStackView.snp.bottom).offset(12)
            make.horizontalEdges.equalTo(contentView.safeAreaLayoutGuide)
            make.height.equalTo(UICollectionViewLayout.searchLayout().itemSize.height * 7 + 80)
            make.bottom.equalTo(contentView).inset(10)
        }
    }
    
    override func configureUI() {
        playImage.backgroundColor = .gray
        titleLabel.text = mock.title
        rateLabel.text = mock.rating.formatted()
        descriptionLabel.text = mock.description
        castLabel.text = "출연: " + mock.cast
        creatorLabel.text = "크리에이터: " + mock.creator
    }
    
    func bind() {
        let playButtonTap = PublishSubject<Void>()
        let saveButtonTap = PublishSubject<UIImage?>()
        
        let input = DetailViewModel.Input(
            playButtonTap: playButtonTap,
            saveButtonTap: saveButtonTap)
        let output = viewModel.transform(input: input)

        saveButton.rx.tap
            .bind(with: self) { [weak self] owner, _ in
                guard let urlString = self?.viewModel.media?.posterPath,
//                let url = URL(string: APIURL.videoURL(urlString)) else {
//                    return
//                }
                let url = APIURL.imageURL(urlString) else {
                    return
                }
                KingfisherManager.shared.retrieveImage(with: url) { result in
                    switch result {
                    case .success(let imageResult):
                        saveButtonTap.onNext(imageResult.image)
                    case .failure(let error):
                        print(error)
                        saveButtonTap.onNext(nil)
                    }
                }
            }
            .disposed(by: disposeBag)
    }
    
}

extension DetailViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 20
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: MediaCollectionViewCell.identifier,
            for: indexPath
        ) as? MediaCollectionViewCell else {
            return UICollectionViewCell()
        }
        cell.configureCell(.checkmark)
        return cell
    }
}

struct DetailMock {
    let title: String
    let rating: Double
    let description: String
    let cast: String
    let creator: String
}

let mock = DetailMock(
    title: "스파이더맨: 홈커밍",
    rating: 7.3,
    description: """
                 외톨이 학생 피터 파커는 유전자가 조작된 거미에 물려 초인적인 거미의 능력을 가지게 된다.
                 자신의 초능력을 즐기던 어느 날, 피터의 삼촌 벤 아저씨가 총에 맞아 죽는다.
                 피터는 자신의 초능력에 책임감을 느끼기 시작하고,
                 시민들의 안전을 위해 악당들과 싸우는 히어로 스파이더맨으로 거듭난다.
                 """,
    cast: "톰 홀랜드 마이클 키튼 로버트 다우니 주니어",
    creator: "Kirk R. Thatcher"
)
