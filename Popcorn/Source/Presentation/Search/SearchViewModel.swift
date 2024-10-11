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
        let trendMovieList: BehaviorRelay<[Movie]>
    }
    
    var trendMovieResponse: MovieResponse?
    var trendMovieList: [Movie] = []
    var disposeBag = DisposeBag()
    
    func transform(input: Input) -> Output {
        let trendMovieList = BehaviorRelay<[Movie]>(value: [])
        
        let callTrendMovie = input.searchText
            .withUnretained(self)
            .filter { owner, value in
                value.trimmingCharacters(in: .whitespaces).isEmpty && owner.trendMovieResponse == nil
            }
        
        callTrendMovie
            .flatMap { _ in
                NetworkManager.shared.fetchMovie(with: Router.trending(type: .movie))
            }
            .bind(with: self) { owner, result in
                switch result {
                case .success(let value):
                    owner.trendMovieResponse = value
                    let data = value.results.map {
                        Movie(
                            id: $0.id,
                            poster_path: $0.poster_path,
                            genre_ids: $0.genre_ids,
                            isMovie: true,
                            backdrop_path: $0.backdrop_path,
                            title: $0.title,
                            vote_average: $0.vote_average,
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
