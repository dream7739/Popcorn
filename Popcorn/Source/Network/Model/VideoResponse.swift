//
//  VideoResponse.swift
//  Popcorn
//
//  Created by 김성민 on 10/9/24.
//

import Foundation

// MARK: - Video 모델 (Movie + TV)
struct VideoResponse: Decodable {
    let id: Int
    let results: [VideoResult]
}

struct VideoResult: Decodable {
    let iso_639_1: String
    let iso_3166_1: String
    let name: String
    let key: String
    let site: String
    let size: Int
    let type: String
    let official: Bool
    let published_at: String
    let id: String
}
