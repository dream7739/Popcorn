//
//  BaseViewModel.swift
//  Popcorn
//
//  Created by 홍정민 on 10/10/24.
//

import Foundation
import RxSwift

protocol BaseViewModel: AnyObject {
    associatedtype Input
    associatedtype Output
    
    func transform(input: Input) -> Output
    var disposeBag: DisposeBag { get set }
}
