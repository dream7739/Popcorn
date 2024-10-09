//
//  UICollectionViewLayout+.swift
//  Popcorn
//
//  Created by 김성민 on 10/9/24.
//

import UIKit

extension UICollectionViewLayout {
    
    // MARK: - 검색 화면 / 상세 화면 - 비슷한 콘텐츠
    static func searchLayout() -> UICollectionViewFlowLayout {
        let layout = UICollectionViewFlowLayout()
        
        let sectionSpacing: CGFloat = 10
        let cellSpacing: CGFloat = 10
        let cellCount: CGFloat = 3
        
        // 셀 사이즈
        let totalWidth = UIScreen.main.bounds.width - 2 * sectionSpacing - (cellCount - 1) * cellSpacing
        let width = totalWidth / cellCount
        let height = width * 1.5
        layout.itemSize = CGSize(width: width, height: height)
        layout.scrollDirection = .vertical
        layout.minimumInteritemSpacing = cellSpacing
        layout.minimumLineSpacing = cellSpacing
        layout.sectionInset = UIEdgeInsets(top: sectionSpacing, left: sectionSpacing, bottom: sectionSpacing, right: sectionSpacing)
        
        return layout
    }
    
}
