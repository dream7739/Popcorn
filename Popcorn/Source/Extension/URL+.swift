//
//  URL+.swift
//  Popcorn
//
//  Created by 홍정민 on 10/12/24.
//

import UIKit
import Kingfisher

extension URL {
    func downloadImage(_ completion: @escaping (UIImage?) -> Void) {
        KingfisherManager.shared.retrieveImage(
            with: self,
            options: nil,
            progressBlock: nil
        ) { result in
            switch result {
            case .success(let value):
                completion(value.image)
            case .failure(let error):
                completion(nil)
            }
        }
    }
}
