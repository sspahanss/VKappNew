//
//  DataService.swift
//  VKappNew
//
//  Created by Павел on 05.10.2020.
//

import UIKit
import WebKit
import Alamofire
import RealmSwift

/// Сервис для работы с сервером VK
class DataService {
    
    /// Метод для получения всех друзей пользователя
    /// - Parameter completion: замыкание для возврата данных
    static func getAllFriends(
        completion: @escaping (_ array : Results<User>?) -> Void){
        let params: Parameters = [
            "fields": "nickname, domain, sex, photo_100"
        ]
        DataService.getServerData(
            method: .getFriends,
            with: params,
            completion: completion
        )
    }
    
    /// Метод для обновления информации о друзьях
    static func updateAllFriends(){
        let params: Parameters = [
            "fields": "nickname, domain, sex, photo_100"
        ]
        DataService.getServerData(
            method: .getFriends,
            with: params,
            dataType : User.self
        )
    }
    
    /// Метод для обновления информации о друзьях c Operation
    static func updateAllFriendsWithOperation(){
        let params: Parameters = [
            "fields": "nickname, domain, sex, photo_100"
        ]
        DataService.getData(
            method: .getFriends,
            with: params,
            dataType : User.self
        )
    }
    
    /// Метод для получения всех групп пользователя
    /// - Parameter completion: замыкание для возврата данных
    static func getAllGroups(
        completion: @escaping (_ array : Results<Group>?) -> Void){
        let params: Parameters = [
            "extended": "1",
            "isMember" : 1
        ]
        DataService.getServerData(
            method: .getUserGroups,
            with: params,
            completion: completion
        )
    }
    
    /// Метод для обновления всех групп пользователя
    static func updateAllGroups(){
        let params: Parameters = [
            "extended": "1",
            "isMember" : 1
        ]
        DataService.getServerData(
            method: .getUserGroups,
            with: params,
            dataType: Group.self
        )
    }
    
    /// Метод для обновления всех групп пользователя c Operation
    static func updateAllGroupsWithOperation(){
        let params: Parameters = [
            "extended": "1",
            "isMember" : 1
        ]
        DataService.getData(
            method: .getUserGroups,
            with: params,
            dataType: Group.self
        )
    }
    
    /// Метод для получения всех фотографий конкретного пользователя
    /// - Parameters:
    ///   - userId: id пользователя
    ///   - completion: замыкание для возврата данных
    static func getAllPhotosForUser(userId : Int,
                                    completion: @escaping (_ array : Results<Photo>?) -> Void) {
        let params: Parameters = [
            "extended": "1",
            "owner_id" : userId
        ]
        AF.request("https://api.vk.com/method/" + Methods.getAllPhotos.rawValue,
                   parameters: getFullParameters(params)).responseJSON{ response in
                    print("Photos получены с сервера ВК")
                    guard let data = response.data else { return }
                    let array: [Photo]? = decodeRequestData(method: Methods.getAllPhotos, data: data)
                    if let array = array {
                        RealmService.saveData(array)
                        completion(RealmService.getData(for:("ownerID", "==", "Int"), with: userId))
                    }
        }
    }
    
    /// Метод для получения групп по поисковому запросу
    /// - Parameters:
    ///   - searchText: искомый текст
    ///   - completion: замыкание для возврата данных
    static func getSearchedGroups(searchText : String,
                                  completion: @escaping (_ array : Results<Group>?) -> Void) {
        let params: Parameters = [
            "q": searchText,
            "count" : 100
        ]
        AF.request("https://api.vk.com/method/" + Methods.getSearchGroups.rawValue,
                   parameters: getFullParameters(params)).responseJSON{ response in
                    print("\(Group.self)s получены с сервера ВК")
                    guard let data = response.data else { return }
                    let array: [Group]? = decodeRequestData(method: Methods.getSearchGroups, data: data)
                    if let array = array {
                        RealmService.saveData(array, withoutDelete: true)
                        completion(RealmService.getData(for: ("name", "CONTAINS[c]", "String"), with: searchText))
                    }
        }
    }
    
