//
//  ViewController.swift
//  GoGoGitHub
//
//  Created by Michael Sweeney on 6/27/16.
//  Copyright © 2016 Michael Sweeney. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBAction func requestToken(sender: AnyObject) {
        
        GitHubOAuth.shared.oAuthRequestWith(["scope": "email,user"])
        
    }
    
    @IBAction func printToken(sender: AnyObject) {
        do {
            let token = try GitHubOAuth.shared.checkDefaultsForAccessToken()
            print(token)
            
        } catch let error {
            print(error)
        }
        
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

