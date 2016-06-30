//
//  User.swift
//  GoGoGitHub
//
//  Created by Michael Sweeney on 6/29/16.
//  Copyright © 2016 Michael Sweeney. All rights reserved.
//

import Foundation


struct User
{
    let name: String
    let login: String
    let location: String?
    let blog: String?
    let createdAt: NSDate
    let followers: Int
    
    init?(json: [String : AnyObject])
    {
        if let name = json["name"] as? String, login = json["login"] as? String, followers = json["followers"] as? Int {
            
            let createdAt = NSDate.dateFromString(json["created_at"] as! String)
            let location = json["location"] as? String
            let blog = json["blog"] as? String
            
            self.name = name
            self.login = login
            self.location = location
            self.blog = blog
            self.createdAt = createdAt
            self.followers = followers
        }
            
        else {
            print("issue creating user")
            return nil
        }
    }
}