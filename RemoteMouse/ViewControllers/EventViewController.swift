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
    var prevPanPosition = CGPointZero
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func pressTap(sender: AnyObject) {
        self.sendMouseTap(1)
    }
    
    
    @IBAction func didPan(sender: UIPanGestureRecognizer) {
        
        
        switch (sender.state){
        case .Began:
                self.prevPanPosition = sender.locationInView(self.view)
        case .Ended:
                self.prevPanPosition = CGPointZero
        default:
                var p = sender.locationInView(self.view)
                p.x = p.x - self.prevPanPosition.x
                p.y = p.y - self.prevPanPosition.y
                var point = Point(v: Int16(p.y), h: Int16(p.x))
                self.sendMouseMoveEvent(point)
                self.prevPanPosition = sender.locationInView(self.view);
                println(point)
        }
       
    }
    
    @IBAction func pressDoubleTap(sender: AnyObject) {
        self.sendMouseTap(2)
    }
    
//
// #pragma mark - Navigation
//
    func sendMouseMoveEvent (var diff:Point){
        if let stream = self.outputStream{
            
            
            diff.v = min(diff.v, 127)
            
            diff.h = min(diff.h, 127)
            
            diff.v = max(diff.v, -127)
            diff.h = max(diff.h, -127)
            
            var byteData:[UInt8] = [ServerEvent.MouseMove.toRaw(), UInt8(diff.v+128), UInt8(diff.h+128)]
            if  let stream = self.outputStream{
                stream.write(byteData, maxLength: sizeof(UInt8)*byteData.count);
            }
          
        }
    }
    
    func sendMouseTap (tapCount:UInt8){
        var byteData:[UInt8] = [ServerEvent.MouseTap.toRaw(), tapCount]
        if  let stream = self.outputStream{
            stream.write(byteData, maxLength: sizeof(UInt8)*byteData.count);
        }
    }
}
