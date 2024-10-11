//
//  MediaTableHeaderView.swift
//  Popcorn
//
//  Created by 홍정민 on 10/9/24.
//

import UIKit
import SnapKit
import Then

final class MediaTableHeaderView: UITableViewHeaderFooterView {
    private let titleLabel = UILabel().then {
        $0.font = Design.Font.subtitle
        $0.textColor = .white
    }
    
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        
        contentView.addSubview(titleLabel)
        
        titleLabel.snp.makeConstraints { make in
            make.centerY.equalTo(contentView)
            make.leading.equalTo(contentView).offset(10)
            make.trailing.greaterThanOrEqualTo(contentView).inset(10)
        }
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setHeaderTitle(_ title: String) {
        titleLabel.text = title
    }
}
