//
//  ProfileViewController.swift
//  GoGoGitHub
//
//  Created by Michael Sweeney on 6/29/16.
//  Copyright © 2016 Michael Sweeney. All rights reserved.
//

import UIKit

protocol ProfileViewControllerDelegate: class {
    
    func profileViewControllerDidFinish()
}


class ProfileViewController: UIViewController, Setup {
    
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    
    weak var delegate: ProfileViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupAppearance()
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        setup()
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    //MARK: Setup
    
    func setup() {
        API.shared.GETUser { (user) in
            print(user?.name)
            if let user = user {
                self.nameLabel.text = user.name
                self.locationLabel.text = user.location
            }
            
        }
        
    }
    
    func setupAppearance() {
        self.closeButton.layer.cornerRadius = 3.0
    }
    
    
    @IBAction func closeButtonSelected(sender: UIButton) {
        
        self.delegate?.profileViewControllerDidFinish()
    }
    
}
