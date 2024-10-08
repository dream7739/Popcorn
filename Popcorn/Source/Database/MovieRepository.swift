//
//  MovieRepository.swift
//  Popcorn
//
//  Created by 김성민 on 10/8/24.
//

import UIKit
import RealmSwift

final class MovieRepository {
    
    private let realm: Realm
    
    init() {
        do {
            realm = try Realm()
        } catch {
            fatalError("Realm 초기화 실패: \(error.localizedDescription)")
        }
    }
    
    var fileURL: URL? {
        return realm.configuration.fileURL
    }
    
    var schemaVersion: UInt64? {
        guard let fileURL = fileURL else { return nil }
        return try? schemaVersionAtURL(fileURL)
    }
    
    // MARK: - Read
    func fetchAll() -> [RealmMovie] {
        return realm.objects(RealmMovie.self)
            .sorted(byKeyPath: "savedDate", ascending: false)
            .map { $0 }
    }
    
    // MARK: - Create
    func addItem(item: RealmMovie, image: UIImage?) {
        do {
            try realm.write {
                realm.add(item)
                saveImageForItem(item, image: image)
                print("Realm 추가 성공!")
            }
        } catch {
            print("Realm 추가 실패!")
        }
    }
    
    // MARK: - Update
//    func updateItem(_ item: RealmMovie) {}
    
    // MARK: - Delete
    func deleteItem(_ item: RealmMovie) {
        do {
            try realm.write {
                deleteImageForItem(item)
                realm.delete(item)
                print("Realm 삭제 성공!")
            }
        } catch {
            print("Realm 삭제 실패!")
        }
    }
    
    func deleteAll() {
        do {
            try realm.write {
                let movies = realm.objects(RealmMovie.self)
                movies.forEach { deleteImageForItem($0) }
                realm.delete(movies)
                print("Realm 전체 삭제 성공!")
            }
        } catch {
            print("Realm 전체 삭제 실패!")
        }
    }
    
    private func saveImageForItem(_ item: RealmMovie, image: UIImage?) {
        guard let image = image else { return }
        ImageFileManager.shared.saveImageFile(image: image, filename: "\(item.id)")
    }
    
    private func deleteImageForItem(_ item: RealmMovie) {
        ImageFileManager.shared.deleteImageFile(filename: "\(item.id)")
    }
}
