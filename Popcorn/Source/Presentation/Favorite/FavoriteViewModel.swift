//
//  FavoriteViewModel.swift
//  Popcorn
//
//  Created by dopamint on 10/10/24.
//

import Foundation
import RxSwift
import RxCocoa
import RealmSwift

final class FavoriteViewModel {
    private let disposeBag = DisposeBag()
    let repository: MovieRepository
    private var favoriteList = BehaviorRelay<[RealmMovie]>(value: [])
    
    init(repository: MovieRepository = MovieRepository()) {
        self.repository = repository
        setupNotificationObserver()
    }
    
    private func setupNotificationObserver() {
        NotificationCenter.default.rx.notification(.favoriteUpdated)
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] _ in
                self?.updateFavoriteList()
            })
            .disposed(by: disposeBag)
    }
    
    private func updateFavoriteList() {
        let updatedList = repository.fetchAll()
        favoriteList.accept(updatedList)
    }
    
    struct Input {
        let viewWillAppear: Observable<Void>
        let itemDeleted: ControlEvent<RealmMovie>
    }
    
    struct Output {
        let favoriteList: Observable<[RealmMovie]>
    }
    
    func transform(input: Input) -> Output {
            var list: Observable<[RealmMovie]>
            
            list = input.viewWillAppear
                .flatMapLatest { [weak self] _ -> Driver<[RealmMovie]> in
                    guard let self else { return Driver.just([]) }
                    self.updateFavoriteList()
                    return self.favoriteList.asDriver()
                }

            input.itemDeleted
                .observe(on: MainScheduler.instance)
                .bind(with: self) { owner, item in
                    owner.repository.deleteItem(withId: item.id)
                    owner.updateFavoriteList()
                }
                .disposed(by: disposeBag)
            
            return Output(
                favoriteList: list
            )
        }
}

extension Notification.Name {
    static let favoriteUpdated = Notification.Name("favoriteUpdated")
}
