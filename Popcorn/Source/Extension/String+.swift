//
//  String+.swift
//  Popcorn
//
//  Created by 홍정민 on 10/12/24.
//

import Foundation

extension String {
    var backdrop: String {
        return self + "_backdrop"
    }
    var localized: String {
        return NSLocalizedString(self, comment: "")
    }
}
