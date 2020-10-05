//
//  RealmService.swift
//  VKappNew
//
//  Created by Павел on 05.10.2020.
//

import UIKit
import WebKit
import RealmSwift


class RealmService {
 
    static func getData<T : Object>(for filter : (String, String, String)? = nil, with value : Any? = nil) -> Results<T>?{
        do {
            let realm = try Realm()
            
            var predicate = NSPredicate(value: true)
            if let filter = filter, let value = value {
                switch filter.2 {
                case "Int":
                    predicate = NSPredicate(format: "\(filter.0) \(filter.1) %@", NSNumber(value: value as! Int))
                default:
                    predicate = NSPredicate(format: "\(filter.0) \(filter.1) %@", value as! String)
                }
            }
            let data = realm.objects(T.self).filter(predicate)
            print("\(T.self)s получены из Realm")
            return data
        } catch {
            print(error)
        }
        return nil
    }

    static func getSearchedFriends(for searchText: String) -> Results<User>?{
        if (!searchText.isEmpty){
            return RealmService.getData(for: ("lastName", "CONTAINS[c]", "String"), with: searchText)
        } else {
            return RealmService.getData()?.sorted(byKeyPath: "lastName")
        }
    }

    static func getPhotos(for userId:Int) -> Results<Photo>?{
        return RealmService.getData(for:("ownerID", "==", "Int"), with: userId)
    }

    static func getGroups() -> Results<Group>? {
        return getData(for: ("isMember", "==", "Int"), with: 1)?.sorted(byKeyPath: "name")
    }

    static func saveData<T : Object & HaveID>(_ array: [T], withoutDelete : Bool = false) {
        if (!array.isEmpty) {
            do {
                Realm.Configuration.defaultConfiguration = Realm.Configuration(deleteRealmIfMigrationNeeded: true)
                let realm = try Realm()
           
                realm.beginWrite()
                
                if T.self == Photo.self{
                    let objects = realm.objects(T.self).filter(NSPredicate(format: "ownerID == %@", NSNumber(value: (array[0] as! Photo).ownerID)))
                    if !objects.isEmpty && !withoutDelete{
                        for photo in objects{
                            realm.delete((photo as! Photo).sizes)
                        }
                        realm.delete(objects)
                        for object in objects {
                            print("Удален объект типа \(T.self) с ИД = \(object.id)")
                        }
                    }
                } else if !withoutDelete {
                  
                    let objects = realm.objects(T.self).filter { x in !array.contains(where : { $0.id == x.id }) }
                    if !objects.isEmpty {
                        for object in objects {
                            print("Удален объект типа \(T.self) с ИД = \(object.id)")
                        }
                        realm.delete(objects)
                    }
                }
                
                realm.add(array, update: .modified)
                try realm.commitWrite()
                print("\(T.self)s сохранены в Realm")
            } catch {
                print(error)
            }
        }
    }
    
  
    static func saveObject<T: Object & Codable>(for item: T, method : DataService.Methods) {
        let realm = try! Realm()
        do {
            realm.beginWrite()
            (item as! Group).isMember = method == .joinGroup ? 1 : 0
            realm.add(item)
            try realm.commitWrite()
        } catch let e {
            print(e)
        }
    }
}
