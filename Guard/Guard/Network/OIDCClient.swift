//
//  OIDCClient.swift
//  Guard
//
//  Created by Lance Mao on 2022/3/2.
//

import Foundation

public class OIDCClient: NSObject {
    
    public var authRequest: AuthRequest = AuthRequest()
    
    public init(_ authRequest: AuthRequest? = nil) {
        super.init()
        
        if let authData = authRequest {
            self.authRequest = authData
        }
        Authing.getConfig { config in
            if let conf = config {
                if conf.redirectUris?.count ?? 0 > 0{
                    if let url = conf.redirectUris?.first { self.authRequest.redirect_uri = url }
                }
            }
        }
    }
    
    // MARK: Util APIs
    public func buildAuthorizeUrl(completion: @escaping (URL?) -> Void) {
        Authing.getConfig { config in
            if (config == nil) {
                completion(nil)
            } else {
                
                let secret = self.authRequest.client_secret
                
                let url = "\(Authing.getSchema())://\(Util.getHost(config!))/oidc/auth?"
                + "nonce=" + self.authRequest.nonce
                + "&scope=" + self.authRequest.scope.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
                + "&client_id=" + self.authRequest.client_id
                + "&redirect_uri=" + self.authRequest.redirect_uri
                + "&response_type=" + self.authRequest.response_type
                + "&prompt=consent"
                + "&state=" + self.authRequest.state
                + (secret == nil ? "&code_challenge=" + self.authRequest.codeChallenge! + "&code_challenge_method=S256" : "");

                completion(URL(string: url))
            }
        }
    }
    
    public func authByCode(code: String, completion: @escaping(Int, String?, UserInfo?) -> Void) {
        
        let secret = self.authRequest.client_secret
        let secretStr = (secret == nil ? "&code_verifier=" + self.authRequest.codeVerifier : "&client_secret=" + (secret ?? ""))

        let body = "client_id="+Authing.getAppId()
                    + "&grant_type=authorization_code"
                    + "&code=" + code
                    + "&scope=" + self.authRequest.scope
                    + "&prompt=" + "consent"
                    + secretStr
                    + "&redirect_uri=" + self.authRequest.redirect_uri
        
        request(userInfo: nil, endPoint: "/oidc/token", method: "POST", body: body) { code, message, data in
            if (code == 200) {
                AuthClient().createUserInfo(code, message, data) { code, message, userInfo in
                    self.getUserInfoByAccessToken(userInfo: userInfo, completion: completion)
                }
            } else {
                completion(code, message, nil)
            }
        }
    }
    
    public func prepareLogin(config: Config, completion: @escaping(Int, String?, AuthRequest?) -> Void) {
            
        let url = "\(Authing.getSchema())://\(Util.getHost(config))/oidc/auth?_authing_lang=\(Util.getLangHeader())"
        + "&app_id=" + authRequest.client_id
        + "&client_id=" + authRequest.client_id
        + "&nonce=" + authRequest.nonce
        + "&redirect_uri=" + authRequest.redirect_uri
        + "&response_type=" + authRequest.response_type
        + "&scope=" + authRequest.scope.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
        + "&prompt=consent"
        + "&state=" + authRequest.state
        + "&code_challenge=" + authRequest.codeChallenge!
        + "&code_challenge_method=S256"
        
        var request = URLRequest(url: URL(string: url)!)
        request.httpMethod = "GET"
        
        let session = URLSession.init(configuration: URLSessionConfiguration.default, delegate: OIDCClient(), delegateQueue: nil)
        session.dataTask(with: request) { (data, response, error) in
            guard error == nil else {
                completion(500, "network error \(url) \n\(error!)", self.authRequest)
                return
            }
            
            let httpResponse = response as? HTTPURLResponse
            let statusCode: Int = httpResponse?.statusCode ?? 0
            if statusCode == 302{
                let location: String = httpResponse?.allHeaderFields["Location"] as? String ?? ""
                let uuid = URL(string: location)?.lastPathComponent
                self.authRequest.uuid = uuid

                completion(200, "", self.authRequest)
            } else {
                completion(statusCode, String(decoding: data!, as: UTF8.self), nil)
            }
        }.resume()
    }
    
