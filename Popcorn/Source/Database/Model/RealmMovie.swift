//
//  RealmMovie.swift
//  Popcorn
//
//  Created by 김성민 on 10/8/24.
//

import Foundation
import RealmSwift

// TODO: - 회의 후 추가 필요 - 배경, 별점, 줄거리
class RealmMovie: Object {
    @Persisted(primaryKey: true) var id: Int
    @Persisted var savedDate: Date
    
    @Persisted var name: String
    @Persisted var videoURL: String
    @Persisted var isMovie: Bool
    
    convenience init(id: Int, name: String, videoURL: String, isMovie: Bool) {
        self.init()
        self.id = id
        self.savedDate = Date()
        self.name = name
        self.videoURL = videoURL
        self.isMovie = isMovie
    }
}
