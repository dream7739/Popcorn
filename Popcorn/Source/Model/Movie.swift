//
//  Movie.swift
//  Popcorn
//
//  Created by 김성민 on 10/10/24.
//

import Foundation

// MARK: - 뷰에서 쓸 모델 (영화 + TV쇼 통합)
struct Movie {
    let id: Int
    let poster_path: String?
    let genre_ids: [Int]
    let isMovie: Bool
    // 배경
    let backdrop_path: String?
    // 제목
    let title: String
    // 별점
    let vote_average: Double
    // 줄거리
    let overview: String
}
