//
//  PosterCollectionViewCell.swift
//  Popcorn
//
//  Created by 김성민 on 10/10/24.
//

import UIKit
import Kingfisher
import SnapKit
import Then

final class PosterCollectionHeaderView: UICollectionReusableView {
    
    private let containerView = UIView().then {
        $0.clipsToBounds = true
        $0.layer.cornerRadius = 10
    }
    private let posterImageView = PosterImageView()
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
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureHierarchy()
        configureLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configureHierarchy() {
        [playButton, saveButton].forEach {
            buttonStackView.addArrangedSubview($0)
        }
        [posterImageView, genreLabel, buttonStackView].forEach {
            containerView.addSubview($0)
        }
        addSubview(containerView)
    }
    
    func configureLayout() {
        containerView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(20)
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
    }
    
    func configureHeader(_ movie: Movie?) {
        guard let movie else { return }
        posterImageView.setImageView(movie.poster_path)
        genreLabel.text = movie.genreText
    }
}
