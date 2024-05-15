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
    
    //define response param struct
    struct CSRFTokenResponse: Decodable{
        let csrf_token: String
    }
    
    struct AuthResponse: Decodable{
        let is_authenticated: Bool
    }
    
    struct HaruSettingResponse: Decodable{
        let success: Bool
    }
    
    struct SignupResponse: Decodable{
        let success: Bool
    }
    
    
    //define request param struct
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
    
    struct HaruSettingRequestParam: Encodable{
        let HARU_OLD: Int
        let HARU_STYLE: Int
        let HARU_GENDER: Int
        let csrfmiddlewaretoken: String
    }
    
    
    struct HaruSettingDict{
        static let Old: [String: Int] = ["유년층": 0, "청소년층": 1, "성인층": 2, "노년층": 3]
        static let Style: [String: Int] = ["구연체": 2, "낭독체": 6, "대화체": 1, "독백체": 0, "애니체": 5, "중계체": 3, "친절체": 4]
        static let Gender: [String: Int] =  ["남자": 0, "여자": 1]
        
        static func validate(old: String?, style: String?, gender: String?) -> Bool {
            guard let old = old, let style = style, let gender = gender else {
                return false // If any parameter is nil, return false
            }
            
            let oldValid = Old.keys.contains(old)
            let styleValid = Style.keys.contains(style)
            let genderValid = Gender.keys.contains(gender)
            
            return oldValid && styleValid && genderValid
        }
    }
    
    private var HaruSetting: [String: String] = ["Old": "", "Style": "", "Gender": ""]
    
    
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
    
    public func signup(username: String, password1: String, password2: String, email: String, nick_name: String, onsuccess: @escaping () -> ())
    {
        
        
        self.get_csrf_token(endpoint: "members/join/"){ token in
            let param = SignupRequestParam(username: username, password1:password1, password2: password2, email:email, nick_name:nick_name, csrfmiddlewaretoken: token)
            AF.request(User.host+"members/join/", method: .post, parameters: param).responseDecodable(of: SignupResponse.self){res in
                guard case .success(let signup_response) = res.result else {
                    User.instance.is_authenticated = false
                    return
                }
                User.instance.is_authenticated = signup_response.success
                
                if User.instance.is_authenticated
                {
                    onsuccess()
                }
                
            }
        }
    }
    
    public func login(username: String, password: String, onsuccess: @escaping () -> ())
    {
        self.get_csrf_token(endpoint: "members/join/"){ token in
            let param = LoginRequestParam(username: username, password: password, csrfmiddlewaretoken: token)
            print("login: id \(username)  passwd \(password)")
            
            
            AF.request(User.host+"members/login/", method: .post, parameters: param, encoder: URLEncodedFormParameterEncoder(destination: .methodDependent)).responseString{res in
                
                guard case .success(_) = res.result else{
                    return
                }
                
                onsuccess()
                
            }
        }
        
    }
        
    
    
    public func change_haru_setting(old:String, style:String, gender:String)
    {
        
        if HaruSettingDict.validate(old:old, style:style, gender:gender)
        {
            
            self.get_csrf_token(endpoint: "members/haru_setting/"){token in
                let param: HaruSettingRequestParam = HaruSettingRequestParam(
                    HARU_OLD: HaruSettingDict.Old[old]!,
                    HARU_STYLE: HaruSettingDict.Style[style]!,
                    HARU_GENDER: HaruSettingDict.Gender[gender]!,
                    csrfmiddlewaretoken: token
                )
                
                debugPrint(param)
                
                AF.request(User.host+"members/haru_setting/", method: .post, parameters: param, encoder: URLEncodedFormParameterEncoder(destination: .methodDependent)).responseDecodable(of: HaruSettingResponse.self){res in
                    guard case .success(let haru_response) = res.result else {
                        return
                    }
                    if haru_response.success
                    {
                        self.HaruSetting["Old"] = old
                        self.HaruSetting["Style"] = style
                        self.HaruSetting["Gender"] = gender
                        
                        print("Haru setting changed")
                        
                        debugPrint(self.HaruSetting)
                    }
                }
            }
        }
    }
}
