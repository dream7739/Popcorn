//
//  TrendCollectionHeaderView.swift
//  Popcorn
//
//  Created by 김성민 on 10/10/24.
//

import UIKit

final class TrendCollectionHeaderView: UICollectionReusableView {
    
    private let titleLabel = UILabel().then {
        $0.font = Design.Font.title
        $0.textColor = .white
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(titleLabel)
        titleLabel.snp.makeConstraints {
            $0.verticalEdges.equalToSuperview()
            $0.horizontalEdges.equalToSuperview().inset(16)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configureHeader(_ text: String) {
        titleLabel.text = text
    }
}
