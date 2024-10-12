//
//  PopupViewController.swift
//  Popcorn
//
//  Created by dopamint on 10/12/24.
//

import UIKit
import SnapKit
import Then
import RxSwift

class PopupViewController: BaseViewController {
    
    private let disposeBag = DisposeBag()
    private var confirmAction: (() -> Observable<Void>)?
    let dismissTrigger = PublishSubject<Void>()
    
    private let backgroundView = UIView()
    private let containerView = UIView().then {
        $0.backgroundColor = .black.withAlphaComponent(0.7)
        $0.layer.cornerRadius = 12
        $0.clipsToBounds = false
        $0.layer.shadowColor = UIColor.black.cgColor
        $0.layer.shadowOffset = CGSize(width: 0, height: 4)
        $0.layer.shadowRadius = 10
        $0.layer.shadowOpacity = 0.3
    }
    
    private let contentView = UIView()
    private var titleLabel: UILabel?
    private var messageLabel: UILabel?
    private var buttons: [UIButton] = []
    
    private init() {
        super.init(nibName: nil, bundle: nil)
        modalPresentationStyle = .overFullScreen
        modalTransitionStyle = .crossDissolve
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureHierarchy()
        configureLayout()
        setupBackgroundDismiss()
    }
    private func setupBackgroundDismiss() {
        let tapGesture = UITapGestureRecognizer()
        backgroundView.addGestureRecognizer(tapGesture)
        
        tapGesture.rx.event
            .map { _ in () }
            .bind(to: dismissTrigger)
            .disposed(by: disposeBag)
        
        dismissTrigger
            .subscribe(onNext: { [weak self] in
                self?.dismiss(animated: true, completion: nil)
            })
            .disposed(by: disposeBag)
    }
    
    override func configureHierarchy() {
        view.backgroundColor = .clear
        view.addSubview(backgroundView)
        view.addSubview(containerView)
        containerView.addSubview(contentView)
        [titleLabel, messageLabel].compactMap { $0 }.forEach { contentView.addSubview($0) }
        buttons.forEach { contentView.addSubview($0) }
    }
    
    override func configureLayout() {
        backgroundView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        containerView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.equalTo(view.snp.width).multipliedBy(0.8)
            make.height.lessThanOrEqualTo(view.snp.height).multipliedBy(0.7)
        }
        
        contentView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        var lastView: UIView?
        
        [titleLabel, messageLabel].compactMap { $0 }.forEach { view in
            view.snp.makeConstraints { make in
                if let lastView = lastView {
                    make.top.equalTo(lastView.snp.bottom).offset(15)
                } else {
                    make.top.equalToSuperview().offset(20)
                }
                make.leading.trailing.equalToSuperview().inset(20)
            }
            lastView = view
        }
        
        for (index, button) in buttons.enumerated() {
            button.snp.makeConstraints { make in
                if index == 0 {
                    make.top.equalTo((lastView ?? contentView).snp.bottom).offset(20)
                } else {
                    make.top.equalTo(buttons[index-1].snp.top)
                    make.width.equalTo(buttons[index-1])
                }
                
                if buttons.count == 1 {
                    make.leading.trailing.equalToSuperview().inset(20)
                } else if index == 0 {
                    make.leading.equalToSuperview().offset(20)
                    make.trailing.equalTo(view.snp.centerX).offset(-4)
                } else {
                    make.leading.equalTo(view.snp.centerX).offset(4)
                    make.trailing.equalToSuperview().offset(-20)
                }
                
                make.height.equalTo(30)
                if index == buttons.count - 1 {
                    make.bottom.equalToSuperview().offset(-20)
                }
            }
        }
    }
    
    func addTitle(_ title: String) -> Self {
        titleLabel = UILabel().then {
            $0.backgroundColor = .clear
            $0.text = title
            $0.textColor = .white
            $0.textAlignment = .center
            $0.font = .systemFont(ofSize: 15)
        }
        return self
    }
    
    func addMessage(_ message: String) -> Self {
        messageLabel = UILabel().then {
            $0.backgroundColor = .clear
            $0.text = message
            $0.textColor = .white
            $0.textAlignment = .center
            $0.font = .systemFont(ofSize: 14, weight: .semibold)
            $0.numberOfLines = 0
        }
        return self
    }
    
    func addButton(title: String, handler: (() -> Void)? = nil) -> Self {
        let button = UIButton(type: .system).then {
            $0.setTitle(title, for: .normal)
            $0.tintColor = .white
            $0.backgroundColor = .pointRed
            $0.layer.cornerRadius = 8
            $0.titleLabel?.font = .systemFont(ofSize: 20)
        }
        
        button.rx.tap
            .bind { [weak self] in
                handler?()
                self?.dismissTrigger.onNext(())
            }
            .disposed(by: disposeBag)
        
        buttons.append(button)
        return self
    }
    
    static func create() -> PopupViewController {
        return PopupViewController()
    }
}
