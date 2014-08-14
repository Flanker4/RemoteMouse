//
//  AppDelegate.swift
//  RemoteMouseMac
//
//  Created by Boyko Andrey on 7/30/14.
//  Copyright (c) 2014 LOL. All rights reserved.
//

import Cocoa

//➚
//HEAVY NORTH EAST ARROW
//Unicode: U+279A, UTF-8: E2 9E 9A
//⇲
//SOUTH EAST ARROW TO CORNER
//Unicode: U+21F2, UTF-8: E2 87 B2

class AppDelegate: NSObject, NSApplicationDelegate ,QServerDelegate{
    //
    // MARK: - var
    //
    @IBOutlet var window: NSWindow
    @lazy var networkHelper = NetworkHelper()
    @lazy var server        = QServer(domain:BonjourDomain, type:BonjourType, name:BonjourName, preferredPort:0);
    var statusItem: NSStatusItem?
    
    //UI
    @IBOutlet var menu:         NSMenu
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
        
        
           self.statusItem!.title          = "⥰"
        
    }
    ///
    /// Mark: UI
    ///
    @IBAction func menuQuit(sender: AnyObject) {
        NSApplication.sharedApplication().terminate(nil)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.statusItem = NSStatusBar.systemStatusBar().statusItemWithLength(-1)
        self.statusItem!.menu           = self.menu
        self.statusItem!.title          = "⥰"
        self.statusItem!.highlightMode  = true
    }
    ///
    /// Mark: QServer delegate
    ///
    func server(server: QServer!, connectionForInputStream inputStream: NSInputStream!, outputStream: NSOutputStream!) -> AnyObject! {
        if  (networkHelper.hasConnection){
            return nil;
        }
        
        self.server.deregister()
        self.statusItem!.title          = "⥹"
        networkHelper.openStreams([inputStream,outputStream])
        networkHelper.readerCallback = { (mouseEvent:ServerEvent, data:Int...) in
            switch mouseEvent{
            case .MouseMove:
                var point:CGPoint  = NSEvent.mouseLocation()
                point.y = NSScreen.mainScreen().frame.size.height - point.y
                point.y+=CGFloat(data[0])
                point.x+=CGFloat(data[1])
                CGWarpMouseCursorPosition(point);
            case .MouseTap:
                self.simulateMouseClick()
            case .DidCloseServer:
                self.applicationWillTerminate(nil)
                self.server.start()
            }
            
        }
        return self
    }
    
    func serverDidStart(server: QServer!) {
        println (server.name)
    }
    
    func server(server: QServer!, closeConnection connection: AnyObject!) {
        
    }
    
    func server(server: QServer!, didStopWithError error: NSError!) {
        
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
                if  let comp = completion{
                    comp()
                }
            }else{
                self.simulateMouseClick(clickCount: clickCount-1, completion: completion)
            }
        })
    }
    


}

