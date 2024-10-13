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
    
    private let backdropImageView = UIImageView().then {
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
        view.addSubview(backdropImageView)
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
        backdropImageView.snp.makeConstraints { make in
            make.top.horizontalEdges.equalTo(view.safeAreaLayoutGuide)
            make.height.equalTo(200)
        }
        
        tvButton.snp.makeConstraints { make in
            make.top.equalTo(backdropImageView).inset(10)
            make.trailing.equalTo(closeButton.snp.leading).offset(-10)
            make.size.equalTo(25)
        }
        
        closeButton.snp.makeConstraints { make in
            make.top.equalTo(tvButton)
            make.trailing.equalTo(backdropImageView.snp.trailing).inset(10)
            make.size.equalTo(25)
        }
        
        scrollView.snp.makeConstraints { make in
            make.top.equalTo(backdropImageView.snp.bottom)
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
        backdropImageView.backgroundColor = .gray
        castLabel.text = "출연: " + mock.cast
        creatorLabel.text = "크리에이터: " + mock.creator
    }
    
    func bind() {
        let playButtonTap = PublishSubject<Void>()
        let saveButtonTap = PublishSubject<(UIImage?, UIImage?)>()
        
        let input = DetailViewModel.Input(
            playButtonTap: playButtonTap,
            saveButtonTap: saveButtonTap)
        let output = viewModel.transform(input: input)
        
        output.backdropImage
            .bind(to: backdropImageView.rx.image)
            .disposed(by: disposeBag)
        output.title
            .debug()
            .do(onNext: { print("Title received: \($0)") })
            .bind(to: titleLabel.rx.text)
            .disposed(by: disposeBag)
        output.voteAverage
            .map { $0 }
            .bind(to: rateLabel.rx.text)
            .disposed(by: disposeBag)
        output.overView
            .bind(to: descriptionLabel.rx.text)
            .disposed(by: disposeBag)
        
        closeButton.rx.tap
            .bind(with: self) { owner, _ in
                if let navigationController = owner.navigationController {
                    navigationController.popViewController(animated: true)
                } else {
                    owner.dismiss(animated: true, completion: nil)
                }
            }
            .disposed(by: disposeBag)
        
        playButton.rx.tap
            .bind(with: self) { owner, ss in
                input.playButtonTap.onNext(())
            }
            .disposed(by: disposeBag)
        
        saveButton.rx.tap
            .bind(with: self) { owner, _ in
                let image: UIImage? = nil
                var backdrop: UIImage? = nil
                
                if let media = owner.viewModel.media {
                    backdrop = owner.backdropImageView.image
                    guard let posterURL = APIURL.imageURL(media.posterPath) else {
                        input.saveButtonTap.onNext((image, backdrop))
                        return
                    }
                    posterURL.downloadImage { image in
                        input.saveButtonTap.onNext((image, backdrop))
                    }
                } else if owner.viewModel.realmMedia != nil {
                    input.saveButtonTap.onNext((image, backdrop))
                }
            }
            .disposed(by: disposeBag)
        
        output.popUpViewTrigger
            .bind(with: self) { owner, message in
                let alert = PopupViewController.create()
                    .addMessage(message)
                    .addButton(title: "확인") {
                        owner.dismiss(animated: true)
                    }
                owner.present(alert, animated: true)
            }
            .disposed(by: disposeBag)

        output.toTrailerTrigger
            .bind(with: self) { owner, media in
                let trailerVM = TrailerViewModel(media: media)
                let trailerVC = TrailerViewController(viewModel: trailerVM)
                owner.present(trailerVC, animated: true)
            }
            .disposed(by: disposeBag)
        viewModel.loadInitialData()
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
    let cast: String
    let creator: String
}

let mock = DetailMock(

    cast: "톰 홀랜드 마이클 키튼 로버트 다우니 주니어",
    creator: "Kirk R. Thatcher"
)
