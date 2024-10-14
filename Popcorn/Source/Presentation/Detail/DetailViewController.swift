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
        $0.backgroundColor = .gray
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
        $0.whiteBlackRadius("재생".localized, Design.Image.play)
    }
    
    private let saveButton = UIButton().then {
        $0.blackWhiteRadius("저장".localized, Design.Image.download)
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
        $0.numberOfLines = 2
    }
    
    private let creatorLabel = UILabel().then {
        $0.textColor = .lightGray
        $0.font = Design.Font.primary
        $0.numberOfLines = 2
    }
    
    private let similarLabel = UILabel().then {
        $0.text = "비슷한 콘텐츠".localized
        $0.textColor = .white
        $0.font = Design.Font.subtitle
    }
    
    private lazy var collectionView = UICollectionView(
        frame: .zero,
        collectionViewLayout: .searchLayout()
    ).then {
        $0.register(
            MediaCollectionViewCell.self,
            forCellWithReuseIdentifier: MediaCollectionViewCell.identifier
        )
        $0.isScrollEnabled = false
        $0.backgroundColor = .clear
    }
    
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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.isNavigationBarHidden = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        collectionView.snp.makeConstraints { make in
            make.height.equalTo(collectionView.contentSize.height)
        }
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
        contentView.addSubview(similarLabel)
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
        
        similarLabel.snp.makeConstraints { make in
            make.top.equalTo(castStackView.snp.bottom).offset(16)
            make.horizontalEdges.equalTo(titleLabel)
        }
        
        collectionView.snp.makeConstraints { make in
            make.top.equalTo(similarLabel.snp.bottom).inset(30)
            make.horizontalEdges.equalTo(contentView.safeAreaLayoutGuide)
            make.bottom.equalTo(contentView).inset(10)
        }
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
            .bind(to: titleLabel.rx.text)
            .disposed(by: disposeBag)
        output.voteAverage
            .map { String(format: "%.1f", $0)  }
            .bind(to: rateLabel.rx.text)
            .disposed(by: disposeBag)
        output.overView
            .bind(to: descriptionLabel.rx.text)
            .disposed(by: disposeBag)
        
        closeButton.rx.tap
            .bind(with: self) { owner, _ in
                owner.dismiss(animated: true, completion: nil)
            }
            .disposed(by: disposeBag)
        
        playButton.rx.tap
            .bind(with: self) { owner, ss in
                input.playButtonTap.onNext(())
            }
            .disposed(by: disposeBag)
        
        saveButton.rx.tap
            .bind(with: self) { owner, _ in
                if let media = owner.viewModel.media {
                    let backdrop = owner.backdropImageView.image
                    
                    guard let posterURL = APIURL.imageURL(media.posterPath) else {
                        input.saveButtonTap.onNext((nil, backdrop))
                        return
                    }
                    posterURL.downloadImage { poster in
                        input.saveButtonTap.onNext((poster, backdrop))
                    }
                } else if let _ = owner.viewModel.realmMedia {
                    input.saveButtonTap.onNext((nil, nil))
                }
            }
            .disposed(by: disposeBag)
        
        output.list
            .bind(to: collectionView.rx.items(
                cellIdentifier: MediaCollectionViewCell.identifier,
                cellType: MediaCollectionViewCell.self)
            ) { row, media, cell in
                cell.configureCell(media.posterPath)
            }
            .disposed(by: disposeBag)
        
        output.list
            .subscribe(with: self) { owner, value in
                if value.isEmpty {
                    owner.similarLabel.text = ""
                }
            }
            .disposed(by: disposeBag)
        
        output.castText
            .map { "출연: ".localized + $0 }
            .bind(to: castLabel.rx.text)
            .disposed(by: disposeBag)
        
        output.creatorText
            .map { "크리에이터: ".localized + $0 }
            .bind(to: creatorLabel.rx.text)
            .disposed(by: disposeBag)
        
        output.popUpViewTrigger
            .bind(with: self) { owner, message in
                let alert = PopupViewController.create()
                    .addMessage(message)
                    .addButton(title: "확인".localized) {
                        owner.dismiss(animated: true)
                    }
                owner.present(alert, animated: true)
            }
            .disposed(by: disposeBag)
        
        output.toTrailerTrigger
            .bind(with: self) { owner, media in
                let (networkMedia, realmMedia) = media
                if let networkMedia {
                    let trailerVM = TrailerViewModel(media: networkMedia)
                    let trailerVC = TrailerViewController(viewModel: trailerVM)
                    owner.navigationController?.pushViewController(trailerVC, animated: true)
                } else if let realmMedia {
                    let trailerVM = TrailerViewModel(realmMedia: realmMedia)
                    let trailerVC = TrailerViewController(viewModel: trailerVM)
                    owner.navigationController?.pushViewController(trailerVC, animated: true)
                }
            }
            .disposed(by: disposeBag)
        viewModel.loadInitialData()
    }
}
