//
//  AppDelegate.swift
//  GoGoGitHub
//
//  Created by Michael Sweeney on 6/27/16.
//  Copyright © 2016 Michael Sweeney. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    var oauthViewController: ViewController?
    var homeViewController: HomeViewController?
    
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        self.checkOAuthStatus()
        return true
    }
    
    func application(application: UIApplication, openURL url: NSURL, sourceApplication: String?, annotation: AnyObject) -> Bool {
        print("AppDelegate - OpenURL func URL: \(url)")
        
        GitHubOAuth.shared.tokenRequestWithCallback(url, options: SaveOptions.userDefaults) { (success) in
            print("we have a token")
            if let oauthViewController = self.oauthViewController {
                UIView.animateWithDuration(0.4, delay: 1.0, options:
                    .CurveEaseInOut, animations: {
                        self.homeViewController?.navigationController?.navigationBarHidden = false
                        oauthViewController.view.alpha = 0.0
                    }, completion: { (finished) in
                        oauthViewController.view.removeFromSuperview()
                        oauthViewController.removeFromParentViewController()
                        
                        API.shared.getToken()
                        self.checkOAuthStatus()
                        if let homeView =  self.window?.rootViewController as? HomeViewController {
                            homeView.setup()
                        }
                })
            }
            //animate with durarion
            
        }
        
        return true
        
    }
    
    func checkOAuthStatus(){
        do {
            let token = try GitHubOAuth.shared.checkDefaultsForAccessToken()
            print(token)
            
            
        } catch { self.presentOAuthViewController()}
        
    }
    
    func presentOAuthViewController(){
        
        guard let navigationController = self.window?.rootViewController as? UINavigationController else{
            fatalError("Check your root view controller") }
        navigationController.navigationBar.hidden = true

        guard let HomeViewController = navigationController.viewControllers.first as? HomeViewController else { fatalError("Home VC?")}
        
        guard let storyboard = HomeViewController.storyboard else {
            fatalError("Check for storyboard")
        }
        
        guard let ViewController = storyboard.instantiateViewControllerWithIdentifier(ViewController.id) as? ViewController else {
            fatalError("check scene identifier")
        }
        
        //3 steps to present a view over another view
        HomeViewController.addChildViewController(ViewController)
        HomeViewController.view.addSubview(ViewController.view)
        ViewController.didMoveToParentViewController(HomeViewController)
        
        self.oauthViewController = ViewController
        self.homeViewController = HomeViewController
        
        
    }
}

