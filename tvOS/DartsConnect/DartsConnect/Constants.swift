//
//  Constants.swift
//  DartsConnect
//
//  Created by Jordan Lewis on 4/04/2016.
//  Copyright © 2016 Jordan Lewis. All rights reserved.
//

import UIKit

let isDebugging:Bool = true

enum GameType:String {
    case CountDown = "01"
    case Cricket = "Cricket"
    case Free = "Free"
    case TwentyToOne = "20 to 1"
    case World = "World"
}

enum GameEndsCriteria:String {
    case Any = "Any"
    case OnSingle = "Single"
    case OnDouble = "Double"
    case OnTriple = "Triple"
    case OnBull = "Bull"
    case OnDoubleBull = "Double Bull"
}

enum ForceEndTurnReason:CustomStringConvertible {
    case Bust
    case OpenOn(criteria: GameEndsCriteria)
    case CloseOn(criteria: GameEndsCriteria)
    
    var description: String {
        switch self {
        case Bust:
            return "Bust"
        case let OpenOn(reason):
            return "Open on \(reason)"
        case let CloseOn(reason):
            return "Close on \(reason)"
        }
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