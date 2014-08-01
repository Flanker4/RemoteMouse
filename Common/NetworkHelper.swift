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
let BonjourPort:Int32     = 6544


//completion block
typealias NetworkHelperRegisterCompletion = (NSNetService!, errorDict:[NSObject:AnyObject]?)->Void
typealias NetworkHelperFindActiveServiceCompletion = (Array<NSNetService>?)->Void
typealias NetworkHelperReceiveByteClosure = (Point)->Void
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
    func registerService(registrationCompletion:NetworkHelperRegisterCompletion? = nil, callback:NetworkHelperReceiveByteClosure?=nil)->NSNetService{
        
        self.registerCompletionClosure = registrationCompletion
        self.readerCallback = callback
        let netService = NSNetService(domain: BonjourDomain, type: BonjourType, name: BonjourName);
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
  
    func connectToService(service:NSNetService, didConnectCallback:NetworkHelperClinetDidConnect?=nil)->Bool{
        var success                         = false
        var inStream:       NSInputStream?  = nil
        var outStream:      NSOutputStream? = nil
        
        self.clientDidConnectCallback = didConnectCallback
        service.resolveWithTimeout(5)
       
        success = service.getInputStream(&inStream, outputStream: &outStream)
        
        if  (success)&&(inStream)&&(outStream) {
            self.openStreams([inStream!,outStream!])
            
            if let complition = self.clientDidConnectCallback{
                complition (inputSteam: self.inputStream!, outputStream: self.outputStream!)
            }
        }else{
            self.closeStreams([self.inputStream!,self.outputStream!])
        }
        return success
    }
///
/// MARK: private
///
    func openStreams(streams:[NSStream],setDelegate:Bool = true){
        self.inputStream = streams[0] as? NSInputStream;
        self.outputStream = streams[1] as? NSOutputStream;
        for stream in streams{
            if setDelegate{
                stream.delegate = self
            }
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
        self.inputStream = inputStream;
        self.outputStream = outputStream
        
        if let stream = self.inputStream{
            stream.delegate = self;
        }
        
        self.inputStream?.scheduleInRunLoop(NSRunLoop.currentRunLoop(), forMode: NSDefaultRunLoopMode)
        self.outputStream?.scheduleInRunLoop(NSRunLoop.currentRunLoop(), forMode: NSDefaultRunLoopMode)
        
        self.inputStream?.open()
        self.outputStream?.open()
        
        
       //self.openStreams([inputStream!,outputStream!],setDelegate: true);
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
                var buffer = [UInt8](count: 2, repeatedValue: 0)

                
                 var    bytesRead =  self.inputStream!.read(&buffer, maxLength: sizeof(UInt8)*buffer.count)

                
                if (bytesRead > 0) {
                    // Do nothing; we'll handle EOF and error in the
                    // NSStreamEventEndEncountered and NSStreamEventErrorOccurred case,
                    // respectively.
                    let point = Point(v:Int16(buffer[0])-128,h:Int16(buffer[1])-128)
                    if let closure = self.readerCallback{
                        closure(point)
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






