//
//  Router.swift
//  Popcorn
//
//  Created by dopamint on 10/8/24.
//

import Alamofire
import Foundation

enum Router: URLRequestConvertible {
    
    case search(type: ContentType, query: String, page: Int, language: Language? = nil)
    case trending(type: ContentType, language: Language? = nil)
    case credits(type: ContentType, contentId: Int, language: Language? = nil)
    case similar(type: ContentType, contentId: Int, language: Language? = nil)
    case genre(type: ContentType, language: Language? = nil)
    case video(type: ContentType, contentId: Int, language: Language? = nil)
    
    enum ContentType: String {
        case tv
        case movie
    }
    
    enum Language: String {
        case korean = "ko-KR"
        case english = "en-US" // default
        
        static func current() -> Language {
            let languageCode = Locale.current.languageCode ?? "ko"
            return languageCode.lowercased().hasPrefix("ko") ? .korean : .english
        }
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
        case .search(let type, _, _, _):
            return "search/\(type.rawValue)"
        case .trending(let type, _):
            return "trending/\(type.rawValue)/day"
        case .credits(let type, let id, _):
            return "\(type.rawValue)/\(id)/credits"
        case .similar(let type, let id, _):
            return "\(type.rawValue)/\(id)/similar"
        case .genre(let type, _):
            return "genre/\(type.rawValue)/list"
        case .video(let type, let id, _):
            return "\(type.rawValue)/\(id)/videos"
        }
    }
    
    var queryItems: [URLQueryItem]? {
        switch self {
        case .search(_, let query, let page, let language):
            return [
                URLQueryItem(name: "query", value: query),
                URLQueryItem(name: "language", value: language?.rawValue ?? Language.current().rawValue),
                URLQueryItem(name: "page", value: "\(page)")
            ]
        default:
            return nil
        }
    }
    
    private var parameter: Parameters? {
        switch self {
        case .search:
            return nil
        case .trending(_, let language),
                .credits(_, _, let language),
                .genre(_, let language),
                .video(_, _, let language),
                .similar(_, _, let language):
//            return ["language": "ko-KR"]
            return ["language": language?.rawValue ?? Language.current().rawValue]
        }
    }
}

extension Router {
    func asURLRequest() throws -> URLRequest {
        let url = try baseURL.appending(path).asURL()
        var request = URLRequest(url: url)
        request.method = method
        request.headers = header
        if let queryItems {
            if #available(iOS 16.0, *) {
                request.url?.append(queryItems: queryItems)
            } else {
                if let url = request.url {
                    var urlComponent = URLComponents(url: url, resolvingAgainstBaseURL: false)
                    urlComponent?.queryItems = queryItems
                    request.url = urlComponent?.url
                }
            }
        }
        print(request)
        return try URLEncoding.default.encode(request, with: parameter)
    }
}
