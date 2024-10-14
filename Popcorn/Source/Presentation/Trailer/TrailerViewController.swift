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
    
    let viewModel: TrailerViewModel
    private let disposeBag = DisposeBag()
    
    init(viewModel: TrailerViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bind()
    }
    
    private func bind() {
        let input = TrailerViewModel.Input()
        let output = viewModel.transform(input: input)
        
        output.errorAlert
            .subscribe(with: self) { owner, _ in
                owner.showErrorAlert(nil)
            }
            .disposed(by: disposeBag)
        
        output.loadURL
            .subscribe(with: self) { owner, request in
                owner.webView.load(request)
            }
            .disposed(by: disposeBag)
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
        navigationItem.title = "예고편".localized
        navigationController?.isNavigationBarHidden = false
    }
    
    private func showErrorAlert(_ error: Error?) {
        let message = error?.localizedDescription ?? "예고편 없음".localized
        let alert = UIAlertController(title: "에러".localized, message: message, preferredStyle: .alert)
        let alertAction = UIAlertAction(title: "확인".localized, style: .default) { [weak self] _ in
            self?.navigationController?.popViewController(animated: true)
        }
        alert.addAction(alertAction)
        present(alert, animated: true)
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
