//
//  TrailerViewController.swift
//  Popcorn
//
//  Created by 김성민 on 10/11/24.
//

import UIKit
import WebKit
import SnapKit
import Then
import RxSwift

final class TrailerViewController: BaseViewController {
    
    private lazy var webView = WKWebView().then {
        $0.navigationDelegate = self
    }
    
    private lazy var indicator = UIActivityIndicatorView(style: .large).then {
        $0.hidesWhenStopped = true
    }
    
    // MARK: - 둘 중에 한 값만 사용
    // 트렌드나 서치에서 들어올 경우 movie 값 사용
    // 내가 찜한 리스트에서 들어올 경우 realmMovie 값 사용
    let movie: Movie?
    let realmMovie: RealmMovie?
    
    private let disposeBag = DisposeBag()
    
    init(movie: Movie?, realmMovie: RealmMovie?) {
        self.movie = movie
        self.realmMovie = realmMovie
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let movie {
            if movie.isMovie {
                fetchVideo(type: .movie, contentId: movie.id)
            } else {
                fetchVideo(type: .tv, contentId: movie.id)
            }
        } else if let realmMovie {
            if realmMovie.isMovie {
                fetchVideo(type: .movie, contentId: realmMovie.id)
            } else {
                fetchVideo(type: .tv, contentId: realmMovie.id)
            }
        } else {
            showErrorAlert(nil)
            return
        }
    }
    
    override func configureHierarchy() {
        view.addSubview(webView)
        view.addSubview(indicator)
    }
    
    override func configureLayout() {
        webView.snp.makeConstraints { make in
            make.edges.equalTo(view.safeAreaLayoutGuide)
        }
        indicator.snp.makeConstraints { make in
            make.center.equalTo(view.safeAreaLayoutGuide)
        }
    }
    
    override func configureUI() {
        navigationItem.title = "예고편"
    }
    
    private func showErrorAlert(_ error: Error?) {
        let message = error?.localizedDescription ?? "URL 변경 실패"
        let alert = UIAlertController(title: "에러", message: message, preferredStyle: .alert)
        let alertAction = UIAlertAction(title: "확인", style: .default) { [weak self] _ in
            self?.navigationController?.popViewController(animated: true)
        }
        alert.addAction(alertAction)
        present(alert, animated: true)
    }
    
    private func fetchVideo(type: Router.ContentType, contentId: Int) {
        NetworkManager.shared.fetchData(
            with: .video(type: type, contentId: contentId, language: .korean),
            as: VideoResponse.self
        )
        .subscribe(with: self) { owner, result in
            switch result {
            case .success(let value):
                guard let key = value.results.first?.key,
                      let url = URL(string: APIURL.videoURL(key)) else {
                    owner.showErrorAlert(nil)
                    return
                }
                let request = URLRequest(url: url)
                owner.webView.load(request)
                
            case .failure(let error):
                print("영화 비디오 통신 실패", error)
                owner.showErrorAlert(nil)
            }
        }
        .disposed(by: disposeBag)
    }
}

extension TrailerViewController: WKNavigationDelegate {
    func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {
        indicator.startAnimating()
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        indicator.stopAnimating()
    }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: any Error) {
        indicator.stopAnimating()
        showErrorAlert(error)
    }
    
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: any Error) {
        indicator.stopAnimating()
        showErrorAlert(error)
    }
}