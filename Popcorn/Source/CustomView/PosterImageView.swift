//
//  PosterImageView.swift
//  Popcorn
//
//  Created by 김성민 on 10/9/24.
//

import UIKit
import Kingfisher
import SnapKit
import Then

final class PosterImageView: BaseView {
    
    private let imageView = UIImageView().then {
        $0.contentMode = .scaleAspectFill
        $0.backgroundColor = .systemGray2
        $0.clipsToBounds = true
        $0.layer.cornerRadius = 10
    }
    
    override func configureHierarchy() {
        addSubview(imageView)
    }
    
    override func configureLayout() {
        imageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    override func configureView() {}
    
    func setImageView(_ image: UIImage?) {
        imageView.image = image
    }
    
    func setImageView(_ urlString: String?) {
        let url = APIURL.imageURL(urlString)
        imageView.kf.setImage(with: url)
    }
}
