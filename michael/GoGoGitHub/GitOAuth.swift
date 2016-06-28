//
//  GitOAuth.swift
//  GoGoGitHub
//
//  Created by Michael Sweeney on 6/27/16.
//  Copyright © 2016 Michael Sweeney. All rights reserved.
//

import Foundation
import UIKit

let kAccessTokenKey = "kAccessTokenKey"
let kOAuthBaseUrl = "https://github.com/login/oauth/"
let kAccessTokenRegexPattern = "access_token=([^&]+)"

typealias GitHubOAuthCompletion = (success: Bool) -> ()

enum GitHubOAuthError : ErrorType {
    case MissingAccessToken(String)
    case ExtractingTokenFromString(String)
    case ExtractingTemporaryCode(String)
    case ResponseFromGitHub(String)
}

enum SaveOptions: Int {
    case userDefaults
    case keyChain
}

class GitHubOAuth {
    
    static let shared = GitHubOAuth()
    private init(){}
    
    func oAuthRequestWith(params: [String: String]) {
        var parameterString = String()
        
        for parameter in params.values {
            
            parameterString = parameterString.stringByAppendingString(parameter)
            print(parameter)
            
        }
        
        if let requestURL = NSURL(string: "\(kOAuthBaseUrl)authorize?client_id=\(kGithubClientID)&scope=\(parameterString)") {
            print(requestURL)
            
            UIApplication.sharedApplication().openURL(requestURL)
        }
    }
    
    func temporaryCodeFromCallback(url: NSURL) throws -> String {
        print("Callback URL: \(url.absoluteString)")
        guard let temporaryCode = url.absoluteString.componentsSeparatedByString("=").last else {
            throw GitHubOAuthError.ExtractingTemporaryCode("Could not extract code from callback")
        }
        
        print("Temp code: \(temporaryCode)")
        return temporaryCode
    }
    
    func stringWith(data: NSData) -> String? {
        let byteBuffer : UnsafeBufferPointer = UnsafeBufferPointer(start: UnsafeMutablePointer<UInt8>(data.bytes), count: data.length)
        let result = String(bytes: byteBuffer, encoding: NSASCIIStringEncoding)
        return result
    }
    
    func accessTokenFromString(string: String) throws -> String? {
        do{
            let regex = try NSRegularExpression(pattern: kAccessTokenRegexPattern, options: NSRegularExpressionOptions.CaseInsensitive)
            
            let matches = regex.matchesInString(string, options: .Anchored, range: NSMakeRange(0, string.characters.count))
            
            if matches.count > 0 {
                for (_, value) in matches.enumerate() {
                    print("Match range: \(value)")
                    let matchRange = value.rangeAtIndex(1)
                    return (string as NSString).substringWithRange(matchRange)
                }
            }
            
        } catch {
            throw GitHubOAuthError.ExtractingTokenFromString("Could not extract token from string")
        }
        
        return nil
    }
    
    
    //MARK: Saving
    func saveAccessTokenToUserDefaults(accessToken: String) -> Bool {
        NSUserDefaults.standardUserDefaults().setObject(accessToken, forKey: kAccessTokenKey)
        return NSUserDefaults.standardUserDefaults().synchronize()
    }
    
    func tokenRequestWithCallback(url: NSURL, options: SaveOptions, completion: GitHubOAuthCompletion)
    {
        
        func returnOnMain(success: Bool, _ completion: GitHubOAuthCompletion) {
            NSOperationQueue.mainQueue().addOperationWithBlock {
                completion(success: success)
            }
        }
        
        
        do {
            let temporaryCode = try self.temporaryCodeFromCallback(url)
            
            let requestString = "\(kOAuthBaseUrl)access_token?client_id=\(kGithubClientID)&client_secret=\(kGithubClientSecret)&code=\(temporaryCode)"
            
            if let requestURL = NSURL(string: requestString)
            {
                let sessionConfiguration = NSURLSessionConfiguration.defaultSessionConfiguration()
                
                let session = NSURLSession(configuration: sessionConfiguration)
                session.dataTaskWithURL(requestURL, completionHandler: {(data, response, error) in
                    
                    if let _ = error{
                        returnOnMain(false, completion); return
                    }
                    
                    if let data = data{
                        if let tokenString = self.stringWith(data){
                            
                            do {
                                if let token = try self.accessTokenFromString(tokenString) {
                                    
                                    switch options {
                                    case .userDefaults: returnOnMain(self.saveAccessTokenToUserDefaults(token), completion)
                                    case .keyChain: returnOnMain(self.saveToKeyChain(token), completion)
                                    }
                                }
                                
                            } catch
                            {
                                returnOnMain(false, completion)
                            }
                            
                        }
                    }
                    
                }).resume()
                
            }
            
        } catch{
            returnOnMain(false, completion)
        }
    }
    
    func checkDefaultsForAccessToken() throws -> String?
    {
        var query = self.keyChainQuery(kAccessTokenKey)
        query[(kSecReturnData as String)] = kCFBooleanTrue
        query[(kSecMatchLimit as String)] = kSecMatchLimitOne
        
        var dataRef: AnyObject?
        
        if SecItemCopyMatching(query, &dataRef) == errSecSuccess {
            if let data = dataRef as? NSData {
                if let token = NSKeyedUnarchiver.unarchiveObjectWithData(data) as? String {
                    return token
                }
            }
            
        }
            
        else{
            guard let accessToken = NSUserDefaults.standardUserDefaults().stringForKey(kAccessTokenKey) else {
                throw GitHubOAuthError.MissingAccessToken("there is no access token saved")
            }
            return accessToken
            
        }
        return nil
    }
    
    private func saveToKeyChain(token: String) -> Bool {
        
        var query = self.keyChainQuery(kAccessTokenKey)
        query[(kSecValueData as String)] = NSKeyedArchiver.archivedDataWithRootObject(token)
        SecItemDelete(query)
        
        return SecItemAdd(query, nil) == errSecSuccess
    }
    
    private func keyChainQuery(query: String) -> [String : AnyObject]{
        
        return [
            (kSecClass as String) : kSecClassGenericPassword,
            (kSecAttrService as String) : query,
            (kSecAttrAccount as String) : query,
            (kSecAttrAccessible as String) : kSecAttrAccessibleAfterFirstUnlock
        ]
    }
}
