//
//  TrendingViewModel.swift
//  Popcorn
//
//  Created by 김성민 on 10/10/24.
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources

typealias TrendSection = AnimatableSectionModel<String, Media>

final class TrendingViewModel: BaseViewModel {
    
    private enum Section: String, CaseIterable {
        case poster = "메인 포스터"
        case movie = "지금 뜨는 영화"
        case tv = "지금 뜨는 TV 시리즈"
    }
    
    private let repository = MediaRepository()
    var disposeBag = DisposeBag()
    
    struct Input {
        let playButtonTap: PublishSubject<Void>
        let saveButtonTap: PublishSubject<UIImage?>
        let cellTap: ControlEvent<IndexPath>
    }
    
    struct Output {
        let sections: PublishSubject<[TrendSection]>
        let toDetailTrigger: PublishSubject<Media>
        let toTrailerTrigger: PublishSubject<Media>
        let popUpViewTrigger: PublishSubject<String>
    }
    
    func transform(input: Input) -> Output {
        let sections = PublishSubject<[TrendSection]>()
        let mainPoster = PublishSubject<[Media]>()
        let trendMovies = PublishSubject<[Media]>()
        let trendTVs = PublishSubject<[Media]>()
        let genres = PublishSubject<[Genre]>()
        let toDetailTrigger = PublishSubject<Media>()
        let toTrailerTrigger = PublishSubject<Media>()
        let popUpViewTrigger = PublishSubject<String>()
        
        // 트렌드 영화 / TV 통신
        fetchTrendingMovies(trendMovies)
        fetchTrendingTVs(trendTVs)
        
        // 영화와 TV 중 랜덤으로 하나의 요소를 선택
        Observable.combineLatest(trendMovies.asObservable(), trendTVs.asObservable())
            .subscribe { movies, tvShows in
                let allItems = movies + tvShows
                if let randomItem = allItems.randomElement() {
                    mainPoster.onNext([randomItem])
                } else {
                    mainPoster.onNext([])
                }
            }
            .disposed(by: disposeBag)
        
        // 랜덤 아이템 뽑혔을 때 장르 API 통신
        fetchGenre(mainPoster, genres)
        
        // 섹션 설정
        Observable.combineLatest(trendMovies.asObservable(), trendTVs.asObservable(), mainPoster.asObservable(), genres.asObservable())
            .map(createSections)
            .bind(to: sections)
            .disposed(by: disposeBag)
        
        // 셀 탭 -> 디테일뷰
        input.cellTap
            .withLatestFrom(sections) { ($0, $1) }
            .subscribe(with: self) { owner, value in
                let (indexPath, sections) = value
                let section = sections[indexPath.section]
                let media = section.items[indexPath.item]
                toDetailTrigger.onNext(media)
            }
            .disposed(by: disposeBag)
        
        // 재생 버튼 탭 -> 웹뷰
        input.playButtonTap.withLatestFrom(sections)
            .subscribe(with: self) { owner, section in
                if let media = section[0].items.first {
                    toTrailerTrigger.onNext(media)
                } else {
                    print("메인 포스터 데이터 없음")
                }
            }
            .disposed(by: disposeBag)
        
        // 저장 버튼 탭 -> 렘 추가 + 팝업 뷰
        input.saveButtonTap
            .withLatestFrom(sections) { ($0, $1) }
            .subscribe(with: self) { owner, value in
                let (image, sections) = value
                if let media = sections[0].items.first {
                    let realmMedia = media.toRealmMedia()
                    if owner.repository.contains(media.id) {
                        popUpViewTrigger.onNext("이미 저장된 미디어에요 :)")
                    } else {
                        owner.repository.addItem(item: realmMedia, image: image)
                        popUpViewTrigger.onNext("미디어를 저장했어요 :)")
                    }
                } else {
                    print("메인 포스터 데이터 없음")
                }
            }
            .disposed(by: disposeBag)
        
        return Output(
            sections: sections,
            toDetailTrigger: toDetailTrigger,
            toTrailerTrigger: toTrailerTrigger,
            popUpViewTrigger: popUpViewTrigger
        )
    }
}

extension TrendingViewModel {
    private func fetchTrendingMovies(_ subject: PublishSubject<[Media]>) {
        NetworkManager.shared.fetchData(
            with: .trending(type: .movie, language: .korean),
            as: MovieResponse.self
        )
        .subscribe { result in
            switch result {
            case .success(let response):
                print("트렌드 - 영화 통신 성공")
                subject.onNext(response.results.map { $0.toMedia() })
            case .failure(let error):
                print("트렌드 - 영화 통신 실패", error)
            }
        }
        .disposed(by: disposeBag)
    }
    
    private func fetchTrendingTVs(_ subject: PublishSubject<[Media]>) {
        NetworkManager.shared.fetchData(
            with: .trending(type: .tv, language: .korean),
            as: TVResponse.self
        )
        .subscribe { result in
            switch result {
            case .success(let response):
                print("트렌드 - TV 통신 성공")
                subject.onNext(response.results.map { $0.toMedia() })
            case .failure(let error):
                print("트렌드 - TV 통신 실패", error)
            }
        }
        .disposed(by: disposeBag)
    }
    
    private func fetchGenre(_ mainPoster: PublishSubject<[Media]>, _ genres: PublishSubject<[Genre]>) {
        mainPoster
            .compactMap { $0.first }
            .flatMap { media in
                NetworkManager.shared.fetchData(
                    with: .genre(type: media.isMovie ? .movie : .tv, language: .korean),
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
    }
    
    private func createSections(movies: [Media], tvShows: [Media], main: [Media], genres: [Genre]) -> [TrendSection] {
        var genreDict = [Int: String]()
        for genre in genres {
            genreDict[genre.id] = genre.name
        }
        let genreText = main.first?.genreIDs.map { genreDict[$0] ?? "" }.joined(separator: " ")
        
        return [
            TrendSection(model: genreText ?? "", items: main),
            TrendSection(model: Section.movie.rawValue, items: movies),
            TrendSection(model: Section.tv.rawValue, items: tvShows)
        ]
    }
}
