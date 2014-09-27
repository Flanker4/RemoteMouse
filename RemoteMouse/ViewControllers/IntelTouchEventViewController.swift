//
//  IntelTouchViewController.swift
//  RemoteMouse
//
//  Created by Boyko Andrey on 9/26/14.
//  Copyright (c) 2014 LOL. All rights reserved.
//

import UIKit
enum PanDirection:Int{
    case None = 0
    case Up
    case Down
    case Left
    case Right
    
    init(velocity:CGPoint = CGPointZero){
        if  (velocity.y > 0) && (fabs(velocity.y) > fabs(velocity.x)){
            self = .Down
        }
        if  (velocity.y < 0) && (fabs(velocity.y) > fabs(velocity.x)){
            self = .Up
        }
        if  (velocity.x > 0) && (fabs(velocity.x) > fabs(velocity.y)){
            self = .Left
        }
        if  (velocity.x < 0) && (fabs(velocity.x) > fabs(velocity.y)){
            self = .Right
        }
        self = .None
    }
    func reverceDirection() -> PanDirection{
        switch (self){
        case .Up:
                return .Down
        case .Down:
                return .Up
        case .Left:
                return .Right
        case .Right:
                return Left
        default:
                return .None
        }
    }
    
}


class IntelTouchEventViewController: TouchEventViewController {
    
    var panVelocity = CGPointZero
    var panDirection = PanDirection.None
    var startPanPoint:CGPoint = CGPointZero {
        didSet{
            self.touchView.startDrawPoint = startPanPoint
        }
    }
    
    var requiredChangeCurrentDirection = false
    var requiredChangeCurrentDirectionSem = 0
    
    var timer:NSTimer?
    //const
    let timerInterval = 0.01
    override func didPan(sender: UIPanGestureRecognizer) {
        
        switch (sender.state){
        case .Began:
            self.startTimer()
        case .Ended,.Cancelled,.Failed:
            self.stopTimer()
        default:
            println(sender.locationInView(self.touchView))
        }

       
    }
    
    //
    //MARK: -Utils
    //
    func initPanVar(){
        self.panVelocity = CGPointZero
        self.panDirection = .None
        self.prevPanPosition = self.panGesture.locationInView(self.touchView)
        self.startPanPoint = prevPanPosition
        self.touchView.startDrawPoint = prevPanPosition
        self.touchView.endDrawPoint = prevPanPosition
    }
    func resetPanVar(){
        self.panVelocity = CGPointZero
        self.panDirection = .None
        self.prevPanPosition = CGPointZero
        self.startPanPoint = CGPointZero
        
        self.touchView.startDrawPoint = nil
        self.touchView.endDrawPoint = nil
    }
    
    func startTimer(){
        self.stopTimer()
        self.timer = NSTimer.scheduledTimerWithTimeInterval(timerInterval, target: self, selector: "timerTick:", userInfo: nil, repeats: true)
        self.initPanVar()
    }
    
    func stopTimer(){
        self.resetPanVar()
        if let tmpTimer = self.timer{
            tmpTimer.invalidate()
            self.timer = nil
        }
    }
    
   
    
    func timerTick(timer:NSTimer){
        let koef: CGFloat = 50.0
        var point = Point(v: 0, h: 0)
        
        let prevPanDirection = self.panDirection
        
        let location = self.panGesture.locationInView(self.touchView)
        self.touchView.endDrawPoint = location
        
        //локальная скорость
        let localVelocity = CGPointMake(location.x-self.prevPanPosition.x, location.y-self.prevPanPosition.y)
        
        self.panVelocity = CGPointMake(location.x-self.startPanPoint.x, location.y-self.startPanPoint.y)
        self.panDirection = PanDirection(velocity: self.panVelocity)
     
        
        
        
        if CGPointEqualToPoint(localVelocity, CGPointZero){
           self.requiredChangeCurrentDirectionSem++
        }else{
            println(self.requiredChangeCurrentDirectionSem)
            if (self.requiredChangeCurrentDirectionSem > Int(1/*sec*//timer.timeInterval)){
                self.requiredChangeCurrentDirection = false
                self.startPanPoint = self.prevPanPosition;
                //локальная скорость
                self.panVelocity = CGPointMake(location.x-self.startPanPoint.x, location.y-self.startPanPoint.y)
                self.panDirection = PanDirection(velocity: self.panVelocity)
                println("UPDATE new direction is \(self.panDirection.toRaw()) with velocity \(self.panVelocity)")

            }
            self.requiredChangeCurrentDirectionSem = 0
        }
        
        point.h =  Int16(self.panVelocity.x/koef)
        point.v =  Int16(self.panVelocity.y/koef)
        
        self.parentTabBarViewController.sendMouseMoveEvent(point)
        
        self.prevPanPosition = location
    }
}
