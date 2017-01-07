
//
//  ScoresBar.swift
//  DartsConnect
//
//  Created by Jordan Lewis on 17/05/2016.
//  Copyright © 2016 Jordan Lewis. All rights reserved.
//

import UIKit

/// Each individual unit of UI that shows that darthit for the turn
class ScoresBarScore: UIView {
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
    
    func reset() {
        scoreLabel.text = "Throw"
        descLabel.text = "Throw a dart"
    }
    
    func updateLabels(dartHit:DartHit) {
        scoreLabel.text = "\(dartHit.totalHitValue)"
        descLabel.text = "\(multiplierDictionary[dartHit.multiplier]!) \(scoresDictionary[dartHit.section]!)"
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
        
        descLabel = UILabel()
        descLabel.text = "Triple Zero"
        descLabel.font = UIFont.systemFontOfSize(30)
        descLabel.adjustsFontSizeToFitWidth = true
        descLabel.textAlignment = .Center
        descLabel.textColor = UIColor.whiteColor()
        descLabel.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(descLabel)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class ScoresBar: UIView {
    var header:UILabel = UILabel()
    var scoresStack:UIStackView!
    var actionButton:UIButton = UIButton(type: .System)
    var game = GlobalVariables.sharedVariables.currentGame!
    
    enum ActionButtonTitle:String {
        case Next = "Next Player"
        case Skip = "----------" // TODO: Implement 'Skip Player'
    }
    
    var parentVC:GameViewController!
    
    /**
     Makes the last hit a - for a bust/missed
     */
    func tacOutLastHit() {
        let index = game.players[game.currentTurn].turnScores.numThrows - 1
        let hitBox = scoresStack.arrangedSubviews[index] as! ScoresSideBarScore
        hitBox.scoreLabel.text = "-"
    }
    
    /**
     Just a shortcut for setting a button title
     
     - parameter title: A ActionButtonTitle enum value.
     */
    func setButtonTitle(title:ActionButtonTitle) {
        actionButton.setTitle(title.rawValue, forState: .Normal)
    }
    
    // TODO: Implement 'Skip Player'
    /**
     NOT IMPLEMENTED
     */
    func skipPlayer() {
        //        game.skipPlayer() This doesn't exist yet
    }
    
    /**
     Changes to the next player
     */
    func nextPlayer() {
        game.changeToNextPlayer()
    }
    
    /**
     Called when the Next or Skip player button is pressed
     
     - parameter sender: The instance of UIButton that called this function
     */
    func actionButtonPressed(sender:UIButton) {
        switch ActionButtonTitle(rawValue:sender.currentTitle!)! {
        case .Next:
            nextPlayer()
            break
        case .Skip:
            skipPlayer()
            break
        }
    }
    
    /**
     Sets all of the scores in a side bar back to their blank values
     */
    func resetScoresSidebar() {
        for scoreView:ScoresSideBarScore in scoresStack.arrangedSubviews as! [ScoresSideBarScore] {
            scoreView.reset()
        }
    }
    
    /**
     Shows the score that was just hit in the sidebar
     
     - parameter dartHit: A DartHit
     */
    func showScore(dartHit:DartHit) {
        let index = game.getCurrentThrowNumber() - 1 < 0 ? 0 : game.getCurrentThrowNumber()
        print(index)
        let scoreView = scoresStack.arrangedSubviews[index] as! ScoresSideBarScore
        scoreView.updateLabels(dartHit)
        
        if game.getCurrentThrowNumber() == 3 {
            setButtonTitle(.Next)
        }
    }
    
    init(parent: GameViewController) {
        super.init(frame: CGRectZero)
        
        parentVC = parent
        
        self.translatesAutoresizingMaskIntoConstraints = false
        
        self.backgroundColor = kColorBlack
        self.applyDropShadow()
        if isDebugging {self.backgroundColor = UIColor.redColor()}
        
        header.text = parent.gameType.rawValue
        header.font = UIFont.boldSystemFontOfSize(50)
        header.adjustsFontSizeToFitWidth = true
        header.translatesAutoresizingMaskIntoConstraints = false
        header.textColor = kColorBlue
        header.textAlignment = .Center
        self.addSubview(header)
        
        scoresStack = UIStackView()
        scoresStack.spacing = 10
        scoresStack.alignment = .Center
        scoresStack.distribution = .EqualSpacing
        scoresStack.translatesAutoresizingMaskIntoConstraints = false
        
        for i in 1...3 {
            let score:ScoresSideBarScore = ScoresSideBarScore()
            score.scoreLabel.text = "\(i)"
            score.translatesAutoresizingMaskIntoConstraints = false
            scoresStack.addArrangedSubview(score)
        }
        self.addSubview(scoresStack)
        
        setButtonTitle(.Skip)
        actionButton.addTarget(self, action: #selector(ScoresSideBar.actionButtonPressed(_:)), forControlEvents: .PrimaryActionTriggered)
        actionButton.titleLabel?.adjustsFontSizeToFitWidth = true
        actionButton.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(actionButton)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
