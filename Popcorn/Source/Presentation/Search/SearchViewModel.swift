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
        let searchMovieList: BehaviorRelay<[Movie]>
        let showTableView: BehaviorRelay<Void>
    }
    
    var trendMovieResponse: MovieResponse?
    var trendMovieList: [Movie] = []
    var searchMovieResponse: MovieResponse?
    var searchMovieList: [Movie] = []
    var searchPage = 1
    let callSearchMovieMore = PublishRelay<Void>()
    var disposeBag = DisposeBag()
    
    func transform(input: Input) -> Output {
        let trendMovieList = BehaviorRelay<[Movie]>(value: [])
        let searchMovieList = BehaviorRelay<[Movie]>(value: [])
        let showTableView = BehaviorRelay<Void>(value: ())
        
        NetworkManager.shared.fetchMovie(with: Router.trending(type: .movie))
            .subscribe(with: self) { owner, result in
                switch result {
                case .success(let value):
                    owner.trendMovieResponse = value
                    let data = value.results.map { $0.toMovie() }
                    owner.trendMovieList = data
                    trendMovieList.accept(data)
                case .failure(let error):
                    print(error)
                }
            }
            .disposed(by: disposeBag)
        
        input.searchText
            .map { $0.trimmingCharacters(in: .whitespaces) }
            .filter { $0.isEmpty }
            .bind(with: self) { owner, value in
                showTableView.accept(())
            }
            .disposed(by: disposeBag)
        
        input.searchText
            .map { $0.trimmingCharacters(in: .whitespaces) }
            .filter { !$0.isEmpty }
            .distinctUntilChanged()
            .debounce(.seconds(1), scheduler: MainScheduler.instance)
            .withUnretained(self)
            .map {
                self.searchPage = 1
                return $1
            }
            .flatMap { value in
                NetworkManager.shared.fetchMovie(
                    with: Router.search(type: .movie, query: value, page: self.searchPage)
                )
            }
            .bind(with: self) { owner, result in
                switch result {
                case .success(let value):
                    owner.searchMovieResponse = value
                    let data = value.results.map { $0.toMovie() }
                    owner.searchMovieList = data
                    searchMovieList.accept(data)
                case .failure(let error):
                    print(error)
                }
            }
            .disposed(by: disposeBag)
        
        callSearchMovieMore
            .withLatestFrom(input.searchText)
            .withUnretained(self)
            .flatMap { owner, value in
                NetworkManager.shared.fetchMovie(
                    with: Router.search(type: .movie, query: value, page: owner.searchPage)
                )
            }
            .bind(with: self) { owner, result in
                switch result {
                case .success(let value):
                    let data = value.results.map { $0.toMovie() }
                    owner.searchMovieList.append(contentsOf: data)
                    searchMovieList.accept(data)
                case .failure(let error):
                    print(error)
                }
            }
            .disposed(by: disposeBag)
        
        return Output(
            trendMovieList: trendMovieList,
            searchMovieList: searchMovieList,
            showTableView: showTableView
        )
    }
}
