//
//  SearchViewModel.swift
//  Popcorn
//
//  Created by 홍정민 on 10/10/24.
//

import Foundation
import RxSwift
import RxCocoa

final class SearchViewModel: BaseViewModel {
    struct Input {
        let searchText: ControlProperty<String>
    }
    
    struct Output {
        let trendMovieList: BehaviorRelay<[Media]>
    }
    
    var trendMovieResponse: MovieResponse?
    var trendMovieList: [Media] = []
    var disposeBag = DisposeBag()
    
    func transform(input: Input) -> Output {
        let trendMovieList = BehaviorRelay<[Media]>(value: [])
        
        let callTrendMovie = input.searchText
            .withUnretained(self)
            .filter { owner, value in
                value.trimmingCharacters(in: .whitespaces).isEmpty && owner.trendMovieResponse == nil
            }
        
        callTrendMovie
            .flatMap { _ in
                NetworkManager.shared.fetchData(with: .trending(type: .movie), as: MovieResponse.self)
            }
            .bind(with: self) { owner, result in
                switch result {
                case .success(let value):
                    owner.trendMovieResponse = value
                    let data = value.results.map {
                        Media(
                            id: $0.id,
                            posterPath: $0.poster_path,
                            genreIDs: $0.genre_ids,
                            isMovie: true,
                            backdropPath: $0.backdrop_path,
                            title: $0.title,
                            voteAverage: $0.vote_average,
                            overview: $0.overview
                        )
                    }
                    owner.trendMovieList = data
                    trendMovieList.accept(data)
                case .failure(let error):
                    print(error)
                }
            }
            .disposed(by: disposeBag)
        
        return Output(
            trendMovieList: trendMovieList
        )
    }
    
}
