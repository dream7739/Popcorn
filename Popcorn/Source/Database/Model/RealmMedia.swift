//
//  RealmMedia.swift
//  Popcorn
//
//  Created by 김성민 on 10/8/24.
//

import Foundation
import RealmSwift

// TODO: - 회의 후 추가 필요 - 배경, 별점, 줄거리
class RealmMedia: Object {
    @Persisted(primaryKey: true) var id: Int
    @Persisted var savedDate: Date
    @Persisted var title: String
    @Persisted var isMovie: Bool
    @Persisted var voteAverage: Double
    @Persisted var overview: String
    
    convenience init(
        id: Int,
        title: String,
        isMovie: Bool,
        voteAverage: Double,
        overview: String
    ) {
        self.init()
        self.id = id
        self.savedDate = Date()
        self.title = title
        self.isMovie = isMovie
        self.voteAverage = voteAverage
        self.overview = overview
    }
}
