//
//  DetailViewModel.swift
//  Popcorn
//
//  Created by dopamint on 10/12/24.
//

import UIKit
import RxSwift
import RxCocoa

final class DetailViewModel: BaseViewModel {

    private let repository = MediaRepository()
    var disposeBag = DisposeBag()
    
    let media: Media?
    let realmMedia: RealmMedia?
    
    init(media: Media?) {
        self.media = media
        self.realmMedia = nil
    }
    
    init(realmMedia: RealmMedia?) {
        self.media = nil
        self.realmMedia = realmMedia
    }
    
    struct Input {
        let playButtonTap: PublishSubject<Void>
        let saveButtonTap: PublishSubject<(UIImage?, UIImage?)>
//        let cellTap: ControlEvent<IndexPath>
    }
    
    struct Output {
//        let toDetailTrigger: PublishSubject<Media>
//        let toTrailerTrigger: PublishSubject<Media>
        let popUpViewTrigger: PublishSubject<String>
        let list: PublishSubject<[Media]>
        let castText: PublishSubject<String>
        let creatorText: PublishSubject<String>
    }
    
    func transform(input: Input) -> Output {
        let media = PublishSubject<(Media?, RealmMedia?)>()
        let similars = PublishSubject<[Media]>()
        let toDetailTrigger = PublishSubject<Media>()
        let toTrailerTrigger = PublishSubject<Media>()
        let popUpViewTrigger = PublishSubject<String>()
        let list = PublishSubject<[Media]>()
        let castText = PublishSubject<String>()
        let creatorText = PublishSubject<String>()

        var type = Router.ContentType.movie
        var contentID = 0

        if let media = self.media {
            type = media.isMovie ? .movie : .tv
            contentID = media.id
        } else if let realmMedia = self.realmMedia {
            type = realmMedia.isMovie ? .movie : .tv
            contentID = realmMedia.id
        }

        fetchCredits(type: type, contentID: contentID, castText: castText, creatorText: creatorText)
        if type == .movie {
            fetchSimilarMovies(contentID: contentID, list: list)
        } else {
            fetchSimilarTVs(contentID: contentID, list: list)
        }
        
        // 재생 버튼 탭 -> 웹뷰
        input.playButtonTap.withLatestFrom(media)
            .subscribe(with: self) { owner, media in
                if let media = media.0 {
                    
                }
                if let realmMedia = media.1 {
                    
                }
            }
            .disposed(by: disposeBag)
        
        // TODO: - 저장 버튼 탭 -> 렘 추가 + 팝업 뷰
        input.saveButtonTap
            .withLatestFrom(media) { image, media in
                (image.0, image.1, media)
            }
            .subscribe(with: self) { owner, value in
                let (image, backdrop, media) = value
                // 미디어가 있으면
                if let media = media.0 {
                    // 일단 렘미디어로 바꾸고
                    let realmMedia = media.toRealmMedia()
                    // 미디어가 렘에 잇다면 메세지
                    if owner.repository.contains(media.id) {
                        popUpViewTrigger.onNext("이미 저장된 미디어에요 :)")
                    } else {
                        // 없다면 저장
                        owner.repository.addItem(item: realmMedia, image: image, backdrop: backdrop)
                        popUpViewTrigger.onNext("미디어를 저장했어요 :)")
                    }
                    // 렘미디어가 있다면 (오프라인)
                } else if let realmMedia = media.1 {
                    if owner.repository.contains(realmMedia.id) {
                        popUpViewTrigger.onNext("이미 저장된 미디어에요 :)")
                    } else {
                        // 이거 실행안되긴 함
                        owner.repository.addItem(item: realmMedia, image: image, backdrop: backdrop)
                        popUpViewTrigger.onNext("미디어를 저장했어요 :)")
                    }
                } else {
                    print("메인 포스터 데이터 없음")
                }
            }
            .disposed(by: disposeBag)
        
        return Output(
            popUpViewTrigger: popUpViewTrigger,
            list: list,
            castText: castText,
            creatorText: creatorText
        )
    }
    
    private func fetchCredits(type: Router.ContentType, contentID: Int, castText: PublishSubject<String>, creatorText: PublishSubject<String>) {
        NetworkManager.shared.fetchData(
            with: .credits(type: type, contentId: contentID, language: .korean),
            as: CreditResponse.self
        ).subscribe { result in
            switch result {
            case .success(let value):
                print("Credit 통신 성공")
                let casts = value.cast.prefix(3).map { $0.name }.joined(separator: " ")
                let creators = value.crew.prefix(3).map { $0.name }.joined(separator: " ")
                castText.onNext(casts)
                creatorText.onNext(creators)
                
            case .failure(let error):
                print("Credit 통신 실패", error)
            }
        }
        .disposed(by: disposeBag)
    }

    private func fetchSimilarMovies(contentID: Int, list: PublishSubject<[Media]>) {
        NetworkManager.shared.fetchData(
            with: .similar(type: .movie, contentId: contentID, language: .korean),
            as: MovieResponse.self
        ).subscribe { result in
            switch result {
            case .success(let value):
                print("Similar Movie 통신 성공")
                let mediaList = value.results.map { $0.toMedia() }
                list.onNext(mediaList)
                
            case .failure(let error):
                print("Similar Movie 통신 실패", error)
            }
        }
        .disposed(by: disposeBag)
    }

    private func fetchSimilarTVs(contentID: Int, list: PublishSubject<[Media]>) {
        NetworkManager.shared.fetchData(
            with: .similar(type: .tv, contentId: contentID, language: .korean),
            as: TVResponse.self
        ).subscribe { result in
            switch result {
            case .success(let value):
                print("Similar TV 통신 성공")
                let mediaList = value.results.map { $0.toMedia() }
                list.onNext(mediaList)
                
            case .failure(let error):
                print("Similar TV 통신 실패", error)
            }
        }
        .disposed(by: disposeBag)
    }
    
}
