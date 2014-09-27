//
//  TouchView.swift
//  RemoteMouse
//
//  Created by Boyko Andrey on 8/15/14.
//  Copyright (c) 2014 LOL. All rights reserved.
//

import UIKit

class TouchView: UIView {
    
    private var _startDrawPoint:CGPoint?
    private var _endDrawPoint:CGPoint?
    
    var startDrawPoint:CGPoint?{
        set{
            let oldValue = _startDrawPoint;
            _startDrawPoint = newValue;
            self.redrawIfRequired(newValue, oldValue: oldValue)
        }
        get{
            return _startDrawPoint
        }
        
    }
    
    var endDrawPoint:CGPoint?{
        set{
            let oldValue = _endDrawPoint;
            _endDrawPoint = newValue;
            self.redrawIfRequired(newValue, oldValue: oldValue)
            
        }
        get{
            return _endDrawPoint
        }
    }


// MARK: Init
    
    func setup(){
        self.backgroundColor =  UIColor.blackColor()
    }
    
    required init(coder aDecoder:NSCoder){
        super.init(coder: aDecoder)
        self.setup()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setup()
    }

// MARK: Life Cycle
    func redraw(){
        self.setNeedsDisplay();
    }
    
    func redrawIfRequired(newValue:CGPoint?,oldValue:CGPoint?){
        if  (newValue != oldValue){
            self.redraw();
        }
    }
    
    override func drawRect(rect: CGRect){
        if let beginPoint = self.startDrawPoint{
            if  let endPoint = self.endDrawPoint{
                let currentContext = UIGraphicsGetCurrentContext()
                
                //draw line
                CGContextSetStrokeColorWithColor(currentContext, UIColor.whiteColor().CGColor);
                CGContextSetLineWidth(currentContext, 5.0);
                CGContextMoveToPoint(currentContext, beginPoint.x, beginPoint.y)
                CGContextAddLineToPoint(currentContext, endPoint.x, endPoint.y)
                CGContextStrokePath(currentContext);
                //draw big circles
                let circleRadiusBig:CGFloat = 50
                CGContextSetFillColorWithColor(currentContext, UIColor.whiteColor().CGColor)
                CGContextAddEllipseInRect(currentContext, CGRect(x: beginPoint.x - circleRadiusBig, y:beginPoint.y - circleRadiusBig, width: circleRadiusBig*2, height: circleRadiusBig*2))
                CGContextAddEllipseInRect(currentContext, CGRect(x: endPoint.x  - circleRadiusBig, y: endPoint.y - circleRadiusBig,    width: circleRadiusBig*2, height: circleRadiusBig*2))
              
                CGContextFillPath(currentContext)
                CGContextStrokePath(currentContext);
                
                //draw small circels
                CGContextSetLineWidth(currentContext, 5.0);
                CGContextSetStrokeColorWithColor(currentContext, UIColor.blueColor().CGColor)
                CGContextSetFillColorWithColor(currentContext, UIColor.redColor().CGColor)
                
                let circleRadiusSmall:CGFloat = 45
                CGContextAddEllipseInRect(currentContext, CGRect(x: beginPoint.x - circleRadiusSmall, y:beginPoint.y - circleRadiusSmall, width: circleRadiusSmall*2, height: circleRadiusSmall*2))
                CGContextAddEllipseInRect(currentContext, CGRect(x: endPoint.x  - circleRadiusSmall, y: endPoint.y - circleRadiusSmall,    width: circleRadiusSmall*2, height: circleRadiusSmall*2))
                
                CGContextFillPath(currentContext)
                CGContextStrokePath(currentContext);
                
            }
            
        }
    }
    
   /* override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
        self.startTimer()
        self.touchBeganPoint = touches.anyObject()?.locationInView(self)
        self.currentTouchPoint = self.touchBeganPoint
        self.setNeedsDisplay()
    }
    
    override func touchesMoved(touches: NSSet, withEvent event: UIEvent){
        self.currentTouchPoint = touches.anyObject()?.locationInView(self)
        self.setNeedsDisplay()
    }
    
    override func touchesEnded(touches: NSSet, withEvent event: UIEvent) {
        self.stopTimer()
        self.setNeedsDisplay()
    }
    
    override func touchesCancelled(touches: NSSet!, withEvent event: UIEvent!) {
        self.stopTimer()
        self.setNeedsDisplay()
    }

    ///
    /// MARK: Utils
    ///
    
    func startTimer(){
        self.stopTimer()
        self.timer = NSTimer.scheduledTimerWithTimeInterval(timerInterval, target: self, selector: "timerTick:", userInfo: nil, repeats: true)
    }
    
    func stopTimer(){
        self.touchBeganPoint    = nil
        self.currentTouchPoint  = nil
        
        if let tmpTimer = self.timer{
            tmpTimer.invalidate()
            self.timer = nil
        }
    }
    
    func timerTick(timer:NSTimer){
        let koef:CGFloat = 50.0
        var point = CGPointZero
        point.x =  (self.currentTouchPoint!.x - self.touchBeganPoint!.x)/koef
        point.y =  (self.currentTouchPoint!.y - self.touchBeganPoint!.y)/koef
        self.delegate?.touchView?(self, didMoveWithAccleration: point)
    }
}*/
}