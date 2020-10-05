//
//  Group.swift
//  VKappNew
//
//  Created by Павел on 01.10.2020.
//

import UIKit
import RealmSwift

class Group: Object, Codable, HaveID, HavePhoto {
    @objc dynamic var id: Int = 0
    @objc dynamic var name = ""
    @objc dynamic var screenName: String = ""
    @objc dynamic var isClosed: Int = 0
    @objc dynamic var type: String = ""
    @objc dynamic var isMember: Int = 0
    @objc dynamic var photo100: String = ""
    
    enum CodingKeys: String, CodingKey {
        case id, name
        case screenName = "screen_name"
        case isClosed = "is_closed"
        case type
        case isMember = "is_member"
        case photo100 = "photo_100"
    }
    required convenience init(from decoder: Decoder) throws {
        self.init()
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        id = try container.decode(Int.self, forKey: .id)
        isClosed = try container.decode(Int.self, forKey: .isClosed)
        type = try container.decode(String.self, forKey: .type)
        name = try container.decode(String.self, forKey: .name)
        screenName = try container.decode(String.self, forKey: .screenName)
        photo100 = try container.decode(String.self, forKey: .photo100)
        isMember = (try? container.decodeIfPresent(Int.self, forKey: .isMember)) ?? 0
    }
    override static func primaryKey() -> String? {
        return "id"
    }
}




