//
//  User.swift
//  VKappNew
//
//  Created by Павел on 01.10.2020.
//

import UIKit
import RealmSwift

class User: Object, Decodable, HaveID, HavePhoto {
    @objc dynamic var firstName: String = ""
    @objc dynamic var id: Int = 0
    @objc dynamic var lastName:  String = ""
    @objc dynamic var nickname: String = ""
    @objc dynamic var online: Int = 0
    @objc dynamic var photo100 = "photo_100"
    @objc dynamic var sex: Int = 0
    
    required convenience init(from decoder: Decoder) throws {
        self.init()
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.id = try container.decode(Int.self, forKey: .id)
        self.online = try container.decode(Int.self, forKey: .online)
        self.firstName = try container.decode(String.self, forKey: .firstName)
        self.lastName = try container.decode(String.self, forKey: .lastName)
        self.photo100 = try container.decode(String.self, forKey: .photo100)
        self.sex = try container.decode(Int.self, forKey: .sex)
        self.nickname = (try? container.decodeIfPresent(String.self, forKey: .nickname)) ?? ""
    }
    
    enum CodingKeys: String, CodingKey {
        case firstName = "first_name"
        case id
        case lastName = "last_name"
        case photo100 = "photo_100"
        case nickname, online
        case sex
    }
    
    func getFullName() -> String {
        "\(self.firstName) \(self.lastName)"
    }
    
    override static func primaryKey() -> String? {
        return "id"
    }
    
}

class Items<T:Decodable>  : Decodable {
    var items : [T] = []
}


class Response<T:Decodable> : Decodable {
    var response : Items<T>
}

protocol HaveID {
    var id: Int { get set }
}

protocol HavePhoto {
    var photo100: String { get set }
}

class ResponseUsers: Decodable {
    var response : [User] = []

}
