//
//  VKSession.swift
//  VKappNew
//
//  Created by Павел on 01.10.2020.
//

import Foundation

class Session {

    var token: String = ""
    var userID: Int = 0
    
    private init() {}
    
    public static let shared = Session()
}
