//
//  VKLoginViewController.swift
//  VKappNew
//
//  Created by Павел on 01.10.2020.
//

import UIKit
import WebKit
import Alamofire

class VKLoginController: UIViewController {
    
    @IBOutlet weak var webView: WKWebView! 
    
    let vkRequest = VKRequests()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        webView.load(vkRequest.vkLoginRequest())
        webView.navigationDelegate = self
        
    }
    
}

extension VKLoginController: WKNavigationDelegate {
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationResponse: WKNavigationResponse, decisionHandler: @escaping (WKNavigationResponsePolicy) -> Void) {
        
        guard let url = navigationResponse.response.url, url.path == "/blank.html", let fragment = url.fragment
        else {
            decisionHandler(.allow)
            return
        }
        
     
        
        let params = fragment
            .components(separatedBy: "&")
            .map { $0.components(separatedBy: "=")}
            .reduce([String: String]()) { result, param in
                var dict = result
                let key = param[0]
                let value = param[1]
                dict[key] = value
                return dict
            }
        guard let token = params["access_token"],
              let userId = Int(params["user_id"]!)
        else {
            decisionHandler(.allow)
            return
        }
        
        Session.instance.token = token
        Session.instance.userID = userId
        debugPrint(Session.instance.token, "это токен")
        
        
        
        performSegue(withIdentifier: "VKLogin", sender: nil)
        decisionHandler(.cancel)
   
    }
    
}
extension UIImage {
    static func getImage(from string: String) -> UIImage? {
        guard let url = URL(string: string)
            else {
                print("Unable to create URL")
                return nil
        }
        
        var image: UIImage? = nil
        do {
            let data = try Data(contentsOf: url, options: [])
            image = UIImage(data: data)
        }
        catch {
            print(error.localizedDescription)
        }
        return image
    }
}
