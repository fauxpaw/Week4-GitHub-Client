//
//  HomeViewController.swift
//  GoGoGitHub
//
//  Created by Michael Sweeney on 6/28/16.
//  Copyright © 2016 Michael Sweeney. All rights reserved.
//

import UIKit

class HomeViewController: UIViewController, Setup, UIViewControllerTransitioningDelegate{
    
    @IBAction func addButtonSelected(sender: AnyObject) {
        let controller = UIAlertController(title: "Create", message: "Please enter a name", preferredStyle: .Alert)
        let createAction = UIAlertAction(title: "Create", style: .Default) { (action) in
            //
            guard let textField = controller.textFields?.first else {return}
            if let text = textField.text {
                API.shared.POSTRepository(text, completion: { (success) in
                    print("repo created...")
                })
            }
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
        
        controller.addTextFieldWithConfigurationHandler(nil)
        controller.addAction(createAction)
        controller.addAction(cancelAction)
        
        self.presentViewController(controller, animated: true, completion: nil)
    }
    
    @IBOutlet weak var tableView: UITableView!
    
    lazy var transition = CustomModelTransition(duration: 2.0)
    
    var repositories = [Repository]() {
        didSet {
            self.tableView.reloadData()
        }
    }

    override func viewDidLoad()
    {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
    }
    
    func setupAppearance() {
        
    }
    
    func setup(){
        API.shared.GETRepositories { (repositories) in
            if let data = repositories {
                self.repositories = data
            }
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.setup()
        
    }
    
    func animationControllerForPresentedController(presented: UIViewController, presentingController presenting: UIViewController, sourceController source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return self.transition
    }
    
}

extension HomeViewController : UITableViewDataSource, ProfileViewControllerDelegate
{
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print(self.repositories.count)
        return self.repositories.count
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == ProfileViewController.id {
            if let profileViewController = segue.destinationViewController as? ProfileViewController {
                profileViewController.delegate = self
                profileViewController.transitioningDelegate = self
            }
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let repositoryCell = tableView.dequeueReusableCellWithIdentifier("repositoryCell", forIndexPath: indexPath)
        let repository = self.repositories[indexPath.row]
        repositoryCell.textLabel?.text = repository.name
        return repositoryCell
    }
    
    //MARK: ProfileViewControllerDelegate
    
    func profileViewControllerDidFinish() {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
}
