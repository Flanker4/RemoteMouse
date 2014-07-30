//
//  NetworkHelper.swift
//  RemoteMouse
//
//  Created by Boyko Andrey on 7/30/14.
//  Copyright (c) 2014 LOL. All rights reserved.
//

import Foundation
let BonjourDomain   = "local."
let BonjourType     = "_remotemouse._tcp."
let BonjourName     = "GG"
let BonjourPort:Int32     = 6543


//completion block
typealias NetworkHelperRegisterCompletion = (NSNetService!, errorDict:[NSObject:AnyObject]?)->Void

class NetworkHelper: NSObject, NSNetServiceDelegate {
    
    
    var registerCompletionClosure:NetworkHelperRegisterCompletion?;
    
    
    func registerService(completion:NetworkHelperRegisterCompletion? = nil)->NSNetService{
        
        self.registerCompletionClosure = completion;
        
        let netService = NSNetService(domain: BonjourDomain, type: BonjourType, name: BonjourName,port: BonjourPort);
        netService.scheduleInRunLoop(NSRunLoop.currentRunLoop(), forMode: kCFRunLoopDefaultMode)
        netService.delegate = self
        netService.publish()
        return netService
    }
    
    func stopService(netService:NSNetService){
        netService.delegate = nil
        netService.stop()
    }
 
  
////delegate netService
    func netServiceDidPublish(sender: NSNetService!) {
        println("Service did register with name \(sender.name)");
        if  let completion:NetworkHelperRegisterCompletion = self.registerCompletionClosure{
            completion(sender,errorDict:nil)
        }
        
    }
    
    func netService(sender: NSNetService!, didNotPublish errorDict: [NSObject : AnyObject]!) {
        println("Serivce did not publish. Error: \(errorDict)");
        if  let completion = self.registerCompletionClosure{
            completion(sender,errorDict:errorDict);
        }

    }
}






