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
        // TODO: - 'main' will be deprecated 대체하기
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
    
    // MARK: - 트렌드 화면 - 지금 뜨는 영화, 지금 뜨는 TV 시리즈
    static func trendLayout() -> UICollectionViewFlowLayout {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        
        let cellSpacing: CGFloat = 10
        
        // 셀 사이즈
        let width = 100
        let height = 150
        layout.itemSize = CGSize(width: width, height: height)
        layout.scrollDirection = .horizontal
        layout.minimumInteritemSpacing = cellSpacing
        layout.minimumLineSpacing = cellSpacing
        
        return layout
    }
    
}
