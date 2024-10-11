//
//  MovieCollectionViewCell.swift
//  Popcorn
//
//  Created by 김성민 on 10/9/24.
//

import UIKit
import SnapKit

final class MovieCollectionViewCell: BaseCollectionViewCell {
    
    private let imageView = PosterImageView()
    
    override func configureHierarchy() {
        addSubview(imageView)
    }
    
    override func configureLayout() {
        imageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    func configureCell(_ image: UIImage?) {
        imageView.setImageView(image)
    }
    
    func configureCell(_ urlString: String?) {
        imageView.setImageView(urlString)
    }
}