    // MARK: AuthorizationCode APIs
    ///邮箱注册获取 Authorization code
    public func getAuthCodeForEmailRegister(email: String, password: String, completion: @escaping(Int, String?, UserInfo?) -> Void) {
        Authing.getConfig { config in
            if let conf = config{
                self.prepareLogin(config: conf) { code, message, authRequest in
                    if code == 200{
                        authRequest?.returnAuthorizationCode = true
                        AuthClient().registerByEmail(authData: authRequest, email: email, password: password, completion: completion)
                    } else {
                        completion(code, message, nil)
                    }
                }
            } else {
                completion(500, "Cannot get config. app id:\(Authing.getAppId())", nil)
            }
        }
    }
    
    ///手机号验证码注册获取 Authorization code
    public func getAuthCodeForPhoneCodeRegister(phoneCountryCode: String? = nil, phone: String, code: String, password: String? = nil, completion: @escaping(Int, String?, UserInfo?) -> Void) {
        Authing.getConfig { config in
            if let conf = config{
                self.prepareLogin(config: conf) { statusCode, message, authRequest in
                    if statusCode == 200{
                        authRequest?.returnAuthorizationCode = true
                        AuthClient().registerByPhoneCode(authData: authRequest, phoneCountryCode: phoneCountryCode, phone: phone, code: code, password: password, completion: completion)
                    } else {
                        completion(statusCode, message, nil)
                    }
                }
            } else {
                completion(500, "Cannot get config. app id:\(Authing.getAppId())", nil)
            }
        }
    }
    
    ///用户名密码注册获取 Authorization code
    public func getAuthCodeForUserNameRegister(username: String, password: String, completion: @escaping(Int, String?, UserInfo?) -> Void) {
        Authing.getConfig { config in
            if let conf = config{
                self.prepareLogin(config: conf) { code, message, authRequest in
                    if code == 200{
                        authRequest?.returnAuthorizationCode = true
                        AuthClient().registerByUserName(authData: authRequest, username: username, password: password, completion: completion)
                    } else {
                        completion(code, message, nil)
                    }
                }
            } else {
                completion(500, "Cannot get config. app id:\(Authing.getAppId())", nil)
            }
        }
    }
    
    ///账号登录获取 Authorization code
    public func getAuthCodeForAccountLogin(account: String, password: String, completion: @escaping(Int, String?, UserInfo?) -> Void) {
        Authing.getConfig { config in
            if let conf = config{
                self.prepareLogin(config: conf) { code, message, authRequest in
                    if code == 200{
                        authRequest?.returnAuthorizationCode = true
                        AuthClient().loginByAccount(authData: authRequest ,account: account, password: password, completion: completion)
                    } else {
                        completion(code, message, nil)
                    }
                }
            } else {
                completion(500, "Cannot get config. app id:\(Authing.getAppId())", nil)
            }
        }
    }
    
    ///手机号验证码登录获取 Authorization code
    public func getAuthCodeForPhoneCodeLogin(phoneCountryCode: String? = nil, phone: String, code: String, completion: @escaping(Int, String?, UserInfo?) -> Void) {
        Authing.getConfig { config in
            if let conf = config{
                self.prepareLogin(config: conf) { statuCode, message, authRequest in
                    if statuCode == 200{
                        authRequest?.returnAuthorizationCode = true
                        AuthClient().loginByPhoneCode(authData: authRequest, phoneCountryCode: phoneCountryCode,  phone: phone, code: code, completion: completion)
                    } else {
                        completion(statuCode, message, nil)
                    }
                }
            } else {
                completion(500, "Cannot get config. app id:\(Authing.getAppId())", nil)
            }
        }
    }
    
    ///微信登录获取 Authorization code
    public func getAuthCodeForWechatLogin(_ code: String, completion: @escaping(Int, String?, UserInfo?) -> Void) {
        Authing.getConfig { config in
            if let conf = config{
                self.prepareLogin(config: conf) { statuCode, message, authRequest in
                    if statuCode == 200{
                        authRequest?.returnAuthorizationCode = true
                        AuthClient().loginByWechat(authData: authRequest, code, completion: completion)
                    } else {
                        completion(statuCode, message, nil)
                    }
                }
            } else {
                completion(500, "Cannot get config. app id:\(Authing.getAppId())", nil)
            }
        }
    }
    
