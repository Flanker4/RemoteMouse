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
typealias NetworkHelperReceiveByteClosure = (UInt8)->Void
typealias NetworkHelperClinetDidConnect = (inputSteam:NSInputStream,outputStream:NSOutputStream)->Void


class NetworkHelper: NSObject, NSNetServiceDelegate, NSNetServiceBrowserDelegate, NSStreamDelegate {
    
    
    var registerCompletionClosure:NetworkHelperRegisterCompletion?
    
    var findActiveServicesClosure:NetworkHelperFindActiveServiceCompletion?
    var readerCallback:NetworkHelperReceiveByteClosure?
    var clientDidConnectCallback:NetworkHelperClinetDidConnect?
    
    var activeServices = [NSNetService]()
    var browser = NSNetServiceBrowser()
    
    var outputStream:       NSOutputStream?
    var inputStream:        NSInputStream?
///
/// MARK: Public
///
    func registerService(registrationCompletion:NetworkHelperRegisterCompletion? = nil, clientDidConnectCompletion:NetworkHelperClinetDidConnect?=nil)->NSNetService{
        
        self.registerCompletionClosure = registrationCompletion
        self.clientDidConnectCallback = clientDidConnectCompletion
        let netService = NSNetService(domain: BonjourDomain, type: BonjourType, name: BonjourName,port: BonjourPort);
        netService.scheduleInRunLoop(NSRunLoop.currentRunLoop(), forMode: kCFRunLoopDefaultMode)
        netService.delegate = self
        netService.publishWithOptions(NSNetServiceOptions.ListenForConnections)
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
  
    func connectToService(service:NSNetService, callback:NetworkHelperReceiveByteClosure?=nil)->Bool{
        var success                         = false
        var inStream:       NSInputStream?  = nil
        var outStream:      NSOutputStream? = nil
        
        self.readerCallback = callback
        //service.resolveWithTimeout(5)
       
        success = service.getInputStream(&inStream, outputStream: &outStream)
        
        if  (success) {
            self.inputStream  = inStream;
            self.outputStream = outStream;
            
            self.openStreams([self.inputStream!,self.outputStream!])
        }else{
            self.closeStreams([self.inputStream!,self.outputStream!])
        }
        return success
    }
///
/// MARK: private
///
    func openStreams(streams:[NSStream]){
        self.inputStream = streams[0] as? NSInputStream;
        self.outputStream = streams[1] as? NSOutputStream;
        for stream in streams{
            stream.delegate = self
            stream.scheduleInRunLoop(NSRunLoop.currentRunLoop(), forMode: NSDefaultRunLoopMode)
            stream.open()
        }
    }
    
    func closeStreams(streams:[NSStream]){
        for stream in streams{
            stream.delegate = nil;
            stream.removeFromRunLoop(NSRunLoop.currentRunLoop(), forMode: NSDefaultRunLoopMode)
            stream.close()
        }
        //wtf?
        self.inputStream = nil;
        self.outputStream = nil;
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
    
    func netService(sender: NSNetService!, didAcceptConnectionWithInputStream inputStream: NSInputStream!, outputStream: NSOutputStream!){
        self.openStreams([inputStream,outputStream]);
        if let complition = self.clientDidConnectCallback{
            complition (inputSteam: inputStream, outputStream: outputStream)
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
    
///
/// MARK: NSStream Delegate
///
    
    func stream(aStream: NSStream!, handleEvent eventCode: NSStreamEvent) {
        switch eventCode{
            case NSStreamEvent.OpenCompleted:
                println("")

            case NSStreamEvent.None:
                println("")
            case NSStreamEvent.OpenCompleted:
                println("")
            case NSStreamEvent.HasBytesAvailable:
                println("Go")
                var    b:        UInt8   = 0;
                var    bytesRead =  self.inputStream!.read(&b, maxLength: sizeof(UInt8))

                
                if (bytesRead > 0) {
                    // Do nothing; we'll handle EOF and error in the
                    // NSStreamEventEndEncountered and NSStreamEventErrorOccurred case,
                    // respectively.
                    println(b);
                    if let closure = self.readerCallback{
                        closure(b)
                    }
                }
            case NSStreamEvent.HasSpaceAvailable:
                println("")
            case NSStreamEvent.ErrorOccurred:
                println("")
            case NSStreamEvent.EndEncountered:
                println("")
            default:
                println("")
        }
    }
};






