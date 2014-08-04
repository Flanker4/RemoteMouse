//
//  AppDelegate.swift
//  RemoteMouseMac
//
//  Created by Boyko Andrey on 7/30/14.
//  Copyright (c) 2014 LOL. All rights reserved.
//

import Cocoa

class AppDelegate: NSObject, NSApplicationDelegate ,QServerDelegate{
    //
    // MARK: - var
    //
    @IBOutlet var window: NSWindow
    @lazy let networkHelper = NetworkHelper()
    @lazy let server        = QServer(domain:BonjourDomain, type:BonjourType, name:BonjourName, preferredPort:0);
   
    //
    // MARK: - func
    //
    func applicationDidFinishLaunching(aNotification: NSNotification?) {
        // Insert code here to initialize your application
        self.server.delegate = self
        self.server.start()

        
    }

    func applicationWillTerminate(aNotification: NSNotification?) {
        // Insert code here to tear down your application
        self.networkHelper.closeStreams()
        self.server.stop()
        self.server.deregister()
        
    }

    ///
    /// Mark: QServer delegate
    ///
    func server(server: QServer!, connectionForInputStream inputStream: NSInputStream!, outputStream: NSOutputStream!) -> AnyObject! {
        if  (networkHelper.hasConnection){
            return nil;
        }
        
        self.server.deregister()
        
        networkHelper.openStreams([inputStream,outputStream])
        networkHelper.readerCallback = { (mouseEvent:MouseEvent, diff:Point) in
            switch mouseEvent{
            case .Move:
                var point:CGPoint  = NSEvent.mouseLocation()
                point.y = NSScreen.mainScreen().frame.size.height - point.y
                point.y+=CGFloat(diff.v)
                point.x+=CGFloat(diff.h)
                CGWarpMouseCursorPosition(point);
            case .Tap:
                self.simulateMouseClick()
            }
            
        }
        return self
    }
    
    func serverDidStart(server: QServer!) {
        println (server.name)
    }

    ///
    /// Mark: Utils
    ///
    func simulateMouseEvent(eventType:CGEventType){
        let ourEvent = CGEventCreate(nil)
        
        let mouseLocation = CGEventGetLocation(ourEvent.takeRetainedValue())
        let event = CGEventCreateMouseEvent(CGEventSourceCreate(CGEventSourceStateID(kCGEventSourceStateHIDSystemState)).takeRetainedValue(), eventType, mouseLocation,  CGMouseButton(kCGMouseButtonLeft) );
        CGEventPost(CGEventTapLocation(kCGHIDEventTap), event.takeRetainedValue());
    }
    
    func simulateMouseClick(clickCount:Int=1 , completion:(() -> Void)?=nil){
        self.simulateMouseEvent(kCGEventLeftMouseDown)
        
        let delay = 0.2 * Double(NSEC_PER_SEC)
        let time = dispatch_time(DISPATCH_TIME_NOW, Int64(delay))
        dispatch_after(time, dispatch_get_main_queue(), {
            self.simulateMouseEvent(kCGEventLeftMouseUp)
            if  clickCount==1{
                if  let comp= completion{
                    comp()
                }
            }else{
                self.simulateMouseClick(clickCount: clickCount-1, completion: completion)
            }
        })
    }
    


}