    // MARK: Register APIs
    public func registerByEmail(email: String, password: String, completion: @escaping(Int, String?, UserInfo?) -> Void) {
        Authing.getConfig { config in
            if let conf = config{
                self.prepareLogin(config: conf) { code, message, authRequest in
                    if code == 200{
                        AuthClient().registerByEmail(authData: authRequest, email: email, password: password, completion: completion)
                    } else {
                        completion(code, message, nil)
                    }
                }
            } else {
                completion(500, "Cannot get config. app id:\(Authing.getAppId())", nil)
            }
        }
    }
    
    public func registerByUserName(username: String, password: String, completion: @escaping(Int, String?, UserInfo?) -> Void) {
        Authing.getConfig { config in
            if let conf = config{
                self.prepareLogin(config: conf) { code, message, authRequest in
                    if code == 200{
                        AuthClient().registerByUserName(authData: authRequest, username: username, password: password, completion: completion)
                    } else {
                        completion(code, message, nil)
                    }
                }
            } else {
                completion(500, "Cannot get config. app id:\(Authing.getAppId())", nil)
            }
        }
    }
    
    public func registerByPhoneCode(phoneCountryCode: String? = nil, phone: String, code: String, password: String? = nil, completion: @escaping(Int, String?, UserInfo?) -> Void) {
        Authing.getConfig { config in
            if let conf = config{
                self.prepareLogin(config: conf) { statusCode, message, authRequest in
                    if statusCode == 200{
                        AuthClient().registerByPhoneCode(authData: authRequest, phoneCountryCode: phoneCountryCode, phone: phone, code: code, password: password, completion: completion)
                    } else {
                        completion(statusCode, message, nil)
                    }
                }
            } else {
                completion(500, "Cannot get config. app id:\(Authing.getAppId())", nil)
            }
        }
    }

    // MARK: Login APIs
    public func loginByAccount(account: String, password: String, completion: @escaping(Int, String?, UserInfo?) -> Void) {
        Authing.getConfig { config in
            if let conf = config{
                self.prepareLogin(config: conf) { code, message, authRequest in
                    if code == 200{
                        AuthClient().loginByAccount(authData: authRequest ,account: account, password: password, completion: completion)
                    } else {
                        completion(code, message, nil)
                    }
                }
            } else {
                completion(500, "Cannot get config. app id:\(Authing.getAppId())", nil)
            }
        }
    }
    
    public func loginByPhoneCode(phoneCountryCode: String? = nil, phone: String, code: String, completion: @escaping(Int, String?, UserInfo?) -> Void) {
        Authing.getConfig { config in
            if let conf = config{
                self.prepareLogin(config: conf) { statuCode, message, authRequest in
                    if statuCode == 200{
                        AuthClient().loginByPhoneCode(authData: authRequest, phoneCountryCode: phoneCountryCode,  phone: phone, code: code, completion: completion)
                    } else {
                        completion(statuCode, message, nil)
                    }
                }
            } else {
                completion(500, "Cannot get config. app id:\(Authing.getAppId())", nil)
            }
        }
    }
    
    public func loginByEmail(email: String, code: String, completion: @escaping(Int, String?, UserInfo?) -> Void) {
        Authing.getConfig { config in
            if let conf = config{
                self.prepareLogin(config: conf) { statuCode, message, authRequest in
                    if statuCode == 200{
                        AuthClient().loginByEmail(authData: authRequest, email: email, code: code, completion: completion)
                    } else {
                        completion(statuCode, message, nil)
                    }
                }
            } else {
                completion(500, "Cannot get config. app id:\(Authing.getAppId())", nil)
            }
        }
    }
    
    public func loginByWechat(_ code: String, completion: @escaping(Int, String?, UserInfo?) -> Void) {
        Authing.getConfig { config in
            if let conf = config{
                self.prepareLogin(config: conf) { statuCode, message, authRequest in
                    if statuCode == 200{
                        AuthClient().loginByWechat(authData: authRequest, code, completion: completion)
                    } else {
                        completion(statuCode, message, nil)
                    }
                }
            } else {
                completion(500, "Cannot get config. app id:\(Authing.getAppId())", nil)
            }
        }
    }
        
