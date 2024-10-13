//
//  DetailViewModel.swift
//  Popcorn
//
//  Created by dopamint on 10/12/24.
//

import UIKit
import RxSwift
import RxCocoa
import RealmSwift

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
    }
    
    struct Output {
//        let toDetailTrigger: PublishSubject<Media>
        let toTrailerTrigger: PublishSubject<Media>
        let title: PublishSubject<String>
        let voteAverage: PublishSubject<String>
        let overView: PublishSubject<String>
        let backdropImage: PublishSubject<UIImage>
        let popUpViewTrigger: PublishSubject<String>
    }
    private let content = PublishSubject<(Media?, RealmMedia?)>()
        
        func loadInitialData() {
            content.onNext((media, realmMedia))
        }
    func transform(input: Input) -> Output {
        
        let similars = PublishSubject<[Media]>()
        let title = PublishSubject<String>()
        let voteAverage = PublishSubject<String>()
        let overView = PublishSubject<String>()
        let backdropImage = PublishSubject<UIImage>()
        
        let toDetailTrigger = PublishSubject<Media>()
        let toTrailerTrigger = PublishSubject<Media>()
        let popUpViewTrigger = PublishSubject<String>()
        
        print("✨✨✨✨✨✨✨")
        
        
        content
            .bind(with: self) { owner, media in
                if let media = media.0 {
                    print("1.✨✨✨✨미디어 잇음✨✨✨")
                    title.onNext(media.title)
                    print(media.title)
                    voteAverage.onNext(media.voteAverage.description)
                    overView.onNext(media.overview)
                    let url = APIURL.imageURL(media.backdropPath)
                    url?.downloadImage { image in
                        guard let image else { return }
                        backdropImage.onNext(image)
                        print("2.✨✨✨✨이미지 다운 완료")
                    }
                } else if let realmMedia = media.1 {
                    print("1.✨✨✨✨✨렘미디어 잇음✨✨")
                    print(realmMedia.title)
                    title.onNext(realmMedia.title)
                    voteAverage.onNext(realmMedia.voteAverage.description)
                    overView.onNext(realmMedia.overview)
                    
                    let image = ImageFileManager.shared.loadImageFile(filename: String(realmMedia.id).backdrop )
                    guard let image else { return }
                    backdropImage.onNext(image)
                    print("2.✨✨✨✨렘 이미지 가져옴")
                }
            }
            .disposed(by: disposeBag)
        
        // 재생 버튼 탭 -> 웹뷰
        input.playButtonTap
            .withLatestFrom(content)
            .subscribe(with: self) { owner, media in
                if let media = media.0 {
                    toTrailerTrigger.onNext(media)
                }
            }
            .disposed(by: disposeBag)
        
        // TODO: - 저장 버튼 탭 -> 렘 추가 + 팝업 뷰
        input.saveButtonTap
            .withLatestFrom(content) { image, media in
                (image.0, image.1, media)
            }
            .subscribe(with: self) { owner, value in
                let (poster, backdrop, media) = value
                // 미디어가 있으면
                if let media = media.0 {
                    // 일단 렘미디어로 바꾸고
                    let realmMedia = media.toRealmMedia()
                    // 미디어가 렘에 잇다면 메세지
                    if owner.repository.contains(media.id) {
                        popUpViewTrigger.onNext("이미 저장된 미디어에요 :)")
                    } else {
                        // 없다면 저장
                        owner.repository.addItem(item: realmMedia, image: poster, backdrop: backdrop)
                        NotificationCenter.default.post(name: .favoriteUpdated, object: self)
                        popUpViewTrigger.onNext("미디어를 저장했어요 :)")
                    }
                    // 렘미디어가 있다면 (오프라인)
                } else if let realmMedia = media.1 {
                    if owner.repository.contains(realmMedia.id) {
                        popUpViewTrigger.onNext("이미 저장된 미디어에요 :)")
                    }
                } else {
                    print("메인 포스터 데이터 없음")
                }
            }
            .disposed(by: disposeBag)
        
        return Output(toTrailerTrigger: toTrailerTrigger,
                      title: title,
                      voteAverage: voteAverage,
                      overView: overView,
                      backdropImage: backdropImage,
                      popUpViewTrigger: popUpViewTrigger)
    }
}
