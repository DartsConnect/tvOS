//
//  GameViewController.swift
//  DartsConnect
//
//  Created by Jordan Lewis on 5/04/2016.
//  Copyright © 2016 Jordan Lewis. All rights reserved.
//

import UIKit

class GameViewController: UIViewController {
    
    var gameType:GameType!
    var gameController:Game!
    let hitLabel:UILabel = UILabel()
    
    override func pressesBegan(presses: Set<UIPress>, withEvent event: UIPressesEvent?) {
        if(presses.first?.type == UIPressType.Menu) {
            // handle event
            let alert:UIAlertController = UIAlertController(title: "\(gameType.rawValue) Menu", message: nil, preferredStyle: .ActionSheet)
            alert.addAction(UIAlertAction(title: "Rethrow Last Dart", style: .Default, handler: {
                (action:UIAlertAction) in
            }))
            
            alert.addAction(UIAlertAction(title: "Skip Player", style: .Default, handler: {
                (action:UIAlertAction) in
            }))
            
            // Insert Catch Ups here
            alert.addAction(UIAlertAction(title: "Player 1 Catch Up", style: .Default, handler: {
                (action:UIAlertAction) in
            }))
            
            alert.addAction(UIAlertAction(title: "Back to Game", style: .Default, handler: {
                (action:UIAlertAction) in
            }))
            
            alert.addAction(UIAlertAction(title: "Save & Quit Game", style: .Default, handler: {
                (action:UIAlertAction) in
            }))
            
            alert.addAction(UIAlertAction(title: "Quit Game without Saving", style: .Default, handler: {
                (action:UIAlertAction) in
                self.dismissViewControllerAnimated(true, completion: nil)
            }))
            
            self.showViewController(alert, sender: self)
        } else {
            // perform default action (in your case, exit)
            super.pressesBegan(presses, withEvent: event)
        }
    }
    
    func showHitScore(score:AnyObject) { // AnyObject becuase it can be a number with hit number, or BULL if bulls eye
        hitLabel.text = "\(score)"
        hitLabel.alpha = 1
        hitLabel.transform = CGAffineTransformMakeScale(0, 0)
        
        UIView.animateWithDuration(0.625, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 4, options: .CurveEaseInOut, animations: {
            //self.hitLabel.alpha = 1
            self.hitLabel.transform = CGAffineTransformMakeScale(1, 1)
            }, completion: {(completed) in
                UIView.animateWithDuration(0.25, delay: 0, options: .CurveEaseIn, animations: {
                        self.hitLabel.alpha = 0
                        self.hitLabel.transform = CGAffineTransformMakeScale(2, 0.01)
                    }, completion: {(done) in
                        self.hitLabel.transform = CGAffineTransformMakeScale(0, 0)
                })
        })
    }
    
    init(gameSettings:[String], players:[String]) {
        super.init(nibName: nil, bundle: nil)
                
        gameType = GameType(rawValue: gameSettings[0])!
        
        //gameController = CountdownGame(startScore: 301, playerIDs: players)
        
        switch gameType! {
        case .CountDown:
            gameController = CountdownGame(startScore: UInt(gameSettings[1])!, playerIDs: players, openC: [GameEndsCriteria(rawValue: gameSettings[2])!], closeC: [GameEndsCriteria(rawValue: gameSettings[3])!])
            break
        case .Cricket:
            break
        case .Free:
            break
        case .TwentyToOne:
            break
        case .World:
            break
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidAppear(animated: Bool) {
        showHitScore(180)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        hitLabel.text = "180"
        hitLabel.font = UIFont.boldSystemFontOfSize(400)
        hitLabel.textColor = UIColor.whiteColor()
        hitLabel.textAlignment = .Center
        if isDebugging {hitLabel.backgroundColor = UIColor.clearColor()}
        hitLabel.layer.shadowOpacity = 0.75
        hitLabel.layer.shadowColor = UIColor.blackColor().CGColor
        hitLabel.layer.shadowOffset = CGSizeMake(5, 5)
        hitLabel.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(hitLabel)
        self.view.addConstraint(NSLayoutConstraint(item: hitLabel, attribute: .CenterX, relatedBy: .Equal, toItem: self.view, attribute: .CenterX, multiplier: 1, constant: 0))
        self.view.addConstraint(NSLayoutConstraint(item: hitLabel, attribute: .CenterY, relatedBy: .Equal, toItem: self.view, attribute: .CenterY, multiplier: 0.8, constant: 0))
        self.view.addConstraint(NSLayoutConstraint(item: hitLabel, attribute: .Height, relatedBy: .Equal, toItem: self.view, attribute: .Height, multiplier: 0.5, constant: 0))
        self.view.addConstraint(NSLayoutConstraint(item: hitLabel, attribute: .Width, relatedBy: .Equal, toItem: self.view, attribute: .Width, multiplier: 0.5, constant: 0))
        
        
        
        let playerBar:PlayersBar = PlayersBar(parent: self, players: gameController.playerNames(), startScore: gameType == .CountDown ? (gameController as! CountdownGame).gameStartScore : 0)
        playerBar.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(playerBar)
        self.view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-100-[playerBar]-100-|", options: .AlignAllCenterX, metrics: nil, views: ["playerBar":playerBar]))
        self.view.addConstraint(NSLayoutConstraint(item: playerBar, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1, constant: 200))
        self.view.addConstraint(NSLayoutConstraint(item: playerBar, attribute: .Bottom, relatedBy: .Equal, toItem: self.view, attribute: .Bottom, multiplier: 1, constant: 0))
        
        let scoresBar:ScoresSideBar = ScoresSideBar(parent: self)
        scoresBar.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(scoresBar)
        self.view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|-\(100 + 50)-[scoresBar]-\(200 + 50)-|", options: .AlignAllLeading, metrics: nil, views: ["scoresBar":scoresBar]))
        self.view.addConstraint(NSLayoutConstraint(item: scoresBar, attribute: .Width, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1, constant: 300))
        self.view.addConstraint(NSLayoutConstraint(item: scoresBar, attribute: .Right, relatedBy: .Equal, toItem: self.view, attribute: .Right, multiplier: 1, constant: 0))
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