    public func getUserInfoByAccessToken(userInfo: UserInfo?, completion: @escaping(Int, String?, UserInfo?) -> Void) {
        request(userInfo: userInfo, endPoint: "/oidc/me", method: "GET", body: nil) { code, message, data in
            AuthClient().createUserInfo(userInfo, code, message, data, completion: completion)
        }
    }
    
    public func getNewAccessTokenByRefreshToken(userInfo: UserInfo?, completion: @escaping(Int, String?, UserInfo?) -> Void) {
        let rt = userInfo?.refreshToken ?? ""
        let body = "client_id=" + Authing.getAppId() + "&grant_type=refresh_token" + "&refresh_token=" + rt;
        request(userInfo: nil, endPoint: "/oidc/token", method: "POST", body: body) { code, message, data in
            if (code == 200) {
                AuthClient().createUserInfo(userInfo, code, message, data, completion: completion)
            } else {
                completion(code, message, nil)
            }
        }
    }
    
    public func authorize(userInfo: UserInfo, completion: @escaping(Int, String?, UserInfo?) -> Void) {
        Authing.getConfig { config in
            if let conf = config {
                self.prepareLogin(config: conf) { code, message, authRequest in
                    if code == 200 {
                        authRequest?.token = userInfo.token
                        self.oidcInteraction(completion: completion)
                    } else {
                        completion(code, message, nil)
                    }
                }
            } else {
                completion(500, "Cannot get config. app id:\(Authing.getAppId())", nil)
            }
        }
    }
    
    public func oidcInteraction(completion: @escaping(Int, String?, UserInfo?) -> Void) {
        Authing.getConfig { config in
            if let conf = config {
                let url = "\(Authing.getSchema())://\(Util.getHost(conf))/interaction/oidc/\(self.authRequest.uuid!)/login"
                let body = "token=" + self.authRequest.token!
                self._oidcInteraction(url: url, body: body, completion: completion)
            }else {
                completion(500, "Cannot get config. app id:\(Authing.getAppId())", nil)
            }
        }
    }
    
    private func _oidcInteraction(url: String, body: String, completion: @escaping(Int, String?, UserInfo?) -> Void) {
    
        var request = URLRequest(url: URL(string: url)!)
        request.httpMethod = "POST"
        request.setValue("application/x-www-form-urlencoded; charset=utf-8", forHTTPHeaderField: "Content-Type")
        request.httpBody = body.data(using: .utf8)
        
        let session = URLSession.init(configuration: URLSessionConfiguration.default, delegate: OIDCClient(), delegateQueue: nil)
        session.dataTask(with: request) { (data, response, error) in
            guard error == nil else {
                completion(500, "network error \(url) \n\(error!)", nil)
                return
            }
            
            let httpResponse = response as? HTTPURLResponse
            let statusCode: Int = httpResponse?.statusCode ?? 0
            if statusCode == 302{
                let location: String = httpResponse?.allHeaderFields["Location"] as? String ?? ""
                self.oidcLogin(url: location, completion: completion)
            } else {
                completion(statusCode, String(decoding: data!, as: UTF8.self), nil)
            }
        }.resume()
    }

    public func oidcLogin(url: String, completion: @escaping(Int, String?, UserInfo?) -> Void) {
        
        var request = URLRequest(url: URL(string: url)!)
        request.httpMethod = "GET"
        
        let session = URLSession.init(configuration: URLSessionConfiguration.default, delegate: OIDCClient(), delegateQueue: nil)
        session.dataTask(with: request) { (data, response, error) in
            guard error == nil else {
                completion(500, "network error \(url) \n\(error!)", nil)
                return
            }
            
            let httpResponse = response as? HTTPURLResponse
            let statusCode: Int = httpResponse?.statusCode ?? 0
            if statusCode == 302{
                
                let location: String = httpResponse?.allHeaderFields["Location"] as? String ?? ""
                let authCode = Util.getQueryStringParameter(url: URL.init(string: location)!, param: "code")
                if authCode != nil{
                    if self.authRequest.returnAuthorizationCode == true {
                        let userInfo = UserInfo.init()
                        userInfo.authorizationCode = authCode
                        completion(200, "Get authorization code success", userInfo)
                        return
                    }
                    self.authByCode(code: authCode!, completion: completion)
                } else if URL(string: location)?.lastPathComponent == "authz" {
                    if let scheme = request.url?.scheme, let host = request.url?.host, let uuid = self.authRequest.uuid{
                        let requsetUrl = "\(scheme)://\(host)/interaction/oidc/\(uuid)/confirm"
                        self._oidcInteractionScopeConfirm(url: requsetUrl, completion: completion)
                    }
                } else {
                    let requsetUrl = (request.url?.scheme ?? "") + "://" + (request.url?.host ?? "") + location
                    self.oidcLogin(url: requsetUrl, completion: completion)
                }
                
            } else {
                completion(statusCode, String(decoding: data!, as: UTF8.self), nil)
            }
        }.resume()
    }
    
