//
//  GameSummaryViewController.swift
//  DartsConnect
//
//  Created by Jordan Lewis on 20/05/2016.
//  Copyright © 2016 Jordan Lewis. All rights reserved.
//

import UIKit

/// A UIView class for containing the Game Summary data for one player
class GameSummaryPlayerRow:UIView {
    init(playerName:String, place:Int, description:String, height:CGFloat) {
        super.init(frame: CGRectZero)
        self.translatesAutoresizingMaskIntoConstraints = false
        
        self.backgroundColor = kColorBlack
        if isDebugging {self.backgroundColor = UIColor.redColor()}
        
        let placeLabel = UILabel()
        placeLabel.text = "\(place)."
        placeLabel.font = UIFont.systemFontOfSize(height/2)
        placeLabel.textAlignment = .Left
        placeLabel.translatesAutoresizingMaskIntoConstraints = false
        placeLabel.textColor = kColorWhite
        self.addSubview(placeLabel)
        
        let playerLabel = UILabel()
        playerLabel.text = playerName
        playerLabel.font = UIFont.systemFontOfSize(height/2)
        playerLabel.textAlignment = .Left
        playerLabel.translatesAutoresizingMaskIntoConstraints = false
        playerLabel.textColor = kColorWhite
        self.addSubview(playerLabel)
        
        let descLabel = UILabel()
        descLabel.text = description
        descLabel.font = UIFont.systemFontOfSize(height/2)
        descLabel.textAlignment = .Right
        descLabel.translatesAutoresizingMaskIntoConstraints = false
        descLabel.textColor = kColorWhite
        self.addSubview(descLabel)
        
        self.addConstraint(placeLabel.exactAttributeConstraint(.Left, value: 10, relatedTo: self))
        self.addConstraint(playerLabel.relateAttribute(.Left, toView: placeLabel, attribute2: .Right, multiplier: 1, constant: 10))
        self.addConstraint(descLabel.exactAttributeConstraint(.Right, value: -10, relatedTo: self))
        self.addConstraint(placeLabel.exactAttributeConstraint(.Width, value: height/2, relatedTo: nil))
        self.addConstraints(placeLabel.fullVerticalConstraint)
        self.addConstraints(playerLabel.fullVerticalConstraint)
        self.addConstraints(descLabel.fullVerticalConstraint)
        self.addConstraint(playerLabel.relateAttribute(.Right, toView: descLabel, attribute2: .Left, multiplier: 1, constant: -10))
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class GameSummaryViewController: UIViewController {
    let vStack:UIStackView = UIStackView()
    
    /**
     Go back to the Main View Controller
     */
    func finish() {
        print("Leave game summary view controller")
        // These are all the things that didn't work
        //        self.showViewController(GlobalVariables.sharedVariables.menuvc!, sender: self)
        //        self.presentVC(GlobalVariables.sharedVariables.menuvc!)
        //        presentViewController(GlobalVariables.sharedVariables.menuvc!, animated: true, completion: nil)
        //        showViewController(GlobalVariables.sharedVariables.menuvc!, sender: self)
        showViewController(ViewController(), sender: self)
    }
    
    /**
     Was used for debuigging
     
     - returns: self
     */
    convenience init() {
        let players = [
            "Jordan":"0",
            "Jack":"34",
            "Sam":"43",
            "Kimber":"98"
        ]
        let places = [
            "Jordan",
            "Jack",
            "Sam",
            "Kimber"
        ]
        self.init(title: "301", players:players, places: places)
    }
    
    init(title: String, players:[String:String], places:[String]) {
        super.init(nibName: nil, bundle: nil)
        
        // Create a vertical stack to place the rows
        vStack.translatesAutoresizingMaskIntoConstraints = false
        vStack.axis = .Vertical
        vStack.spacing = 0
        vStack.distribution = .Fill
        vStack.alignment = .Leading
        self.view.addSubview(vStack)
        
        // For every player, add create a Game Summary Row and assign values to some labels and give it constraints
        for player in places {
            let description = players[player]!
            let heightMultiplier = 1 - (CGFloat(vStack.arrangedSubviews.count) * 0.1)
            let row = GameSummaryPlayerRow(playerName: player, place: places.indexOf(player)! + 1, description: description, height: 100 * heightMultiplier)
            vStack.addArrangedSubview(row)
            if vStack.arrangedSubviews.count == 1 {
                vStack.addConstraints(row.fullHorizontalConstraint)
                vStack.addConstraint(row.exactAttributeConstraint(.Height, value: 100, relatedTo: nil))
            } else {
                vStack.addConstraint(row.relationalAttributeConstraintTo(vStack.arrangedSubviews.first!, attribute: .Width, multiplier: 1 - (CGFloat(vStack.arrangedSubviews.count - 1) * 0.1)))
                vStack.addConstraint(row.relationalAttributeConstraintTo(vStack.arrangedSubviews.first!, attribute: .Height, multiplier: heightMultiplier))
            }
        }
        
        self.view.addConstraint(vStack.relationalAttributeConstraintTo(self.view, attribute: .Width, multiplier: 0.65))
        // Get the height of the stack view based on the heightMultiplier and how many players there are.
        let stackHeight:CGFloat = {
            let firstH:CGFloat = 100
            var sum:CGFloat = 0
            for i in 0..<players.count {
                sum += firstH - (CGFloat(i) * firstH * 0.1)
            }
            return sum
        }()
        
        let button = UIButton(type: .System)
        button.setTitle("Finish", forState: .Normal)
        button.addTarget(self, action: #selector(GameSummaryViewController.finish), forControlEvents: .PrimaryActionTriggered)
        button.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(button)
        
        let titleLabel = UILabel()
        titleLabel.text = "\(title) Game Summary"
        titleLabel.font = UIFont.boldSystemFontOfSize(100)
        titleLabel.textAlignment = .Left
        titleLabel.adjustsFontSizeToFitWidth = true
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(titleLabel)
        
        self.view.addConstraint(titleLabel.bindAttribute(.Left, toView: vStack))
        self.view.addConstraint(titleLabel.exactAttributeConstraint(.Top, value: 75, relatedTo: self.view))
        self.view.addConstraint(titleLabel.bindAttribute(.Width, toView: vStack))
        self.view.addConstraint(titleLabel.exactAttributeConstraint(.Height, value: 150, relatedTo: nil))
        
        self.view.addConstraint(vStack.exactAttributeConstraint(.Height, value: stackHeight, relatedTo: nil))
        //        self.view.addConstraint(vStack.relateAttribute(.Top, toView: titleLabel, attribute2: .Bottom, multiplier: 1, constant: 75))
        //        self.view.addConstraint(vStack.exactAttributeConstraint(.Left, value: 200, relatedTo: self.view))
        self.view.addConstraint(vStack.exactAttributeConstraint(.CenterX, value: 0, relatedTo: self.view))
        self.view.addConstraint(vStack.exactAttributeConstraint(.CenterY, value: 0, relatedTo: self.view))
        
        self.view.addConstraint(button.exactAttributeConstraint(.Bottom, value: -100, relatedTo: self.view))
        //        self.view.addConstraint(button.exactAttributeConstraint(.Right, value: -100, relatedTo: self.view))
        self.view.addConstraint(button.exactAttributeConstraint(.Left, value: 0, relatedTo: vStack))
        self.view.addConstraint(button.relationalAttributeConstraintTo(self.view, attribute: .Width, multiplier: 0.25))
        self.view.addConstraint(button.exactAttributeConstraint(.Height, value: 75, relatedTo: nil))
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
