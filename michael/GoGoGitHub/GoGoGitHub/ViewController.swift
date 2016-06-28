//
//  ViewController.swift
//  GoGoGitHub
//
//  Created by Michael Sweeney on 6/27/16.
//  Copyright © 2016 Michael Sweeney. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var loginButton: UIButton!
    
        @IBAction func requestToken(sender: AnyObject) {
    
            GitHubOAuth.shared.oAuthRequestWith(["scope": "email,user,repo"])
    
        }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setup()
        self.setupAppearance()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}

extension ViewController: Setup {
    //MARK: Setup
    
    func setup() {
        self.title = "Repositories"
    }
    
    func setupAppearance() {
        //makes button have rounded corners!
        self.loginButton.layer.cornerRadius = 3.0
    }
    
}

