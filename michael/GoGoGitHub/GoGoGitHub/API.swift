//
//  API.swift
//  GoGoGitHub
//
//  Created by Michael Sweeney on 6/28/16.
//  Copyright © 2016 Michael Sweeney. All rights reserved.
//

import Foundation


class API
{
    static let shared = API()
    
    private let session: NSURLSession
    private let template: NSURLComponents
    
    private init() {
        self.session = NSURLSession(configuration: .defaultSessionConfiguration())
        self.template = NSURLComponents()
        self.configure()
    }
    
    private func configure(){
        
        
        self.template.scheme = "https"
        self.template.host = "api.github.com"
        getToken()
    }
    
    func getToken(){
        do {
            if let token = try GitHubOAuth.shared.checkDefaultsForAccessToken() {
                self.template.queryItems = [NSURLQueryItem(name: "access_token", value: token)]
            }
        } catch {
            
        }
        
    }
    
    func GETRepositories(completion: (repositories: [Repository]?) -> ()){
        
        self.template.path = "/user/repos"
        self.session.dataTaskWithURL(self.template.URL!) { (data, response, error) in
            
            if let error = error {
                print(error)
            }
            
            if let data = data {
                //                print(data)
                do {
                    if let json = try NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions()) as? [[String: AnyObject]] {
                        //                        print(json)
                        
                        var repositories = [Repository]()
                        for repositoryJSON in json {
                            if let repository = Repository(json: repositoryJSON) {
                                repositories.append(repository)
                            }
                        }
                        NSOperationQueue.mainQueue().addOperationWithBlock({
                            completion(repositories: repositories)
                        })
                        
                    }
                } catch {
                    print(error)
                }
            }
            
            
            }.resume()
    }
    
    func GETUser(completion: (user: User?) -> ())
    {
        self.template.path = "/user"
        self.session.dataTaskWithURL(self.template.URL!) { (data, response, error) in
            
            if let error = error {
                print(error)
            }
            
            if let data = data {
                do {
                    
                    if let json = try NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions()) as? [String : AnyObject] {
                        
                        let user = User(json: json)
                        print("this is my user \(user)")
                        
                        NSOperationQueue.mainQueue().addOperationWithBlock({
                            completion(user: user)
                        })
                    }
                }
                    
                catch {
                    print(error)
                }
            }
            
            }.resume()
    }
    
    func POSTRepository(name: String, completion: (success: Bool) -> ()){
        self.template.path = "user/repos"
        
        let request = NSMutableURLRequest(URL: self.template.URL!)
        request.HTTPMethod = "POST"
        
        request.HTTPBody = try? NSJSONSerialization.dataWithJSONObject(["name": name], options: .PrettyPrinted)
        
        let task = self.session.dataTaskWithRequest(request) { (data, response, error) in
            if let response = response as? NSHTTPURLResponse {
                //
                switch response.statusCode {
                case 200...299:
                    dispatch_async(dispatch_get_main_queue(), {
                        completion(success: true)
                    })
                    
                default:
                    dispatch_async(dispatch_get_main_queue(), {
                        completion(success: false)
                    })
                }
            }
        }
        task.resume()
    }
    
    
    
}










