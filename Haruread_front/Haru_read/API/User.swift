//
//  User.swift
//  Haru_read
//
//  Created by 이준수 on 2024/05/12.
//

import Foundation
import Alamofire

class User
{
    struct CSRFTokenResponse: Decodable{
        let csrf_token: String
    }
    
    struct AuthResponse: Decodable{
        let is_authenticated: Bool
    }
    
    struct LoginRequestParam: Encodable{
        let username: String
        let password: String
        let csrfmiddlewaretoken: String
    }
    
    struct SignupRequestParam: Encodable{
        let username: String
        let password1: String
        let password2: String
        let email: String
        let nick_name: String
        let csrfmiddlewaretoken: String
    }
    
    static let instance = User()
    
    static let host = "http://192.168.45.225:8000/"
    
    private init() {}
    
    var is_authenticated = false
    
    private func get_csrf_token(endpoint: String,  completion: @escaping (String) -> Void) -> Void
    {
        
        
        AF.request(User.host+endpoint, method: .get).responseDecodable(of: CSRFTokenResponse.self){ res in
            guard case .success(let token_response) = res.result else {
                print("\(res.description)")
                return
            }
            let token = token_response.csrf_token
            
            completion(token)
        }
        
        return
    }
    
    private func check_auth()
    {
        AF.request(User.host + "members/auth/", method: .get).responseDecodable(of: AuthResponse.self){res in
            guard case .success(let auth_response) = res.result else{
                print("Auth check failed: \(res.description)")
                return
            }
            
            User.instance.is_authenticated = auth_response.is_authenticated
        }
    }
    
    public func signup(username: String, password1: String, password2: String, email: String, nick_name: String)
    {
        
        
        self.get_csrf_token(endpoint: "members/join/"){ token in
            let param = SignupRequestParam(username: username, password1:password1, password2: password2, email:email, nick_name:nick_name, csrfmiddlewaretoken: token)
            AF.request(User.host+"members/join/", method: .post, parameters: param).responseString{res in
                print(res)
            }
        }
    }
    public func login(username: String, password: String)
    {
        self.get_csrf_token(endpoint: "members/join/"){ token in
            let param = LoginRequestParam(username: username, password: password, csrfmiddlewaretoken: token)
            print("login: id \(username)  passwd \(password)")
            
            
            AF.request(User.host+"members/login/", method: .post, parameters: param, encoder: URLEncodedFormParameterEncoder(destination: .methodDependent)).responseString{res in
                self.check_auth()
                
                if(self.is_authenticated == false)
                {
                    print("login failed")
                }
                else
                {
                    print("login successed")
                }
            }
        }
        
    }
}
