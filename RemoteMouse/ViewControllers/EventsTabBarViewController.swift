
//
//  EventsTabBarViewController.swift
//  RemoteMouse
//
//  Created by Boyko Andrey on 9/26/14.
//  Copyright (c) 2014 LOL. All rights reserved.
//

import UIKit
//Command?
class EventsTabBarViewController: UITabBarController {
    var outputStream:NSOutputStream?
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        //self.sendCloseConection()
    }
    
    func sendMouseMoveEvent (var diff:Point){
        //return;
        if let stream = self.outputStream{
            diff.v = min(diff.v, 127)
            
            diff.h = min(diff.h, 127)
            
            diff.v = max(diff.v, -127)
            diff.h = max(diff.h, -127)
            
            var byteData:[UInt8] = [ServerEvent.MouseMove.toRaw(), UInt8(diff.v+128), UInt8(diff.h+128)]
            self.sendData(byteData)
        }
    }
    
   func sendMouseTap (tapCount:UInt8){
        //return;
        var byteData:[UInt8] = [ServerEvent.MouseTap.toRaw(), tapCount]
        self.sendData(byteData)
    }
    
    func sendCloseConection(){
        var byteData:[UInt8] = [ServerEvent.DidCloseServer.toRaw()]
        self.sendData(byteData)
    }
    
    func sendData(byteData:[UInt8]){
        if  let stream = self.outputStream{
            stream.write(byteData, maxLength: sizeof(UInt8)*byteData.count);
        }
    }
    
}
