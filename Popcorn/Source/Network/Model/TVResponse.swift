//
//  TVResponse.swift
//  Popcorn
//
//  Created by 김성민 on 10/9/24.
//

import Foundation

// MARK: - Trending / Search / Similar 모델
struct TVResponse: Decodable {
    let page: Int
    let results: [TVResult]
    let total_pages: Int
    let total_results: Int
    
    struct TVResult: Decodable {
        let adult: Bool
        let backdrop_path: String?
        let genre_ids: [Int]
        let id: Int
        let origin_country: [String]
        let original_language: String
        let original_name: String
        let overview: String
        let popularity: Double
        let poster_path: String?
        let first_air_date: String
        let name: String
        let vote_average: Double
        let vote_count: Int
    }
}

extension TVResponse.TVResult {
    func toMovie() -> Movie {
        return Movie(
            id: self.id,
            poster_path: self.poster_path,
            genre_ids: self.genre_ids,
            isMovie: false,
            backdrop_path: self.backdrop_path,
            title: self.name,
            vote_average: self.vote_average,
            overview: self.overview
        )
    }
}
