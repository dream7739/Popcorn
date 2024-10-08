//
//  ImageFileManager.swift
//  Popcorn
//
//  Created by 김성민 on 10/8/24.
//

import UIKit

final class ImageFileManager {
    static let shared = ImageFileManager()
    private init() {}
    
    // 도큐먼트 폴더 위치
    private let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
    
    func saveImageFile(image: UIImage, filename: String) {
        guard let documentDirectory else { return }
        let fileURL = documentDirectory.appendingPathComponent("\(filename).jpg")
        guard let data = image.jpegData(compressionQuality: 0.5) else { return }
        
        do {
            print("이미지 파일 저장 성공")
            try data.write(to: fileURL)
        } catch {
            print("이미지 파일 저장 실패", error)
        }
    }
    
    func loadImageFile(filename: String) -> UIImage? {
        guard let documentDirectory else { return nil }
        let fileURL = documentDirectory.appendingPathComponent("\(filename).jpg")
        if FileManager.default.fileExists(atPath: fileURL.path) {
            print("이미지 파일 로드 성공")
            return UIImage(contentsOfFile: fileURL.path)
        } else {
            print("이미지 파일 로드 실패")
            return nil
        }
    }

    func deleteImageFile(filename: String) {
        guard let documentDirectory else { return }
        let fileURL = documentDirectory.appendingPathComponent("\(filename).jpg")
        if FileManager.default.fileExists(atPath: fileURL.path) {
            do {
                print("이미지 파일 삭제 성공")
                try FileManager.default.removeItem(atPath: fileURL.path)
            } catch {
                print("이미지 파일 삭제 실패", error)
            }
        } else {
            print("이미지 파일 없음")
        }
    }
}
