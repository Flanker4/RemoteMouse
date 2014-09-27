//
//  TouchEventViewController.swift
//  RemoteMouse
//
//  Created by Boyko Andrey on 9/26/14.
//  Copyright (c) 2014 LOL. All rights reserved.
//

import UIKit

class TouchEventViewController: EventViewController {


//
//MARK: - Properties
//
    lazy var panGesture = UIPanGestureRecognizer()
    var prevPanPosition = CGPointZero
    
    lazy var _touchView:TouchView? = nil
    
    var touchView:TouchView {
        if  (_touchView == nil){
            _touchView = TouchView(frame: self.view.bounds)
            _touchView!.setTranslatesAutoresizingMaskIntoConstraints(false)
            
            self.view.addSubview(_touchView!)
           
            let bindings = ["parentView": self.view, "touchView":_touchView!]
            // Width constraint and position
            self.view.addConstraints(
                NSLayoutConstraint.constraintsWithVisualFormat("[touchView(parentView)]", options:( .AlignAllCenterX | .AlignAllCenterY), metrics: nil, views: bindings))
            // Height
            self.view.addConstraints(
                NSLayoutConstraint.constraintsWithVisualFormat("V:[touchView(parentView)]", options:NSLayoutFormatOptions(0), metrics: nil, views: bindings))
            
        }
        return _touchView!
    }

//
//MARK: - Life Cycle
//
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.addGestureRecognizers()
    }
    
    private func addGestureRecognizers(){
        self.panGesture.addTarget(self, action: "didPan:")
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: "pressTap:")
        let doubleTapGestureRecognizer = UITapGestureRecognizer(target: self, action: "pressTap:")
        doubleTapGestureRecognizer.numberOfTapsRequired = 2;
        
        self.touchView.addGestureRecognizer(self.panGesture)
        self.touchView.addGestureRecognizer(tapGestureRecognizer)
        self.touchView.addGestureRecognizer(doubleTapGestureRecognizer)
        
        tapGestureRecognizer.requireGestureRecognizerToFail(doubleTapGestureRecognizer)
    }
    
//
//MARK: - User Interaction
//
    
    func pressTap(sender: UITapGestureRecognizer) {
        self.parentTabBarViewController.sendMouseTap(UInt8(sender.numberOfTapsRequired))
    }
    
    func didPan(sender: UIPanGestureRecognizer) {
        switch (sender.state){
        case .Began:
            let location = sender.locationInView(self.touchView)
            self.prevPanPosition = location
            self.touchView.startDrawPoint = location;
        case .Ended,.Cancelled,.Failed:
            self.prevPanPosition = CGPointZero
            self.touchView.startDrawPoint = nil;
            self.touchView.endDrawPoint = nil;
        default:
            let location = sender.locationInView(self.touchView)
            
            //update ui
            self.touchView.endDrawPoint = location;
            
            //prepare data
            var p = location
            p.x = p.x - self.prevPanPosition.x
            p.y = p.y - self.prevPanPosition.y
            var point = Point(v: Int16(p.y), h: Int16(p.x))
            //send
            self.parentTabBarViewController.sendMouseMoveEvent(point)
            //update last
            self.prevPanPosition = location;
            println(point)
        }
        
    }
    
   
    
}
