//
//  ScoresSideBar.swift
//  DartsConnect
//
//  Created by Jordan Lewis on 5/04/2016.
//  Copyright © 2016 Jordan Lewis. All rights reserved.
//

import UIKit

class ScoresSideBarScore: UIView {
    var scoreLabel:UILabel = UILabel()
    var descLabel:UILabel = UILabel()
    
    init() {
        super.init(frame: CGRectZero)
        
        scoreLabel = UILabel()
        scoreLabel.text = "0"
        scoreLabel.font = UIFont.boldSystemFontOfSize(50)
        scoreLabel.adjustsFontSizeToFitWidth = true
        scoreLabel.textAlignment = .Center
        scoreLabel.textColor = UIColor.whiteColor()
        scoreLabel.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(scoreLabel)
        self.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-10-[scoreLabel]-10-|", options: .AlignAllCenterX, metrics: nil, views: ["scoreLabel":scoreLabel]))
        
        descLabel = UILabel()
        descLabel.text = "Triple Zero"
        descLabel.font = UIFont.systemFontOfSize(30)
        descLabel.adjustsFontSizeToFitWidth = true
        descLabel.textAlignment = .Center
        descLabel.textColor = UIColor.whiteColor()
        descLabel.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(descLabel)
        self.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-10-[descLabel]-10-|", options: .AlignAllCenterX, metrics: nil, views: ["descLabel":descLabel]))
        
        self.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|-10-[scoreLabel(\(scoreLabel.font.pointSize))]-5-[descLabel(\(descLabel.font.pointSize + 10))]-10-|", options: .AlignAllCenterX, metrics: nil, views: ["scoreLabel":scoreLabel, "descLabel":descLabel]))
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class ScoresSideBar: UIView {
    var header:UILabel = UILabel()
    var scoresStack:UIStackView!
    var actionButton:UIButton = UIButton(type: .System)
    
    var parentVC:GameViewController!
    
    func actionButtonPressed(sender:UIButton) {
        parentVC.showHitScore(180)
    }
    
    init(parent: GameViewController) {
        super.init(frame: CGRectZero)
        
        parentVC = parent
        
        if isDebugging {self.backgroundColor = UIColor.redColor()}
        
        header.text = "Player 1"
        header.adjustsFontSizeToFitWidth = true
        header.font = UIFont.boldSystemFontOfSize(50)
        header.translatesAutoresizingMaskIntoConstraints = false
        header.textColor = UIColor.whiteColor()
        header.textAlignment = .Center
        self.addSubview(header)
        self.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|[header]|", options: .AlignAllCenterX, metrics: nil, views: ["header":header]))
        
        scoresStack = UIStackView()
        scoresStack.axis = .Vertical
        scoresStack.spacing = 10
        scoresStack.alignment = .Center
        scoresStack.distribution = .EqualSpacing
        scoresStack.translatesAutoresizingMaskIntoConstraints = false
        
        for i in 1...3 {
            let score:ScoresSideBarScore = ScoresSideBarScore()
            score.scoreLabel.text = "\(i)"
            score.translatesAutoresizingMaskIntoConstraints = false
            scoresStack.addArrangedSubview(score)
            scoresStack.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-10-[score]-10-|", options: .AlignAllCenterX, metrics: nil, views: ["score":score]))
            scoresStack.addConstraint(NSLayoutConstraint(item: score, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1, constant: 115))
        }
        
        self.addSubview(scoresStack)
        
        actionButton.setTitle("Next Player", forState: .Normal)
        actionButton.addTarget(self, action: #selector(ScoresSideBar.actionButtonPressed(_:)), forControlEvents: .PrimaryActionTriggered)
        actionButton.titleLabel?.adjustsFontSizeToFitWidth = true
        actionButton.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(actionButton)
        self.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-25-[actionButton]-25-|", options: .AlignAllCenterX, metrics: nil, views: ["actionButton":actionButton]))

        self.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|-25-[header]-40-[scoreStack]-40-[actionButton]-25-|", options: .AlignAllCenterX, metrics: nil, views: ["header":header, "scoreStack":scoresStack, "actionButton":actionButton]))
        self.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|[scoreStack]|", options: .AlignAllCenterX, metrics: nil, views: ["scoreStack":scoresStack]))
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
