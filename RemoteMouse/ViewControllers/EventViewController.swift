//
//  EventViewController.swift
//  RemoteMouse
//
//  Created by Boyko Andrey on 7/31/14.
//  Copyright (c) 2014 LOL. All rights reserved.
//

import UIKit

class EventViewController: UIViewController {
    
    var outputStream:NSOutputStream?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func pressUp(sender: AnyObject) {
        sendMouseMoveEvent(Point(v: 10, h: 0))
    }

    @IBAction func pressLeft(sender: AnyObject) {
        sendMouseMoveEvent(Point(v: 0, h: -10))
    }
    
    @IBAction func pressRight(sender: AnyObject) {
        sendMouseMoveEvent(Point(v: 0, h: 10))
    }
    
    @IBAction func pressDown(sender: AnyObject) {
        sendMouseMoveEvent(Point(v: -10, h: 0))
    }
    
//
// #pragma mark - Navigation
//
    func sendMouseMoveEvent (diff:Point){
        if let stream = self.outputStream{
            
           var byteData:[UInt8] = [UInt8(diff.v+128),UInt8(diff.h+128)]
            if  let stream = self.outputStream{
                stream.write(byteData, maxLength: sizeof(UInt8)*byteData.count);
            }
          
        }
    }
    
    /*
- (void)simulateMouseEvent:(CGEventType)eventType
{
// Get the current mouse position
CGEventRef ourEvent = CGEventCreate(NULL);
CGPoint mouseLocation = CGEventGetLocation(ourEvent);

// Create and post the event
CGEventRef event = CGEventCreateMouseEvent(CGEventSourceCreate(kCGEventSourceStateHIDSystemState), eventType, mouseLocation, kCGMouseButtonLeft);
CGEventPost(kCGHIDEventTap, event);
CFRelease(event);
}
*/

}
