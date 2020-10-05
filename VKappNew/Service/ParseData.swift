//
//  ParseData.swift
//  VKappNew
//
//  Created by Павел on 05.10.2020.
//

import Foundation
import RealmSwift

class ParseData: Operation {
    
    init(method: DataService.Methods) {
        self.method = method
    }
    
    
    var method : DataService.Methods
    var outputData: [Object & Decodable & HaveID]?
    
    override func main() {
        guard let getDataOperation = dependencies.first as? GetDataOperation,
            let data = getDataOperation.data else { return }
        
        do {
            let res : Any?
            switch method {
            case .getFriends :
                res = try JSONDecoder().decode(Response<User>.self, from: data)
                outputData = (res! as! Response<User>).response.items
            case .getUserGroups, .getSearchGroups, .getGroupById :
                res = try JSONDecoder().decode(Response<Group>.self, from: data)
                outputData = (res! as! Response<Group>).response.items
            case .getAllPhotos :
                res = try JSONDecoder().decode(Response<Photo>.self, from: data)
                outputData = (res! as! Response<Photo>).response.items
            default :
                return
            }
            
        } catch let DecodingError.dataCorrupted(context) {
            print(context)
        } catch let DecodingError.keyNotFound(key, context) {
            print("Key '\(key)' not found:", context.debugDescription)
            print("codingPath:",  context.codingPath)
        } catch let DecodingError.valueNotFound(value, context) {
            print("Value '\(value)' not found:", context.debugDescription)
            print("codingPath:", context.codingPath)
        } catch let DecodingError.typeMismatch(type, context)  {
            print("Type '\(type)' mismatch:", context.debugDescription)
            print("codingPath:", context.codingPath)
        } catch {
            print("error: ", error)
        }
    }
}
