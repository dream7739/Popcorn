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
    static func trendLayout() -> UICollectionViewCompositionalLayout {
        return UICollectionViewCompositionalLayout { sectionIndex, layoutEnvironment -> NSCollectionLayoutSection? in
            switch sectionIndex {
            case 0:
                return UICollectionViewLayout.posterLayoutSection()
            default:
                return UICollectionViewLayout.trendLayoutSection()
            }
        }
    }
    
    // 첫 번째 섹션 - 헤더뷰만 사용
    static func posterLayoutSection() -> NSCollectionLayoutSection {
        // 헤더 크기
        let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(500))
        let headerItem = NSCollectionLayoutBoundarySupplementaryItem(
            layoutSize: headerSize,
            elementKind: UICollectionView.elementKindSectionHeader,
            alignment: .top
        )
        
        // 섹션 레이아웃 (그룹 없이 헤더만 설정)
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(0.01))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(0.01))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        let section = NSCollectionLayoutSection(group: group)
        section.boundarySupplementaryItems = [headerItem]
        return section
    }
    
    // 두 번째, 세 번째 섹션
    static func trendLayoutSection() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(widthDimension: .absolute(100), heightDimension: .absolute(150))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupSize = NSCollectionLayoutSize(widthDimension: .absolute(100), heightDimension: .absolute(150))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        
        // 섹션 레이아웃
        let section = NSCollectionLayoutSection(group: group)
        // 가로 스크롤
        section.orthogonalScrollingBehavior = .continuous
        section.interGroupSpacing = 10
        section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 20, trailing: 0)
        
        // 헤더 크기
        let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(50))
        let headerItem = NSCollectionLayoutBoundarySupplementaryItem(
            layoutSize: headerSize,
            elementKind: UICollectionView.elementKindSectionHeader,
            alignment: .top
        )
        section.boundarySupplementaryItems = [headerItem]
        return section
    }
}
