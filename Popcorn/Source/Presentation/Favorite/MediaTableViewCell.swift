//
//  MediaTableViewCell.swift
//  Popcorn
//
//  Created by 홍정민 on 10/9/24.
//

import UIKit
import SnapKit
import Then
import Kingfisher

final class MediaTableViewCell: UITableViewCell {
    private let thumbImage = UIImageView().then {
        $0.contentMode = .scaleAspectFill
        $0.clipsToBounds = true
    }
    
    private let titleLabel = UILabel().then {
        $0.font = Design.Font.primary
        $0.textColor = .white
    }
    
    private let playButton = UIButton().then {
        $0.imageBackground(Design.Image.playCircle)
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        configureHierarchy()
        configureLayout()
        contentView.backgroundColor = .black
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configureHierarchy() {
        contentView.addSubview(thumbImage)
        contentView.addSubview(titleLabel)
        contentView.addSubview(playButton)
    }
    
    private func configureLayout() {
        thumbImage.snp.makeConstraints { make in
            make.width.equalTo(90)
            make.height.equalTo(70)
            make.centerY.equalTo(contentView)
            make.leading.equalTo(contentView).offset(10)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.centerY.equalTo(contentView)
            make.leading.equalTo(thumbImage.snp.trailing).offset(8)
            make.trailing.greaterThanOrEqualTo(playButton.snp.leading).inset(8)
        }
        
        playButton.snp.makeConstraints { make in
            make.centerY.equalTo(contentView)
            make.size.equalTo(40)
            make.trailing.equalTo(contentView).inset(10)
        }
    }
    
    func configureData(_ data: Media) {
        titleLabel.text = data.title
        titleLabel.textColor = .white
        let url = APIURL.imageURL(data.posterPath)
        thumbImage.kf.setImage(with: url)
    }
    
    func configureData(_ data: RealmMedia) {
        titleLabel.text = data.title
        titleLabel.textColor = .white
        let image = ImageFileManager.shared.loadImageFile(filename: String(data.id))
        thumbImage.image = image
    }
}
