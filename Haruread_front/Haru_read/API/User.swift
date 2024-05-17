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
    
    struct ProfileGetResponse: Decodable{
        let nick_name: String
        let HARU_OLD: Int
        let HARU_STYLE: Int
        let HARU_GENDER: Int
    }
    
    struct UserProfile{
        let nick_name: String
        let old: String
        let style: String
        let gender: String
    }
    
    struct HaruSettingGetResponse: Decodable{
        let HARU_OLD: Int
        let HARU_STYLE: Int
        let HARU_GENDER: Int
    }
    
    struct HaruSettingChangeResponse: Decodable{
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
    
    struct HaruSettingChangeRequestParam: Encodable{
        let HARU_OLD: Int
        let HARU_STYLE: Int
        let HARU_GENDER: Int
        let csrfmiddlewaretoken: String
    }
    
    
    struct HaruSettingDict{
        static let Old: [String: Int] = ["유년층": 0, "청소년층": 1, "성인층": 2, "노년층": 3]
        static let OldArray: [String] = ["유년층", "청소년층", "성인층", "노년층"]
        
        static let Style: [String: Int] = ["구연체": 2, "낭독체": 6, "대화체": 1, "독백체": 0, "애니체": 5, "중계체": 3, "친절체": 4]
        static let StyleArray: [String] = ["독백체", "대화체", "구연체", "중계체", "친절체", "애니체", "낭독체"]
        
        static let Gender: [String: Int] =  ["남자": 0, "여자": 1]
        static let GenderArray: [String] = ["남자", "여자"]
        
        static func validate(old: String?, style: String?, gender: String?) -> Bool {
            guard let old = old, let style = style, let gender = gender else {
                return false // If any parameter is nil, return false
            }
            
            let oldValid = Old.keys.contains(old)
            let styleValid = Style.keys.contains(style)
            let genderValid = Gender.keys.contains(gender)
            
            return oldValid && styleValid && genderValid
        }
        
        static func validate(old: Int, style: Int, gender:Int) -> Bool
        {
            let oldValid = (OldArray.startIndex...OldArray.endIndex).contains(old)
            let styleValid = (StyleArray.startIndex...OldArray.endIndex).contains(old)
            let genderValid = (GenderArray.startIndex...OldArray.endIndex).contains(old)
            
            return oldValid && styleValid && genderValid
        }
    }
    
    private var HaruSetting: [String: String] = ["Old": "", "Style": "", "Gender": ""]
    
    
    static let instance = User()
    
    static let host = "http://192.168.45.225:8000/"
    
    private init() {}
    
    var is_authenticated = false
    var profile: UserProfile? = nil
    
    private func get_csrf_token(completion: @escaping (String) -> Void) -> Void
    {
        
        
        AF.request(User.host+"members/csrf_token/", method: .get).responseDecodable(of: CSRFTokenResponse.self){ res in
            guard case .success(let token_response) = res.result else {
                print("\(res.description)")
                return
            }
            let token = token_response.csrf_token
            
            completion(token)
        }
        
        return
    }
    
    public func signup(username: String, password1: String, password2: String, email: String, nick_name: String, onsuccess: @escaping () -> (), onfailure: @escaping () -> ())
    {
        
        
        self.get_csrf_token{ token in
            let param = SignupRequestParam(username: username, password1:password1, password2: password2, email:email, nick_name:nick_name, csrfmiddlewaretoken: token)
            AF.request(User.host+"members/join/", method: .post, parameters: param).responseDecodable(of: SignupResponse.self){res in
                guard case .success(let signup_response) = res.result else {
                    User.instance.is_authenticated = false
                    onfailure()
                    return
                }
                User.instance.is_authenticated = signup_response.success
                
                if User.instance.is_authenticated
                {
                    onsuccess()
                }
                else
                {
                    onfailure()
                }
                
            }
        }
    }
    
    public func login(username: String, password: String, onsuccess: @escaping () -> (), onfailure: @escaping () -> ())
    {
        self.get_csrf_token{ token in
            let param = LoginRequestParam(username: username, password: password, csrfmiddlewaretoken: token)
            print("login: id \(username)  passwd \(password)")
            
            
            AF.request(User.host+"members/login/", method: .post, parameters: param, encoder: URLEncodedFormParameterEncoder(destination: .methodDependent)).responseString{res in
                
                guard case .success(_) = res.result else{
                    onfailure()
                    return
                }
                
                if (400...599).contains(res.response!.statusCode)
                {
                    onfailure()
                    return
                }
                
                onsuccess()
                
            }
        }
        
    }
    
    public func get_profile(onsuccess: @escaping () -> (), onfailure: @escaping () -> ())
    {
        if User.instance.is_authenticated
        {
            self.get_csrf_token{token in
                AF.request(User.host + "members/profile/", method: .get).responseDecodable(of: ProfileGetResponse.self){ res in
                    guard case .success(let user_profile) = res.result else {
                        onfailure()
                        return
                    }
                    
                    debugPrint(user_profile)
                    
                    if HaruSettingDict.validate(old: user_profile.HARU_OLD, style: user_profile.HARU_STYLE, gender: user_profile.HARU_GENDER)
                    {
                        self.profile = UserProfile(
                            nick_name: user_profile.nick_name,
                            old: HaruSettingDict.OldArray[user_profile.HARU_OLD],
                            style: HaruSettingDict.StyleArray[user_profile.HARU_STYLE],
                            gender: HaruSettingDict.GenderArray[user_profile.HARU_GENDER]
                        )
                        onsuccess()
                    }
                    else
                    {
                        onfailure()
                    }
                    
                }
            }
        }
        else
        {
            onfailure()
        }
    }
        
    public func get_haru_setting(onsuccess: @escaping () -> (), onfailure: @escaping () -> ())
    {
        if User.instance.is_authenticated
        {
            self.get_csrf_token{token in
                AF.request(User.host + "members/haru_setting/", method: .get).responseDecodable(of: HaruSettingGetResponse.self){ res in
                    guard case .success(let haru_setting) = res.result else {
                        onfailure()
                        return
                    }
                    
                    debugPrint(haru_setting)
                }
            }
        }
        else
        {
            onfailure()
        }
    }
    
    public func change_haru_setting(old:String, style:String, gender:String, onsuccess: @escaping () -> (), onfailure: @escaping () -> ())
    {
        
        if HaruSettingDict.validate(old:old, style:style, gender:gender)
        {
            
            self.get_csrf_token{token in
                let param: HaruSettingChangeRequestParam = HaruSettingChangeRequestParam(
                    HARU_OLD: HaruSettingDict.Old[old]!,
                    HARU_STYLE: HaruSettingDict.Style[style]!,
                    HARU_GENDER: HaruSettingDict.Gender[gender]!,
                    csrfmiddlewaretoken: token
                )
                
                debugPrint(param)
                
                AF.request(User.host+"members/haru_setting/", method: .post, parameters: param, encoder: URLEncodedFormParameterEncoder(destination: .methodDependent)).responseDecodable(of: HaruSettingChangeResponse.self){res in
                    guard case .success(let haru_response) = res.result else {
                        return
                    }
                    if haru_response.success
                    {
                        self.HaruSetting["Old"] = old
                        self.HaruSetting["Style"] = style
                        self.HaruSetting["Gender"] = gender
                        
                        debugPrint(self.HaruSetting)
                        
                        onsuccess()
                    }
                    else
                    {
                        onfailure()
                    }
                }
            }
        }
        else
        {
            onfailure()
        }
    }
}
