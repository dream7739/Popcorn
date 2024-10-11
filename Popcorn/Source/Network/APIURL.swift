//
//  APIURL.swift
//  Popcorn
//
//  Created by 김성민 on 10/10/24.
//

import Foundation

// MARK: - image, video Base URL
enum APIURL {
    
    // Kingfisher 사용
    static let imageBaseURL = "http://image.tmdb.org/t/p/w500/"
    
    // Webview 사용 (뒤에 videoAPI 응답값 중 key 덧붙여서 사용)
    static let videoBaseURL = "https://www.youtube.com/watch?v="
    
    static func imageURL(_ str: String?) -> URL? {
        guard let str else { return nil }
        return URL(string: APIURL.imageBaseURL + str)
    }
    
    static func videoURL(_ str: String) -> String {
        return APIURL.videoBaseURL + str
    }
}