    private func _oidcInteractionScopeConfirm(url: String, completion: @escaping(Int, String?, UserInfo?) -> Void) {
        var request = URLRequest(url: URL(string: url)!)
        request.httpMethod = "POST"
        request.setValue("application/x-www-form-urlencoded; charset=utf-8", forHTTPHeaderField: "Content-Type")
        let body = self.authRequest.getScopesAsConsentBody()
        request.httpBody = body.data(using: .utf8)

        let session = URLSession.init(configuration: URLSessionConfiguration.default, delegate: OIDCClient(), delegateQueue: nil)
        
        session.dataTask(with: request) { (data, response, error) in
            guard error == nil else {
                completion(500, "network error \(url) \n\(error!)", nil)
                return
            }
            
            let httpResponse = response as? HTTPURLResponse
            let statusCode: Int = httpResponse?.statusCode ?? 0
            if statusCode == 302{
                let location: String = httpResponse?.allHeaderFields["Location"] as? String ?? ""
                self.oidcLogin(url: location, completion: completion)
            } else {
                completion(statusCode, String(decoding: data!, as: UTF8.self), nil)
            }
        }.resume()
    }
            
    public func request(userInfo: UserInfo?, endPoint: String, method: String, body: String?, completion: @escaping (Int, String?, NSDictionary?) -> Void) {
        Authing.getConfig { config in
            if (config != nil) {
                let urlString: String = "\(Authing.getSchema())://\(Util.getHost(config!))\(endPoint)"
                self._request(userInfo: userInfo, config: config, urlString: urlString, method: method, body: body, completion: completion)
            } else {
                completion(500, "Cannot get config. app id:\(Authing.getAppId())", nil)
            }
        }
    }
    
    private func _request(userInfo: UserInfo?, config: Config?, urlString: String, method: String, body: String?, completion: @escaping (Int, String?, NSDictionary?) -> Void) {
        let url = URL(string: urlString)
        var request = URLRequest(url: url!)
        request.httpMethod = method
        request.setValue("application/x-www-form-urlencoded; charset=utf-8", forHTTPHeaderField: "Content-Type")
        if body != nil {
            request.httpBody = body!.data(using: .utf8)
        }
        if let currentUser = userInfo {
            if let at = currentUser.accessToken {
                request.addValue("Bearer \(at)", forHTTPHeaderField: "Authorization")
            }
        }
        
        
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            guard error == nil else {
                completion(500, "network error \(url!) \n\(error!)", nil)
                return
            }
            
            let httpResponse = response as? HTTPURLResponse
            let statusCode: Int = (httpResponse?.statusCode)!
            
            if (data != nil) {
                if let jsonData = try? JSONSerialization.jsonObject(with: data!, options: .allowFragments) {
                    completion(statusCode, "", jsonData as? NSDictionary)
                } else {
                    completion(statusCode, String(decoding: data!, as: UTF8.self), nil)
                }
            } else {
                completion(statusCode, "", nil)
            }
        }.resume()
    }
}

//MARK: ---------- URLSessionTaskDelegate ----------
extension OIDCClient: URLSessionTaskDelegate{
    
    public func urlSession(_ session: URLSession, task: URLSessionTask, willPerformHTTPRedirection response: HTTPURLResponse, newRequest request: URLRequest, completionHandler: @escaping (URLRequest?) -> Void) {
        completionHandler(nil)
    }
}

