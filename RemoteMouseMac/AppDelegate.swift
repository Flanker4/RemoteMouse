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
        netService = networkHelper.registerService(registrationCompletion: {
                (netService:NSNetService!, errorDict:[NSObject:AnyObject]?)->Void in
                    println (netService.name)
            },
                clientDidConnectCompletion: {
                (inputSteam:NSInputStream,outputStream:NSOutputStream) ->Void in
                    
                    var byteData:[UInt8] = [4]
                    outputStream.write(byteData, maxLength: sizeof(UInt8));
                   
            })
       
        
    }

    func applicationWillTerminate(aNotification: NSNotification?) {
        // Insert code here to tear down your application
        networkHelper.stopService(netService!);
    }


}

