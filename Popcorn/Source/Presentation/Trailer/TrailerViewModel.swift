//
//  TrailerViewModel.swift
//  Popcorn
//
//  Created by 김성민 on 10/12/24.
//

import Foundation
import RxSwift

final class TrailerViewModel: BaseViewModel {
    
    // MARK: - 둘 중에 한 값만 사용
    // 트렌드나 서치에서 들어올 경우 media 값 사용
    // 내가 찜한 리스트에서 들어올 경우 realmMedia 값 사용
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
    
    var disposeBag = DisposeBag()
    
    struct Input {}
    
    struct Output {
        let errorAlert: PublishSubject<Void>
        let loadURL: PublishSubject<URLRequest>
    }
    
    func transform(input: Input) -> Output {
        let errorAlert = PublishSubject<Void>()
        let loadURL = PublishSubject<URLRequest>()
        
        if let media {
            if media.isMovie {
                fetchVideo(type: .movie, contentId: media.id, errorAlert: errorAlert, loadURL: loadURL)
            } else {
                fetchVideo(type: .tv, contentId: media.id, errorAlert: errorAlert, loadURL: loadURL)
            }
        } else if let realmMedia {
            if realmMedia.isMovie {
                fetchVideo(type: .movie, contentId: realmMedia.id, errorAlert: errorAlert, loadURL: loadURL)
            } else {
                fetchVideo(type: .tv, contentId: realmMedia.id, errorAlert: errorAlert, loadURL: loadURL)
            }
        } else {
            errorAlert.onNext(())
        }
        
        return Output(
            errorAlert: errorAlert,
            loadURL: loadURL
        )
    }
    
    // TODO: - 한국어로 하면 예고편 없는 경우 많음..
    private func fetchVideo(type: Router.ContentType, contentId: Int, errorAlert: PublishSubject<Void>, loadURL: PublishSubject<URLRequest>) {
        NetworkManager.shared.fetchData(
            with: .video(type: type, contentId: contentId),
            as: VideoResponse.self
        )
        .subscribe(with: self) { owner, result in
            switch result {
            case .success(let value):
                guard let key = value.results.first?.key,
                      let url = URL(string: APIURL.videoURL(key)) else {
                    errorAlert.onNext(())
                    return
                }
                let request = URLRequest(url: url)
                loadURL.onNext(request)
                
            case .failure(let error):
                print("영화 비디오 통신 실패", error)
                errorAlert.onNext(())
            }
        }
        .disposed(by: disposeBag)
    }
}
