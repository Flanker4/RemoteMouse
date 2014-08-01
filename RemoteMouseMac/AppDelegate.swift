//
//  AppDelegate.swift
//  RemoteMouseMac
//
//  Created by Boyko Andrey on 7/30/14.
//  Copyright (c) 2014 LOL. All rights reserved.
//

import Cocoa

class AppDelegate: NSObject, NSApplicationDelegate ,QServerDelegate{
    @IBOutlet var window: NSWindow
    let networkHelper = NetworkHelper()
    var server:QServer?
    
    var netService:NSNetService?;

    func applicationDidFinishLaunching(aNotification: NSNotification?) {
        // Insert code here to initialize your application
        self.server = QServer(domain:BonjourDomain, type:BonjourType, name:BonjourName, preferredPort:0);
        self.server!.delegate = self
        self.server!.start()

        
    }

    func applicationWillTerminate(aNotification: NSNotification?) {
        // Insert code here to tear down your application
        networkHelper.stopService(netService!);
    }

    func server(server: QServer!, connectionForInputStream inputStream: NSInputStream!, outputStream: NSOutputStream!) -> AnyObject! {
        networkHelper.openStreams([inputStream,outputStream], setDelegate: true)
        networkHelper.readerCallback = { (diff:Point) in
            
            var point:CGPoint  = NSEvent.mouseLocation()
            point.y = NSScreen.mainScreen().frame.size.height - point.y
            point.y-=CGFloat(diff.v)
            point.x+=CGFloat(diff.h)
            CGWarpMouseCursorPosition(point);
            
        }
        return self
    }
    
    func serverDidStart(server: QServer!) {
         println (server.name)
    }

    


}

