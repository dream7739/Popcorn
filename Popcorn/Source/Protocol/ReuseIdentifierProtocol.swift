//
//  ReuseIdentifierProtocol.swift
//  Popcorn
//
//  Created by 김성민 on 10/9/24.
//

import UIKit

protocol ReuseIdentifierProtocol: AnyObject {
    static var identifier: String { get }
}

extension UIView: ReuseIdentifierProtocol {
    static var identifier: String {
        return String(describing: self)
    }
}
