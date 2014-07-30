//
//  AppDelegate.swift
//  RemoteMouseMac
//
//  Created by Boyko Andrey on 7/30/14.
//  Copyright (c) 2014 LOL. All rights reserved.
//

import Cocoa

class AppDelegate: NSObject, NSApplicationDelegate {
                            
    @IBOutlet var window: NSWindow
    let networkHelper = NetworkHelper()
    var netService:NSNetService?;

    func applicationDidFinishLaunching(aNotification: NSNotification?) {
        // Insert code here to initialize your application
        netService = networkHelper.registerService(){
            (netService:NSNetService!, errorDict:[NSObject:AnyObject]?) in
                println (netService.name);
            };
    }

    func applicationWillTerminate(aNotification: NSNotification?) {
        // Insert code here to tear down your application
        networkHelper.stopService(netService!);
    }


}

