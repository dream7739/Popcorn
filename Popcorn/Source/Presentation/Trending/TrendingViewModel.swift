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
        var trendMovies = PublishSubject<[Movie]>()
        let trendTVs = PublishSubject<[Movie]>()
        
        // 트렌드 영화 통신
        NetworkManager.shared.fetchData(
            with: .trending(type: .movie, language: .korean),
            as: MovieResponse.self
        )
        .subscribe(with: self) { owner, result in
            switch result {
            case .success(let response):
//                print("Trending \(response)")
                let movies = response.results.map { $0.toMovie() }
                print("영화 통신 완료!")
                trendMovies.onNext(movies)
            case .failure(let error):
                print("Error fetching trending  \(error)")
            }
        }
        .disposed(by: disposeBag)
        
        // 트렌드 TV 통신
        NetworkManager.shared.fetchData(
            with: .trending(type: .tv, language: .korean),
            as: TVResponse.self
        )
        .subscribe(with: self) { owner, result in
            switch result {
            case .success(let response):
//                print("Trending \(response)")
                let movies = response.results.map { $0.toMovie() }
                print("TV 통신 완료!")
                trendTVs.onNext(movies)
            case .failure(let error):
                print("Error fetching trending \(error)")
            }
        }
        .disposed(by: disposeBag)
        
        // 영화와 TV 중 랜덤으로 하나의 요소를 선택
        Observable.combineLatest(trendMovies.asObservable(), trendTVs.asObservable())
            .subscribe { movies, tvShows in
                let allItems = movies + tvShows
                if let randomItem = allItems.randomElement() {
                    print("✅ 메인 있음!")
                    mainPoster.onNext([randomItem])
                } else {
                    print("❌ 메인 없음!")
                    mainPoster.onNext([])
                }
            }
            .disposed(by: disposeBag)
        
        // 섹션 설정
        Observable.combineLatest(trendMovies.asObservable(), trendTVs.asObservable(), mainPoster.asObservable())
            .subscribe(with: self) { owner, value in
                let (movies, tvShows, main) = value
                let newSections = [
                    TrendSection(model: Section.poster.rawValue, items: main),
                    TrendSection(model: Section.movie.rawValue, items: movies),
                    TrendSection(model: Section.tv.rawValue, items: tvShows)
                ]
                print("섹션 생성!")
                sections.onNext(newSections)
            }
            .disposed(by: disposeBag)
        
        return Output(sections: sections)
    }
}
