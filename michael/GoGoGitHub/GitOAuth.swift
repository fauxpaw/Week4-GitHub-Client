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
    
    func saveAccessTokenToUserDefaults(accessToken: String) -> Bool {
        NSUserDefaults.standardUserDefaults().setObject(accessToken, forKey: kAccessTokenKey)
        return NSUserDefaults.standardUserDefaults().synchronize()
    }
    
    func tokenRequestWithCallback(url: NSURL, options: SaveOptions, completion: GitHubOAuthCompletion){
        
        do {
            let temporaryCode = try self.temporaryCodeFromCallback(url)
            let requestString = "\(kOAuthBaseUrl)access_token?client_id=\(kGithubClientID)&client_secret=\(kGithubClientSecret)&code=\(temporaryCode)"
            if let requestURL = NSURL(string: requestString) {
                let sessionConfiguration = NSURLSessionConfiguration.defaultSessionConfiguration()

                let session = NSURLSession(configuration: sessionConfiguration)
                session.dataTaskWithURL(requestURL, completionHandler: {(data, response, error) in
                    
                    if let _ = error{
                        NSOperationQueue.mainQueue().addOperationWithBlock({ 
                            completion(success: false); return
                        })
                    }
                    
                    if let data = data{
                        if let tokenString = self.stringWith(data){
                            
                            do {
                                if let token = try self.accessTokenFromString(tokenString) {
                                    NSOperationQueue.mainQueue().addOperationWithBlock({ 
                                        completion(success: self.saveAccessTokenToUserDefaults(token))
                                    })
                                }
                                
                            } catch {
                                NSOperationQueue.mainQueue().addOperationWithBlock({ 
                                    completion(success: false)
                                })
                            }
                            
                        }
                    }
                    
                }).resume()
                
            }
            
        } catch{
            NSOperationQueue.mainQueue().addOperationWithBlock({ 
                completion(success: false)
            })
        }
    }
    func checkDefaultsForAccessToken() throws -> String? {
        guard let accessToken = NSUserDefaults.standardUserDefaults().stringForKey(kAccessTokenKey) else {
            throw GitHubOAuthError.MissingAccessToken("there is no access token saved")
        }
        return accessToken
    }
    
}
