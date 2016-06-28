//
//  HomeViewController.swift
//  GoGoGitHub
//
//  Created by Michael Sweeney on 6/28/16.
//  Copyright © 2016 Michael Sweeney. All rights reserved.
//

import UIKit

class HomeViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
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
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        API.shared.GETRepositories { (repositories) in
            if let data = repositories {
                self.repositories = data
            }
        }
    }
    
}

extension HomeViewController : UITableViewDataSource
{
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print(self.repositories.count)
        return self.repositories.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let repositoryCell = tableView.dequeueReusableCellWithIdentifier("repositoryCell", forIndexPath: indexPath)
        let repository = self.repositories[indexPath.row]
        repositoryCell.textLabel?.text = repository.name
        return repositoryCell
    }
}
