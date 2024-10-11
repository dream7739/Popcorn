//
//  Media.swift
//  Popcorn
//
//  Created by 김성민 on 10/10/24.
//

import Foundation
import RxDataSources

// MARK: - 뷰에서 쓸 모델 (영화 + TV쇼 통합)
struct Media {
    let id: Int
    let posterPath: String?
    let genreIDs: [Int]
    let isMovie: Bool
    
    // MARK: - 상세 화면에 보여질 정보
    let backdropPath: String?
    let title: String
    let voteAverage: Double
    let overview: String
}

// MARK: - RxDataSources 관련 프로토콜
extension Media: IdentifiableType, Equatable {
    var identity: UUID {
        return UUID()
    }
}
