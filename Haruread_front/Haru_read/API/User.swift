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
        let id: String
        let email: String
        let nick_name: String
        let HARU_OLD: Int
        let HARU_STYLE: Int
        let HARU_GENDER: Int
    }
    
    struct UserProfile{
        let id: String
        let email: String
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
    
    struct LogoutResponse: Decodable{
        let success: Bool
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
            
            var oldValid = true
            var styleValid = true
            var genderValid = true
            
            if old != nil {
                oldValid = Old.keys.contains(old!)
            }
            
            if style != nil{
                styleValid = Style.keys.contains(style!)
            }
            if gender != nil{
                genderValid = Gender.keys.contains(gender!)
            }
            
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
    
    static let host = "http://175.125.148.178:2871/"
    
    private init() {}
    
    var is_authenticated = false
    var profile: UserProfile? = nil
    
    private func get_csrf_token(completion: @escaping (String) -> Void) -> Void
    {
        
        
        AF.request(User.host+"webpage/csrf_token/", method: .get).responseDecodable(of: CSRFTokenResponse.self){ res in
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
            AF.request(User.host+"webpage/join/", method: .post, parameters: param).responseDecodable(of: SignupResponse.self){res in
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
    
    private func onloginsuccess()
    {
        self.get_profile{
            print("login success, get profile success")
        } onfailure: {
            print("login success, get profile failed")
        }
    }
    
    public func login(username: String, password: String, onsuccess: @escaping () -> (), onfailure: @escaping () -> ())
    {
        self.get_csrf_token{ token in
            let param = LoginRequestParam(username: username, password: password, csrfmiddlewaretoken: token)
            print("login: id \(username)  passwd \(password)")
            
            
            AF.request(User.host+"webpage/login/", method: .post, parameters: param, encoder: URLEncodedFormParameterEncoder(destination: .methodDependent)).responseString{res in
                
                guard case .success(_) = res.result else{
                    onfailure()
                    return
                }
                
                if (400...599).contains(res.response!.statusCode)
                {
                    onfailure()
                    return
                }
                self.is_authenticated = true
                onsuccess()
            }
        }
        
    }
    
    public func logout()
    {
        self.get_csrf_token(){token in
            AF.request(User.host + "webpage/logout/", method: .get).responseDecodable(of: LogoutResponse.self){res in
                guard case .success(let logout_response) = res.result else{
                    return
                }
                
                if logout_response.success {
                    User.instance.is_authenticated = false
                }
            }
        }
    }
    
    public func get_profile(onsuccess: @escaping () -> (), onfailure: @escaping () -> ())
    {
        if User.instance.is_authenticated
        {
            self.get_csrf_token{token in
                AF.request(User.host + "webpage/profile/", method: .get).responseDecodable(of: ProfileGetResponse.self){ res in
                    guard case .success(let user_profile) = res.result else {
                        onfailure()
                        return
                    }
                    
                    debugPrint(user_profile)
                    
                    if HaruSettingDict.validate(old: user_profile.HARU_OLD, style: user_profile.HARU_STYLE, gender: user_profile.HARU_GENDER)
                    {
                        self.profile = UserProfile(
                            id: user_profile.id,
                            email: user_profile.email,
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
                AF.request(User.host + "webpage/haru_setting/", method: .get).responseDecodable(of: HaruSettingGetResponse.self){ res in
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
    
    public func change_haru_setting(old:String?, style:String?, gender:String?, onsuccess: @escaping () -> (), onfailure: @escaping () -> ())
    {
        
        if HaruSettingDict.validate(old:old, style:style, gender:gender)
        {
            
            self.get_csrf_token{token in
                let param: HaruSettingChangeRequestParam = HaruSettingChangeRequestParam(
                    HARU_OLD: HaruSettingDict.Old[(old ?? User.instance.profile?.old)!]!,
                    HARU_STYLE: HaruSettingDict.Style[(style ?? User.instance.profile?.style)!]!,
                    HARU_GENDER: HaruSettingDict.Gender[(gender ?? User.instance.profile?.gender)!]!,
                    csrfmiddlewaretoken: token
                )
                
                debugPrint(param)
                
                AF.request(User.host+"webpage/haru_setting/", method: .post, parameters: param, encoder: URLEncodedFormParameterEncoder(destination: .methodDependent)).responseDecodable(of: HaruSettingChangeResponse.self){res in
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
    
    public func send_diary(emotion: String, wav_file: URL)
    {
        AF.upload(multipartFormData:{ multipartFormData in
            if let emo = emotion.data(using: .utf8){
                multipartFormData.append(emo, withName: "EMO")
            }
            
            multipartFormData.append(wav_file, withName: "wav_file", fileName: "recordFile.wav", mimeType: "audio/wav")
        }, to: User.host+"haru/post/")
        .response{ response in
            switch response.result{
            case .success(let data):
                if let data = data, let res = String(data: data, encoding: .utf8){
                    debugPrint("Diary Upload Result: \(res)")
                }
            case .failure(let err):
                    print("Diary Upload failed \(err)")
            }
        }
    }
}
