//
//  Design.swift
//  Popcorn
//
//  Created by 홍정민 on 10/8/24.
//

import UIKit

enum Design {
    // 시스템 이미지 아이콘
    enum Image {
        static let play = UIImage(systemName: "play")
        static let search = UIImage(systemName: "magnifyingglass")
        static let tv = UIImage(systemName: "sparkles.tv")
        static let home = UIImage(systemName: "house")
        static let playCircle = UIImage(systemName: "play.circle")
        static let download = UIImage(systemName: "square.and.arrow.down")
        static let faceSmile = UIImage(systemName: "face.smiling.inverse")
        static let plus = UIImage(systemName: "plus")
    }
    
    // 폰트
    enum Font {
        static let title = UIFont.boldSystemFont(ofSize: 18)
        static let subtitle = UIFont.boldSystemFont(ofSize: 16)
        static let primary = UIFont.systemFont(ofSize: 14)
        static let secondary = UIFont.systemFont(ofSize: 12)
    }
}
