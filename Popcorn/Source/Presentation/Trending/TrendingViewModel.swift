//
//  TrendingViewModel.swift
//  Popcorn
//
//  Created by 김성민 on 10/10/24.
//

import Foundation
import RxSwift
import RxDataSources

typealias TrendSection = AnimatableSectionModel<String, String>

final class TrendingViewModel {
    
    private enum Section: String, CaseIterable {
        case recent = "지금 뜨는 영화"
        case category = "지금 뜨는 TV 시리즈"
    }
    
    var sections: [TrendSection] = Section.allCases
        .map { TrendSection(model: $0.rawValue, items: []) }
    
    private let disposeBag = DisposeBag()
    
    struct Input {
        
    }
    
    struct Output {
        
    }
    
    func transform(input: Input) -> Output {
        
        return Output()
    }
      
    private func fetchTrendingMovie() {
        let router = Router.trending(type: .movie, language: .korean)
        NetworkManager.shared.fetchData(with: router, as: MovieResponse.self)
            .subscribe(onSuccess: { result in
                switch result {
                case .success(let response):
                    print("Trending \(response)")
                case .failure(let error):
                    print("Error fetching trending  \(error)")
                }
            })
            .disposed(by: disposeBag)
    }
    
    private func fetchTrendingTV() {
        let router = Router.trending(type: .tv, language: .korean)
        NetworkManager.shared.fetchData(with: router, as: TVResponse.self)
            .subscribe(onSuccess: { result in
                switch result {
                case .success(let response):
                    print("Trending \(response)")
                case .failure(let error):
                    print("Error fetching trending  \(error)")
                }
            })
            .disposed(by: disposeBag)
    }
    
    private func fetchTrending(type: Router.ContentType) {
            let router = Router.trending(type: type, language: .korean)
            
            switch type {
            case .movie:
                NetworkManager.shared.fetchData(with: router, as: MovieResponse.self)
                    .subscribe(onSuccess: { result in
                        switch result {
                        case .success(let response):
                            print("Trending \(response)")
                        case .failure(let error):
                            print("Error fetching trending  \(error)")
                        }
                    })
                    .disposed(by: disposeBag)
            case .tv:
                NetworkManager.shared.fetchData(with: router, as: TVResponse.self)
                    .subscribe(onSuccess: { result in
                        switch result {
                        case .success(let response):
                            print("Trending \(response)")
                        case .failure(let error):
                            print("Error fetching trending  \(error)")
                        }
                    })
                    .disposed(by: disposeBag)
            }
        }
        
    private func fetchData<T: Decodable>(router: Router, responseType: T.Type) {
        NetworkManager.shared.fetchData(with: router, as: responseType)
            .subscribe(onSuccess: { result in
                switch result {
                case .success(let response):
                    print("Trending \(response)")
                case .failure(let error):
                    print("Error fetching trending  \(error)")
                }
            })
            .disposed(by: disposeBag)
    }
}
