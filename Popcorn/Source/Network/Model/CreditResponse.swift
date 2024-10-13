//
//  CreditResponse.swift
//  Popcorn
//
//  Created by 김성민 on 10/9/24.
//

import Foundation

// MARK: - Credit 모델 (Movie + TV)
struct CreditResponse: Decodable {
    let id: Int
    let cast: [Cast]
    let crew: [Crew]
}

struct Cast: Decodable {
    let adult: Bool
    let gender: Int
    let id: Int
    let known_for_department: String
    let name: String
    let original_name: String
    let popularity: Double
    let profile_path: String?
    let cast_id: Int?
    let character: String
    let credit_id: String
    let order: Int
}

struct Crew: Decodable {
    let adult: Bool
    let gender: Int
    let id: Int
    let known_for_department: String
    let name: String
    let original_name: String
    let popularity: Double
    let profile_path: String?
    let credit_id: String
    let department: String
    let job: String
}
