//
//  MediaRepository.swift
//  Popcorn
//
//  Created by 김성민 on 10/8/24.
//

import UIKit
import RealmSwift

final class MediaRepository {
    
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
    
    func contains(_ id: Int) -> Bool {
        return realm.object(ofType: RealmMedia.self, forPrimaryKey: id) != nil
    }
    
    // MARK: - Read
    func fetchAll() -> [RealmMedia] {
        return realm.objects(RealmMedia.self)
            .sorted(byKeyPath: "savedDate", ascending: false)
            .map { $0 }
    }
    
    // MARK: - Create
    func addItem(item: RealmMedia, image: UIImage?) {
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
//    func updateItem(_ item: RealmMedia) {}
    
    // MARK: - Delete
    func deleteItem(withId id: Int) {
        do {
            try realm.write {
                if let itemToDelete = realm.object(ofType: RealmMedia.self, forPrimaryKey: id) {
                    deleteImageForItem(itemToDelete)
                    realm.delete(itemToDelete)
                    print("Realm 삭제 성공!")
                } else {
                    print("삭제할 항목을 찾을 수 없습니다.")
                }
            }
        } catch {
            print("Realm 삭제 실패: \(error.localizedDescription)")
        }
    }
    func deleteAll() {
        do {
            try realm.write {
                let mediaList = realm.objects(RealmMedia.self)
                mediaList.forEach { deleteImageForItem($0) }
                realm.delete(mediaList)
                print("Realm 전체 삭제 성공!")
            }
        } catch {
            print("Realm 전체 삭제 실패!")
        }
    }
    
    private func saveImageForItem(_ item: RealmMedia, image: UIImage?) {
        guard let image = image else { return }
        ImageFileManager.shared.saveImageFile(image: image, filename: "\(item.id)")
    }
    
    private func deleteImageForItem(_ item: RealmMedia) {
        ImageFileManager.shared.deleteImageFile(filename: "\(item.id)")
    }
}
