//
//  ScoresTopBar.swift
//  DartsConnect
//
//  Created by Jordan Lewis on 17/05/2016.
//  Copyright © 2016 Jordan Lewis. All rights reserved.
//

import UIKit

/// Scores Bar, Vertical Constraints
class ScoresTopBarScore: ScoresBarScore {
    override init() {
        super.init()
        
        self.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-10-[scoreLabel]-10-|", options: .AlignAllCenterX, metrics: nil, views: ["scoreLabel":scoreLabel]))
        
        self.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-10-[descLabel]-10-|", options: .AlignAllCenterX, metrics: nil, views: ["descLabel":descLabel]))
        
        self.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|-10-[scoreLabel(\(scoreLabel.font.pointSize))]-5-[descLabel(\(descLabel.font.pointSize + 10))]-10-|", options: .AlignAllCenterX, metrics: nil, views: ["scoreLabel":scoreLabel, "descLabel":descLabel]))
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

/// Horizontal Scores Bar to be on the right of the screen, with its own constraints
class ScoresTopBar: ScoresBar {
    override init(parent: GameViewController) {
        super.init(parent: parent)
        
        self.addConstraints(header.fullVerticalConstraint)
        
        scoresStack.axis = .Horizontal
        
        for score in scoresStack.arrangedSubviews {
            scoresStack.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|-10-[score]-10-|", options: .AlignAllCenterX, metrics: nil, views: ["score":score]))
            scoresStack.addConstraint(NSLayoutConstraint(item: score, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1, constant: 115))
        }
        
        self.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|-25-[actionButton]-25-|", options: .AlignAllCenterX, metrics: nil, views: ["actionButton":actionButton]))
        
        self.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-25-[header]-80-[scoreStack]-80-[actionButton]-25-|", options: .AlignAllCenterY, metrics: nil, views: ["header":header, "scoreStack":scoresStack, "actionButton":actionButton]))
        self.addConstraints(scoresStack.fullVerticalConstraint)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
