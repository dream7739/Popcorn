//
//  TrendCollectionHeaderView.swift
//  Popcorn
//
//  Created by 김성민 on 10/10/24.
//

import UIKit
import SnapKit
import Then

final class TrendCollectionHeaderView: UICollectionReusableView {
    
    private let titleLabel = UILabel().then {
        $0.font = Design.Font.subtitle
        $0.textColor = .white
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(titleLabel)
        titleLabel.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configureHeader(_ text: String) {
        titleLabel.text = text
    }
    
    func configureLeftPadding() {
        titleLabel.snp.removeConstraints()
        titleLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(10)
            make.centerY.equalToSuperview()
        }
    }
}
