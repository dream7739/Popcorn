//
//  NetworkManager.swift
//  Popcorn
//
//  Created by dopamint on 10/8/24.
//

import UIKit
import Alamofire
import RxSwift

final class NetworkManager {
    static let shared = NetworkManager()
    private init() {}
    
    private func request<T: Decodable>(api: Router) -> Single<Result<T, AFError>> {
        return Single.create { [weak self] observer in
            guard let self else { return Disposables.create() }
            let request: DataRequest
            request = AF.request(api)
            request.validate(statusCode: 200..<300)
                .responseDecodable(of: T.self) { [weak self] response in
                    switch response.result {
                    case .success(let value):
                        print("✅✅✅✅✅  succeeded")
                        observer(.success(.success(value)))
                    case .failure(let error):
                        print("❌❌❌❌❌ failed: \(error)")
                        self?.handleError(errorCode: error, observer: observer)
                        observer(.success(.failure(error)))
                    }
                }
            return Disposables.create()
        }
    }
    
    private func handleError<T: Decodable>(errorCode: AFError, observer: @escaping (SingleEvent<Result<T, AFError>>) -> Void) {
        
        switch errorCode {
        case .createURLRequestFailed(error: let error):
            print(error as Any)
        case .explicitlyCancelled:
            print("aaa")
        case .invalidURL(url: let url):
            print(url)
        case .responseValidationFailed(reason: let reason):
            print(reason)
        case .responseSerializationFailed(reason: let reason):
            print(reason)
        case .sessionInvalidated(error: let error):
            print(error as Any)
        case .sessionTaskFailed(error: let error):
            print(error as Any)
        default:
            observer(.success(.failure(errorCode)))
        }
    }
    
}

extension NetworkManager {
    func fetchData<T: Decodable>(with router: Router, as type: T.Type) -> Single<Result<T, AFError>> {
        return request(api: router)
    }
}
