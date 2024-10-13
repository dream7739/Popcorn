//
//  SearchEmpyView.swift
//  Popcorn
//
//  Created by 홍정민 on 10/11/24.
//

import UIKit
import SnapKit
import Then

final class SearchEmpyView: BaseView {
    private let descriptionLabel = UILabel().then {
        $0.font = Design.Font.primary
        $0.textColor = .white
        $0.text = "검색 결과가 없습니다".localized
    }

    override func configureHierarchy() {
        addSubview(descriptionLabel)
    }
    
    override func configureLayout() {
        descriptionLabel.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
    }
    
    override func configureView() {
        backgroundColor = .black
    }
}
