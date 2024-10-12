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
        let saveButtonTap: PublishSubject<UIImage?>
//        let cellTap: ControlEvent<IndexPath>
    }
    
    struct Output {
//        let toDetailTrigger: PublishSubject<Media>
//        let toTrailerTrigger: PublishSubject<Media>
        let popUpViewTrigger: PublishSubject<String>
    }
    
    func transform(input: Input) -> Output {
        let media = PublishSubject<(Media?, RealmMedia?)>()
        let similars = PublishSubject<[Media]>()
        let toDetailTrigger = PublishSubject<Media>()
        let toTrailerTrigger = PublishSubject<Media>()
        let popUpViewTrigger = PublishSubject<String>()
        // 랜덤 아이템 뽑혔을 때 장르 API 통신
//        mainPoster
//            .compactMap { $0.first }
//            .flatMap { media in
//                NetworkManager.shared.fetchData(
//                    with: .genre(type: media.isMovie ? .movie : .tv, language: .korean),
//                    as: GenreResponse.self
//                )
//            }
//            .subscribe(with: self) { owner, result in
//                switch result {
//                case .success(let response):
//                    print("장르 통신 성공")
//                    genres.onNext(response.genres)
//                case .failure(let error):
//                    print("장르 통신 실패", error)
//                }
//            }
//            .disposed(by: disposeBag)

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
                (image, media)
            }
            .subscribe(with: self) { owner, value in
                let (image, media) = value
                // 미디어가 있으면
                if let media = media.0 {
                    // 일단 렘미디어로 바꾸고
                    let realmMedia = media.toRealmMedia()
                    // 미디어가 렘에 잇다면 메세지
                    if owner.repository.contains(media.id) {
                        popUpViewTrigger.onNext("이미 저장된 미디어에요 :)")
                    } else {
                        // 없다면 저장
                        owner.repository.addItem(item: realmMedia, image: image)
                        popUpViewTrigger.onNext("미디어를 저장했어요 :)")
                    }
                    // 렘미디어가 있다면 (오프라인)
                } else if let realmMedia = media.1 {
                    if owner.repository.contains(realmMedia.id) {
                        popUpViewTrigger.onNext("이미 저장된 미디어에요 :)")
                    } else {
                        // 이거 실행안되긴 함
                        owner.repository.addItem(item: realmMedia, image: image)
                        popUpViewTrigger.onNext("미디어를 저장했어요 :)")
                    }
                } else {
                    print("메인 포스터 데이터 없음")
                }
            }
            .disposed(by: disposeBag)
        
        return Output(popUpViewTrigger: popUpViewTrigger)
    }
}
