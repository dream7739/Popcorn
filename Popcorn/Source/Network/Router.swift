//
//  Router.swift
//  Popcorn
//
//  Created by dopamint on 10/8/24.
//

import Alamofire
import Foundation

enum Router: URLRequestConvertible {
    
    case search(type: ContentType, query: String, language: Language?)
    case trending(type: ContentType, language: Language?)
    case credits(type: ContentType, contentId: Int, language: Language?)
    case similar(type: ContentType, contentId: Int, language: Language?)
    case genre(type: ContentType, language: Language?)
    case video(type: ContentType, contentId: Int, language: Language?)
    
    enum ContentType: String {
        case tv = "tv"
        case movie = "movie"
    }

    enum Language: String {
        case korean = "ko-KR"
        case english = "en-US" // default
    }
    
    // MARK: URL components -
    
    var method: HTTPMethod {
        return .get
    }
    
    private var baseURL: String {
        return "https://api.themoviedb.org/3/"
    }
    
    private var header: HTTPHeaders {
        return ["Authorization": APIKey.acessToken]
    }
    
    private var path: String {
        switch self {
        case .search(let type, _, _):
            return "search/\(type.rawValue)/"
        case .trending(let type, _):
            return "trending/\(type.rawValue)/day"
        case .credits(let type, let id, _):
            return "\(type.rawValue)/\(id)/credits"
        case .similar(let type, let id, _):
            return "\(type.rawValue)/\(id)/\(type.rawValue)"
        case .genre(let type, _):
            return "genre/\(type.rawValue)/list"
        case .video(let type, let id, _):
            return "\(type.rawValue)/\(id)/videos"
        }
    }
    
    private var parameter: Parameters? {
        switch self {
        case .search(_, let query, let language):
            return ["query": query, "language": "ko-KR"]
        case .trending(_, let language),
                .credits(_, _, let language),
                .genre(_, let language),
                .video(_, _, let language),
                .similar(_, _, let language):
            return ["language": "ko-KR"]
//            return ["language": language?.rawValue ?? ""]
        }
    }
}

extension Router {
    func asURLRequest() throws -> URLRequest {
        let url = try baseURL.appending(path).asURL()
        var request = URLRequest(url: url)
        request.method = method
        request.headers = header
        return try URLEncoding.default.encode(request, with: parameter)
    }
}
