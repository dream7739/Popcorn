//
//  Movie.swift
//  Popcorn
//
//  Created by 김성민 on 10/10/24.
//

import Foundation
import RxDataSources

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

// MARK: - RxDataSources 관련 프로토콜
extension Movie: IdentifiableType, Equatable {
    var identity: UUID {
        return UUID()
    }
}

// MARK: - 임시로 구성한 장르 딕셔너리 -> 통신으로 변경 예정
extension Movie {
    static let genreDict: [Int: String] = [
        28: "Action",
        12: "Adventure",
        16: "Animation",
        35: "Comedy",
        80: "Crime",
        99: "Documentary",
        18: "Drama",
        10751: "Family",
        14: "Fantasy",
        36: "History",
        27: "Horror",
        10402: "Music",
        9648: "Mystery",
        10749: "Romance",
        878: "Science Fiction",
        10770: "TV Movie",
        53: "Thriller",
        10752: "War",
        37: "Western"
    ]
    
    var genreText: String {
        return genre_ids.map { "#\(Movie.genreDict[$0] ?? "")" }.joined(separator: " ")
    }
}