    /// Метод для получения новостей с сервера
    /// - Parameter completion: замыкание для возврата данных
    static func getNewsfeed(startTime: String = "", startFrom: String = "", completion: @escaping (_ array : NewsItems?) -> Void) {
        var params: Parameters = [
            "count" : 20,
            "filters" : "post"
        ]
        if !startTime.isEmpty {
            params["start_time"] = startTime
        }
        if !startFrom.isEmpty {
            params["start_from"] = startFrom
        }
        AF.request("https://api.vk.com/method/" + Methods.getNews.rawValue,
                   parameters: getFullParameters(params)).responseJSON(queue: .global()){ response in
                    do {
                        print("News получены с сервера ВК")
                        
                        guard let data = response.data else { return }
                        let res = try JSONDecoder().decode(ResponseNews.self, from: data)
                        DispatchQueue.main.async {
                            completion(res.response)
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
    
    /// Метод для получения ленты с комментариями
    /// - Parameter completion: замыкание для возврата
    static func getNewsfeedComments(completion: @escaping (_ array : NewsItems?) -> Void) {
        let params: Parameters = [
            "last_comments_count" : 10,
            "count" : 10,
            "filters" : "post"
        ]
        AF.request("https://api.vk.com/method/" + Methods.getNewsComments.rawValue,
                   parameters: getFullParameters(params)).responseJSON{ response in
                    do {
                        print("Newscomments получены с сервера ВК")
                        
                        guard let data = response.data else { return }
                        print(response)
                        let res = try JSONDecoder().decode(ResponseNews.self, from: data)
                        completion(res.response)
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
    
    /// Метод для получения пользователея по ид
    /// - Parameters:
    ///   - userId: идентификатор пользователя
    ///   - completion: замыкание для возврата данных
    static func getUserById(userId : Int,
                            completion: @escaping (_ array : User?) -> Void) {
        let params: Parameters = [
            "user_ids": userId,
            "fields": "nickname, domain, sex, photo_100, online"
        ]
        AF.request("https://api.vk.com/method/" + Methods.getUsers.rawValue,
                   parameters: getFullParameters(params)).responseJSON{ response in
                    print(response)
                    guard let data = response.data else { return }
                    do {
                        let res = try JSONDecoder().decode(ResponseUsers.self, from: data)
                        let array: [User]? = res.response
                        if let array = array {
                            completion(array[0])
                        }
                    } catch {
                        print("error")
                    }
        }
    }
    
    /// Метод для получения универсальных данных с сервера
    /// - Parameters:
    ///   - method: метод запроса
    ///   - parameters: параметры для запроса
    ///   - completion: замыкание для возврата данных
    private static func getServerData<T : Decodable & Object & HaveID>(method : Methods,
                                                                       with parameters: Parameters,
                                                                       completion: @escaping (_ array : Results<T>?) -> Void){
        AF.request("https://api.vk.com/method/" + method.rawValue,
                   parameters: getFullParameters(parameters)).responseJSON{ response in
                    print("\(T.self)s получены с сервера ВК")
                    guard let data = response.data else { return }
                    let array: [T]? = decodeRequestData(method: method, data: data)
                    if let array = array {
                        //сохрняем данные в БД
                        RealmService.saveData(array)
                        //получаем сохраненные данные из БД, чтобы получился Results<T>
                        completion(RealmService.getData())
                    }
        }
    }
    
    /// Метод для получения универсальных данных с сервера без комплишна
    /// - Parameters:
    ///   - method: метод запроса
    ///   - parameters: параметры для запроса
    private static func getServerData<T : Decodable & Object & HaveID>(method : Methods,
                                                                       with parameters: Parameters,
                                                                       dataType : T.Type) {
        let queue = DispatchQueue.global(qos: .utility)
        var array: [T]?
        AF.request("https://api.vk.com/method/" + method.rawValue,
                   parameters: getFullParameters(parameters)).responseJSON(queue: queue){ response in
                    print("\(T.self)s получены с сервера ВК")
                    guard let data = response.data else { return }
                    array = decodeRequestData(method: method, data: data)
                    DispatchQueue.main.async {
                        if let array = array {
                            //сохрняем данные в БД
                            RealmService.saveData(array)
                        }
                    }
        }
    }
    
    static func getData<T : Decodable & Object & HaveID>(method : Methods,
                                                         with parameters: Parameters,
                                                         dataType : T.Type) {
        let opq : OperationQueue = OperationQueue()
        opq.maxConcurrentOperationCount = 2
        let request = AF.request("https://api.vk.com/method/" + method.rawValue,
                                 parameters: DataService.getFullParameters(parameters))
        let getDataOperation = GetDataOperation(request: request)
        opq.addOperation(getDataOperation)
        
        let parseData = ParseData(method: method)
        parseData.addDependency(getDataOperation)
        opq.addOperation(parseData)
        
        let realmSaver = RealmSaver(inputData: nil)
        realmSaver.addDependency(parseData)
        OperationQueue.main.addOperation(realmSaver)
    }
    
    /// Метод для отправки запроса на сервер
    /// - Parameters:
    ///   - item: добавляемый/изменяемый объект
    ///   - method: метод запроса
    static func postDataToServer<T: Object & Codable>(for item: T, method : Methods){
        switch method {
        case .joinGroup, .leaveGroup:
            let params: Parameters = ["group_id" : (item as! Group).id]
            AF.request("https://api.vk.com/method/" + method.rawValue, method: .post,
                       parameters: getFullParameters(params)).responseJSON(completionHandler:  {
                        response in
                        print(response.result)
                       })
            RealmService.saveObject(for: item, method: method)
        default:
            return
        }
    }
    
    /// Метод для преобразования json в указанную модель
    /// - Parameters:
    ///   - method: метод, по которому определяется тип возвращаемых данных
    ///   - data: json
    /// - Returns: опциональный массив с объектами
    private static func decodeRequestData<T : Object & Decodable>(method : Methods,
                                                                  data: Data) -> [T]? {
        var array = Array<Any>()
        do {
            let res : Any?
            switch method {
            case .getFriends :
                res = try JSONDecoder().decode(Response<User>.self, from: data)
            case .getUserGroups, .getSearchGroups, .getGroupById :
                res = try JSONDecoder().decode(Response<Group>.self, from: data)
            case .getAllPhotos :
                res = try JSONDecoder().decode(Response<Photo>.self, from: data)
            default :
                return nil
            }
            array = (res! as! Response<T>).response.items
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
        return array as? [T]
    }
    
    
    
    /// Метод для формаирования полных параметров запроса, включая токен и номер версии АПИ
    /// - Parameter params: параметры запроса
    /// - Returns: полные параметры для запроса
    private static func getFullParameters(_ params : Parameters) -> Parameters {
        var parameters = params
        parameters["access_token"] = Session.instance.token
        parameters["v"] = "5.103"
        return parameters
    }
    
    
    /// Типы запросов
    private enum RequestTypes: String {
        case auth
        case method
    }
    
    /// Типы методов
    enum Methods: String {
        case getFriends = "friends.get"
        case authorize
        case getAllPhotos = "photos.getAll"
        case getUserGroups = "groups.get"
        case getSearchGroups = "groups.search"
        case getGroupById = "groups.getById"
        case getNews = "newsfeed.get"
        case joinGroup = "groups.join"
        case leaveGroup = "groups.leave"
        case getUsers = "users.get"
        case getNewsComments = "newsfeed.getComments"
    }
    
}
