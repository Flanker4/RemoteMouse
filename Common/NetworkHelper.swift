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
typealias NetworkHelperFindActiveServiceCompletion = (Array<NSNetService>?)->Void

class NetworkHelper: NSObject, NSNetServiceDelegate, NSNetServiceBrowserDelegate {
    
    
    var registerCompletionClosure:NetworkHelperRegisterCompletion?
    var findActiveServicesClosure:NetworkHelperFindActiveServiceCompletion?
    var activeServices = [NSNetService]()
    var browser = NSNetServiceBrowser()
///
/// MARK: Public
///
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
 
    func findActiveServices(completion:NetworkHelperFindActiveServiceCompletion?=nil)->Void{
        //prepare
        self.findActiveServicesClosure = completion
        activeServices.removeAll(keepCapacity: true)

        //let's go
        browser.delegate = self
        browser.searchForServicesOfType(BonjourType, inDomain: BonjourDomain)
    }
  
///
/// MARK: NetService Delegate
///
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
///
/// MARK: NetServiceBrowser Delegate
///
    
    func netServiceBrowser(aNetServiceBrowser: NSNetServiceBrowser!, didNotSearch errorDict: [NSObject : AnyObject]!) {
        if let completion = self.findActiveServicesClosure{
            completion(nil);
        }
    }
    
    func netServiceBrowser(aNetServiceBrowser: NSNetServiceBrowser!, didFindService aNetService: NSNetService!, moreComing: Bool) {
        activeServices.append(aNetService);
        
        //notify
        if (!moreComing){
            if let completion = self.findActiveServicesClosure{
                completion(activeServices);
            }
        }
        
        
    }
    
    func netServiceBrowser(aNetServiceBrowser: NSNetServiceBrowser!, didRemoveService aNetService: NSNetService!, moreComing: Bool) {
        //remove item
        let index = find(activeServices, aNetService);
        if let indexExist = index {
            activeServices.removeAtIndex(indexExist);
        }

        //notify
        if (!moreComing){
            if let completion = self.findActiveServicesClosure{
                completion(activeServices);
            }
        }
    }
};






