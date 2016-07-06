//
//  Extensions.swift
//  DartsConnect
//
//  Created by Jordan Lewis on 27/05/2016.
//  Copyright © 2016 Jordan Lewis. All rights reserved.
//

import UIKit

extension UIViewController {
    func showMainScreen() {
        self.presentViewController(GlobalVariables.sharedVariables.menuvc!, animated: true, completion: {
            GlobalVariables.sharedVariables.menuvc!.menu.returnToRoot()
        })
    }
}

extension UIView {
    var fullVerticalConstraint:[NSLayoutConstraint] {
        let view = self
        return NSLayoutConstraint.constraintsWithVisualFormat("V:|[view]|", options: .AlignAllCenterX, metrics: nil, views: ["view":view])
    }
    
    var fullHorizontalConstraint:[NSLayoutConstraint] {
        let view = self
        return NSLayoutConstraint.constraintsWithVisualFormat("H:|[view]|", options: .AlignAllCenterY, metrics: nil, views: ["view":view])
    }
    
    func exactAttributeConstraint(attribute:NSLayoutAttribute, value:CGFloat, relatedTo:UIView?) -> NSLayoutConstraint {
        return NSLayoutConstraint(item: self, attribute: attribute, relatedBy: .Equal, toItem: relatedTo, attribute: relatedTo == nil ? .NotAnAttribute : attribute, multiplier: 1, constant: value)
    }
    
    func relationalAttributeConstraintTo(view:UIView, attribute:NSLayoutAttribute, multiplier:CGFloat) -> NSLayoutConstraint {
        return NSLayoutConstraint(item: self, attribute: attribute, relatedBy: .Equal, toItem: view, attribute: attribute, multiplier: multiplier, constant: 0)
    }
    
    func relateAttribute(attribute1:NSLayoutAttribute, toView:UIView, attribute2:NSLayoutAttribute, multiplier:CGFloat, constant:CGFloat) -> NSLayoutConstraint {
        return NSLayoutConstraint(item: self, attribute: attribute1, relatedBy: .Equal, toItem: toView, attribute: attribute2, multiplier: multiplier, constant: constant)
    }
    
    func equateAttribute(attribute1:NSLayoutAttribute, toView:UIView, attribute2:NSLayoutAttribute) -> NSLayoutConstraint {
        return self.relateAttribute(attribute1, toView: toView, attribute2: attribute2, multiplier: 1, constant: 0)
    }
    
    func bindAttribute(attribute:NSLayoutAttribute, toView:UIView) -> NSLayoutConstraint {
        return self.equateAttribute(attribute, toView: toView, attribute2: attribute)
    }
}

// MARK: Handy Extensions
extension IntegerType {
    /**
     
     - author: Jordan Lewis
     - date: Wednesday 25 May 2016
     - parameters:
     - None
     - returns: None
     - todo: None
     */
    var toString:String {
        return "\(self)"
    }
}

extension Array {
    /**
     
     - author: Jordan Lewis
     - date: Wednesday 25 May 2016
     - parameters:
     - None
     - returns: None
     - todo: None
     */
    var toDict:[String:Element] {
        var dict:[String:Element] = [:]
        for i in 0..<self.count {
            dict[i.toString] = self[i]
        }
        return dict
    }
}