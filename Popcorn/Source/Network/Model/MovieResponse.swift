//
//  MovieResponse.swift
//  Popcorn
//
//  Created by 김성민 on 10/9/24.
//

import Foundation

// MARK: - Trending / Search / Similar 모델
struct MovieResponse: Decodable {
    let page: Int
    let results: [MovieResult]
    let total_pages: Int
    let total_results: Int
}

struct MovieResult: Decodable {
    let adult: Bool
    let backdrop_path: String?
    let genre_ids: [Int]
    let id: Int
    let original_language: String
    let original_title: String
    let overview: String
    let popularity: Double
    let poster_path: String?
    let release_date: String
    let title: String
    let video: Bool
    let vote_average: Double
    let vote_count: Int
}
