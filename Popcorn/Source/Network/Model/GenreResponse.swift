//
//  GenreResponse.swift
//  Popcorn
//
//  Created by 김성민 on 10/9/24.
//

import Foundation

// MARK: - Genre 모델 (Movie + TV)
struct GenreResponse: Decodable {
    let genres: [Genre]
}

struct Genre: Decodable {
    let id: Int
    let name: String
}
