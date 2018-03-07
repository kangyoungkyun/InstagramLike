//
//  AppDelegate.swift
//  InstagramLike
//
//  Created by MacBookPro on 2018. 3. 5..
//  Copyright © 2018년 MacBookPro. All rights reserved.
//

import UIKit
import Firebase
@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    

    //인디케이터 객체
    var actIdc = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)
    var container: UIView!
    
     //AppDelegate 객체
    class func instance() -> AppDelegate {
        return UIApplication.shared.delegate as! AppDelegate
    }
    
    
    //인디케이터 시작
    func showActivityIndicator(){
        if let window = window{
            print("showActivityIndicator 인디케이터 호출")
            container = UIView()
            container.frame = window.frame
            container.center = window.center
            container.backgroundColor = UIColor(white:0, alpha:0.2)
            //actIdc.color = UIColor.black
            actIdc.frame = CGRect(x: 0 , y: 0, width:40, height:40)
            actIdc.hidesWhenStopped = true
            actIdc.center = CGPoint(x: container.frame.size.width / 2, y: container.frame.size.height / 2)
            container.addSubview(actIdc)
            window.addSubview(container)
            
            actIdc.startAnimating()
        }
    }
    
    //인디케이터 삭제
    func dissmissActivityIndicator(){
        if let _ = window{
            print("dissmiss 인디케이터 호출")
            container.removeFromSuperview()
        }
    }

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        FirebaseApp.configure()
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

