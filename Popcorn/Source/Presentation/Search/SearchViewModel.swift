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
        let searchMovieList: BehaviorRelay<[Media]>
        let showTableView: BehaviorRelay<Void>
    }
    
    var trendMovieResponse: MovieResponse?
    var trendMovieList: [Media] = []
    var searchMovieResponse: MovieResponse?
    var searchMovieList: [Media] = []
    var searchPage = 1
    let callSearchMovieMore = PublishRelay<Void>()
    var disposeBag = DisposeBag()
    
    func transform(input: Input) -> Output {
        let trendMovieList = BehaviorRelay<[Media]>(value: [])
        let searchMovieList = BehaviorRelay<[Media]>(value: [])
        let showTableView = BehaviorRelay<Void>(value: ())
        
        NetworkManager.shared.fetchData(with: Router.trending(type: .movie), as: MovieResponse.self)
            .subscribe(with: self) { owner, result in
                switch result {
                case .success(let value):
                    owner.trendMovieResponse = value
                    let data = value.results.map { $0.toMedia() }
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
                NetworkManager.shared.fetchData(
                    with: Router.search(type: .movie, query: value, page: self.searchPage),
                    as: MovieResponse.self
                )
            }
            .bind(with: self) { owner, result in
                switch result {
                case .success(let value):
                    owner.searchMovieResponse = value
                    let data = value.results.map { $0.toMedia() }
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
                NetworkManager.shared.fetchData(
                    with: Router.search(type: .movie, query: value, page: owner.searchPage),
                    as: MovieResponse.self
                )
            }
            .bind(with: self) { owner, result in
                switch result {
                case .success(let value):
                    let data = value.results.map { $0.toMedia() }
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
