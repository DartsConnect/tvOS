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
    
    let scoresDictionary:[UInt:String] = [
        1:"One",
        2:"Two",
        3:"Three",
        4:"Four",
        5:"Five",
        6:"Six",
        7:"Seven",
        8:"Eight",
        9:"Nine",
        10:"Ten",
        11:"Eleven",
        12:"Twelve",
        13:"Thirteen",
        14:"Fourteen",
        15:"Fifteen",
        16:"Sixteen",
        17:"Seventeen",
        18:"Eighteen",
        19:"Nineteen",
        20:"Twenty",
        25:"Bull"
        
    ]
    
    let multiplierDictionary:[UInt:String] = [
        1:"",
        2:"Double",
        3:"Triple"
    ]
    
    func updateLabels(hitValue:UInt, multiplier:UInt) {
        scoreLabel.text = "\(hitValue * multiplier)"
        descLabel.text = "\(multiplierDictionary[multiplier]!) \(scoresDictionary[hitValue]!)"
    }
    
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
    var game = GlobalVariables.sharedVariables.currentGame!
    
    enum ActionButtonTitle:String {
        case Next = "Next Player"
        case Skip = "Skip Player"
    }
    
    var parentVC:GameViewController!
    
    func setButtonTitle(title:ActionButtonTitle) {
        actionButton.setTitle(title.rawValue, forState: .Normal)
    }
    
    func skipPlayer() {
//        GlobalVariables.sharedVariables.currentGame.skipPlayer() This doesn't exist yet
    }
    
    func nextPlayer() {
        GlobalVariables.sharedVariables.currentGame?.nextPlayer()
    }
    
    func actionButtonPressed(sender:UIButton) {
        switch ActionButtonTitle(rawValue:sender.currentTitle!)! {
        case .Next:
            nextPlayer()
            break
        case .Skip:
            skipPlayer()
            break
        default:
            break
        }
    }
    
    func showScore(hitValue:UInt, multiplier:UInt) {
        let scoreView = scoresStack.arrangedSubviews[game.getCurrentThrowNumber() - 1] as! ScoresSideBarScore
        scoreView.updateLabels(hitValue, multiplier: multiplier)
        
        if game.getCurrentThrowNumber() == 3 {
            setButtonTitle(.Next)
        }
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
        
        setButtonTitle(.Skip)
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
