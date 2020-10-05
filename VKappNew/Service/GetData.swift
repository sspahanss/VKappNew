//
//  GetData.swift
//  VKappNew
//
//  Created by Павел on 05.10.2020.
//

import Foundation
import Alamofire

class GetDataOperation: AsyncOperation {

    override func cancel() {
        request.cancel()
        super.cancel()
    }
    
    private var request: DataRequest
    var data: Data?
    
    override func main() {
        request.responseData(queue: DispatchQueue.global(qos: .utility)) { [weak self] response in
            self?.data = response.data
            self?.state = .finished
        }
    }
    
    init(request: DataRequest) {
        self.request = request
    }
    
}
