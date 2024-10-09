//
//  UIButton+.swift
//  Popcorn
//
//  Created by 홍정민 on 10/9/24.
//

import UIKit

extension UIButton {
    func whiteBlackRadius(_ title: String, _ image: UIImage?) {
        var configuration = UIButton.Configuration.basicButton
        configuration.background.backgroundColor = .white
        configuration.baseForegroundColor = .black
        let container = AttributeContainer([.font: Design.Font.primary])
        configuration.attributedTitle = AttributedString(title, attributes: container)
        configuration.image = image?.applyingSymbolConfiguration(.init(pointSize: 12))
        self.configuration = configuration
    }
    
    func blackWhiteRadius(_ title: String, _ image: UIImage?) {
        var configuration = UIButton.Configuration.basicButton
        configuration.background.backgroundColor = .lightBlack
        configuration.baseForegroundColor = .white
        let container = AttributeContainer([.font: Design.Font.primary])
        configuration.attributedTitle = AttributedString(title, attributes: container)
        configuration.image = image?.applyingSymbolConfiguration(.init(pointSize: 12))
        self.configuration = configuration
    }
    
}

extension UIButton.Configuration {
    static let basicButton = {
        var configuration = UIButton.Configuration.plain()
        configuration.cornerStyle = .medium
        configuration.imagePadding = 10
        return configuration
    }()
}
