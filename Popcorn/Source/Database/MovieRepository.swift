//
//  RealmRepository.swift
//  Popcorn
//
//  Created by 김성민 on 10/8/24.
//

import Foundation
import RealmSwift

final class MovieRepository {
    
    private var realm: Realm?
    
    init() {
        do {
            realm = try Realm()
        } catch {
            print("Realm 초기화 실패")
        }
    }
    
    var fileURL: URL? {
        return realm?.configuration.fileURL
    }
    
    var schemaVersion: UInt64? {
        guard let fileURL = fileURL else { return nil }
        return try? schemaVersionAtURL(fileURL)
    }
    
    // MARK: - Create
    func addItem(_ item: RealmMovie) {
        do {
            try realm?.write {
                realm?.add(item)
                print("Realm 추가 성공!")
            }
        } catch {
            print("Realm 추가 실패!")
        }
    }
    
//    // MARK: - Read
    func fetchAll() -> [RealmMovie] {
        var value = realm.objects(LikedPhoto.self)
            .sorted(byKeyPath: "date", ascending: order == .ascending)
        return Array(value)
    }
//    
//    func fetchItem(_ id: String) -> LikedPhoto? {
//        return realm.object(ofType: LikedPhoto.self, forPrimaryKey: id)
//    }
//    
//    // MARK: - Update
//    func updateItem(_ item: LikedPhoto) {
//        //
//    }
//    
//    // MARK: - Delete
//    func deleteItem(_ id: String) {
//        if let item = fetchItem(id) {
//            do {
//                try realm.write {
//                    realm.delete(item)
//                    print("Realm Delete!")
//                }
//            } catch {
//                print("Realm Delete Failed")
//            }
//        }
//    }
//    
//    func deleteAll() {
//        do {
//            try realm.write {
//                let photos = realm.objects(LikedPhoto.self)
//                for item in photos {
//                    ImageFileManager.shared.deleteImageFile(filename: item.id)
//                    ImageFileManager.shared.deleteImageFile(filename: item.id + "user")
//                }
//                realm.delete(photos)
//                print("Realm Delete All!")
//            }
//        } catch {
//            print("Realm Delete All Failed")
//        }
//    }
}
