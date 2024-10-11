//
//  TrendingViewModel.swift
//  Popcorn
//
//  Created by 김성민 on 10/10/24.
//

import Foundation
import RxSwift
import RxDataSources

typealias TrendSection = AnimatableSectionModel<String, Movie>

final class TrendingViewModel: BaseViewModel {
    
    private enum Section: String, CaseIterable {
        case poster = "메인 포스터"
        case movie = "지금 뜨는 영화"
        case tv = "지금 뜨는 TV 시리즈"
    }
    
    var disposeBag = DisposeBag()
    
    struct Input {
        
    }
    
    struct Output {
        let sections: PublishSubject<[TrendSection]>
    }
    
    func transform(input: Input) -> Output {
        let sections = PublishSubject<[TrendSection]>()
        let mainPoster = PublishSubject<[Movie]>()
        let trendMovies = PublishSubject<[Movie]>()
        let trendTVs = PublishSubject<[Movie]>()
        let genres = PublishSubject<[Genre]>()
        
        // 트렌드 영화 통신
        fetchTrendingMovies(trendMovies)
        // 트렌드 TV 통신
        fetchTrendingTVs(trendTVs)
        
        // 영화와 TV 중 랜덤으로 하나의 요소를 선택
        Observable.combineLatest(trendMovies.asObservable(), trendTVs.asObservable())
            .subscribe { movies, tvShows in
                let allItems = movies + tvShows
                if let randomItem = allItems.randomElement() {
                    print("랜덤 영화, TV 성공")
                    mainPoster.onNext([randomItem])
                } else {
                    print("랜덤 영화, TV 실패")
                    mainPoster.onNext([])
                }
            }
            .disposed(by: disposeBag)
        
        // 랜덤 아이템 뽑혔을 때 장르 API 통신
        mainPoster
            .compactMap { $0.first }
            .flatMap { movie in
                NetworkManager.shared.fetchData(
                    with: .genre(type: movie.isMovie ? .movie : .tv, language: .korean),
                    as: GenreResponse.self
                )
            }
            .subscribe(with: self) { owner, result in
                switch result {
                case .success(let response):
                    print("장르 통신 성공")
                    genres.onNext(response.genres)
                case .failure(let error):
                    print("장르 통신 실패", error)
                }
            }
            .disposed(by: disposeBag)
        
        // 섹션 설정
        Observable.combineLatest(trendMovies.asObservable(), trendTVs.asObservable(), mainPoster.asObservable(), genres.asObservable())
            .map(createSections)
            .bind(to: sections)
            .disposed(by: disposeBag)
        
        return Output(sections: sections)
    }
}

extension TrendingViewModel {
    private func fetchTrendingMovies(_ subject: PublishSubject<[Movie]>) {
        NetworkManager.shared.fetchData(
            with: .trending(type: .movie, language: .korean),
            as: MovieResponse.self
        )
        .subscribe { result in
            switch result {
            case .success(let response):
                print("트렌드 - 영화 통신 성공")
                subject.onNext(response.results.map { $0.toMovie() })
            case .failure(let error):
                print("트렌드 - 영화 통신 실패", error)
            }
        }
        .disposed(by: disposeBag)
    }

    private func fetchTrendingTVs(_ subject: PublishSubject<[Movie]>) {
        NetworkManager.shared.fetchData(
            with: .trending(type: .tv, language: .korean),
            as: TVResponse.self
        )
        .subscribe { result in
            switch result {
            case .success(let response):
                print("트렌드 - TV 통신 성공")
                subject.onNext(response.results.map { $0.toMovie() })
            case .failure(let error):
                print("트렌드 - TV 통신 실패", error)
            }
        }
        .disposed(by: disposeBag)
    }
    
    private func createSections(movies: [Movie], tvShows: [Movie], main: [Movie], genres: [Genre]) -> [TrendSection] {
        var genreDict = [Int: String]()
        for genre in genres {
            genreDict[genre.id] = genre.name
        }
        let genreText = main.first?.genre_ids.map { genreDict[$0] ?? "" }.joined(separator: " ")

        return [
            TrendSection(model: genreText ?? "", items: main),
            TrendSection(model: Section.movie.rawValue, items: movies),
            TrendSection(model: Section.tv.rawValue, items: tvShows)
        ]
    }
}