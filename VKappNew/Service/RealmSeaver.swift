//
//  RealmService.swift
//  VKappNew
//
//  Created by Павел on 05.10.2020.
//

import Foundation
import RealmSwift

class RealmSaver : Operation {
    
    var inputData: [Object & Decodable & HaveID]?
    var withoutDelete: Bool = false
    
    init(inputData: [Object & Decodable & HaveID]?, withoutDelete: Bool = false) {
        self.inputData = inputData
        self.withoutDelete = withoutDelete
    }
    
    override func main() {
        guard let getDataOperation = dependencies.first as? ParseData,
            let data = getDataOperation.outputData else { return }
        DispatchQueue.main.async {
            if (!data.isEmpty) {
                do {
                    Realm.Configuration.defaultConfiguration = Realm.Configuration(deleteRealmIfMigrationNeeded: true)
                    let realm = try Realm()
                   
                    realm.beginWrite()
                    
                    if data is [Photo] {
                        let objects = realm.objects(Photo.self).filter(NSPredicate(format: "ownerID == %@", NSNumber(value: (data[0] as! Photo).ownerID)))
                        if !objects.isEmpty && !self.withoutDelete{
                            for photo in objects {
                                realm.delete(photo.sizes)
                            }
                            realm.delete(objects)
                            for object in objects {
                                print("Удален объект типа \(Photo.self) с ИД = \(object.id)")
                            }
                        }
                       
                    } else if data is [User]{
                        self.deleteObjects(realm: realm, data: data as! [User])
                    } else if data is [Group]{
                        self.deleteObjects(realm: realm, data: data as! [Group])
                    }
                    realm.add(data, update: .modified)
                    try realm.commitWrite()
                    print("\(type(of: data[0]))s сохранены в Realm")
                } catch {
                    print(error)
                }
            }
        }
    }
    
    private func deleteObjects<T: Object & HaveID>(realm : Realm, data : [T]){
        let objects = realm.objects(T.self).filter { x in !data.contains(where : { $0.id == x.id }) }
        if !objects.isEmpty {
            for object in objects {
                print("Удален объект типа \(T.self) с ИД = \(object.id)")
            }
            realm.delete(objects)
        }
    }
}
