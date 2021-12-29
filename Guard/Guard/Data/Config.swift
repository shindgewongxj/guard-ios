//
//  Config.swift
//  Guard
//
//  Created by Lance Mao on 2021/12/13.
//

import Foundation

public class Config {
    var userPoolId: String?
    var identifier: String?
    var name: String?
    var logo: String?
    var userpoolLogo: String?
    var loginMethods: [String]?
    var defaultLoginMethod: String?
    var enabledLoginMethods: [String]?
    var registerMethods: [String]?
    var defaultRegisterMethod: String?
    
    public static func parse(data: NSDictionary?) -> Config? {
        guard data != nil else {
            return nil
        }
        let config: Config = Config()
        config.userPoolId = data!["userPoolId"] as? String
        config.identifier = data!["identifier"] as? String
        config.name = data!["name"] as? String
        config.logo = data!["logo"] as? String
        config.userpoolLogo = data!["userpoolLogo"] as? String
        let loginTabs: NSDictionary? = data!["loginTabs"] as? NSDictionary
        if (loginTabs != nil) {
            config.loginMethods = loginTabs!["list"] as? [String]
            config.defaultLoginMethod = loginTabs!["default"] as? String
            var i: Int = 0
            config.loginMethods?.forEach({ method in
                if (method == config.defaultLoginMethod) {
                    config.loginMethods?.remove(at: i)
                    config.loginMethods?.insert(method, at: 0)
                    return
                }
                i+=1
            })
        }
        let passwordTabConfig: NSDictionary? = data!["passwordTabConfig"] as? NSDictionary
        if (passwordTabConfig != nil) {
            config.enabledLoginMethods = passwordTabConfig?["enabledLoginMethods"] as? [String]
        }
        let registerTabs: NSDictionary? = data!["registerTabs"] as? NSDictionary
        if (registerTabs != nil) {
            config.registerMethods = registerTabs!["list"] as? [String]
            config.defaultRegisterMethod = registerTabs!["default"] as? String
            var i: Int = 0
            config.registerMethods?.forEach({ method in
                if (method == config.defaultRegisterMethod) {
                    config.registerMethods?.remove(at: i)
                    config.registerMethods?.insert(method, at: 0)
                    return
                }
                i+=1
            })
        }
        return config
    }
    
    public func getLogoUrl() -> String? {
        return logo ?? userpoolLogo
    }
}
