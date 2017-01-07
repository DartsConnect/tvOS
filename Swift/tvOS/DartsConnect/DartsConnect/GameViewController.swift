//
//  GameViewController.swift
//  DartsConnect
//
//  Created by Jordan Lewis on 5/04/2016.
//  Copyright © 2016 Jordan Lewis. All rights reserved.
//

import UIKit

class GameViewController: UIViewController {
    
    var gameType:GameClass!
    var gameController:Game!
    let hitLabel:UILabel = UILabel()
    var playerBar:PlayersBar!
    var scoresBar:ScoresBar?
    var cricketDisplay:CricketClosedDisplay?
    
    func showMainScreen() {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    /**
     Called when the menu button on the remote is pressed
     The actions commented out, were not able to be added at the time of writing
     */
    override func pressesBegan(presses: Set<UIPress>, withEvent event: UIPressesEvent?) {
        if(presses.first?.type == UIPressType.Menu) {
            // handle event
            let alert:UIAlertController = UIAlertController(title: "\(gameType.rawValue) Menu", message: nil, preferredStyle: .ActionSheet)
            //            alert.addAction(UIAlertAction(title: "Rethrow Last Dart", style: .Default, handler: {
            //                (action:UIAlertAction) in
            //            }))
            
            //            alert.addAction(UIAlertAction(title: "Skip Player", style: .Default, handler: {
            //                (action:UIAlertAction) in
            //            }))
            
            // Insert Catch Ups here
            //            alert.addAction(UIAlertAction(title: "Player 1 Catch Up", style: .Default, handler: {
            //                (action:UIAlertAction) in
            //            }))
            alert.addAction(UIAlertAction(title: "Back to Game", style: .Default, handler: {
                (action:UIAlertAction) in
                // Do nothing
            }))
            
            //            alert.addAction(UIAlertAction(title: "Save & Quit Game", style: .Default, handler: {
            //                (action:UIAlertAction) in
            //                //self.dismissViewControllerAnimated(true, completion: {GlobalVariables.sharedVariables.menuvc?.menu.returnToRoot()})
            //            }))
            //            alert.addAction(UIAlertAction(title: "Reconnect to Dartboard", style: .Default, handler: {
            //                (action:UIAlertAction) in
            //                GlobalVariables.sharedVariables.bonjourManager = BonjourManager(nil)
            //                GlobalVariables.sharedVariables.connector?.delegate = self.gameController
            //            }))
            
            alert.addAction(UIAlertAction(title: "Quit Game without Saving", style: .Default, handler: {
                (action:UIAlertAction) in
                self.showMainScreen()
            }))
            
            self.showViewController(alert, sender: self)
        } else {
            // perform default action (in your case, exit)
            super.pressesBegan(presses, withEvent: event)
        }
    }
    
    /**
     Animates in and out a big label showing what was just hit.
     
     - parameter score: The value that was just hit. AnyObject becuase it can be a number with hit number, or BULL if bulls eye
     */
    func showHitScore(score:AnyObject) {
        hitLabel.text = "\(score)"
        hitLabel.alpha = 1
        hitLabel.transform = CGAffineTransformMakeScale(0, 0)
        
        self.view.bringSubviewToFront(hitLabel)
        
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
    
    // MARK: Adding UI Elements
    func addScoresTopBar() {
        scoresBar = ScoresTopBar(parent: self)
        self.view.addSubview(scoresBar!)
        self.view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-\(150)-[scoresBar]-\(150)-|", options: .AlignAllLeading, metrics: nil, views: ["scoresBar":scoresBar!]))
        self.view.addConstraint(NSLayoutConstraint(item: scoresBar!, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1, constant: 135))
        self.view.addConstraint(NSLayoutConstraint(item: scoresBar!, attribute: .Top, relatedBy: .Equal, toItem: self.view, attribute: .Top, multiplier: 1, constant: 0))
    }
    
    func addScoresSideBar() {
        scoresBar = ScoresSideBar(parent: self)
        self.view.addSubview(scoresBar!)
        self.view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|-\(100 + 50)-[scoresBar]-\(200 + 50)-|", options: .AlignAllLeading, metrics: nil, views: ["scoresBar":scoresBar!]))
        self.view.addConstraint(NSLayoutConstraint(item: scoresBar!, attribute: .Width, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1, constant: 300))
        self.view.addConstraint(NSLayoutConstraint(item: scoresBar!, attribute: .Right, relatedBy: .Equal, toItem: self.view, attribute: .Right, multiplier: 1, constant: 0))
    }
    
    func addCricketCloseDisplay(numPlayers: Int) {
        cricketDisplay = CricketClosedDisplay(numPlayers: numPlayers)
        self.view.addSubview(cricketDisplay!)
        self.view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-150-[cricketDisplay]-150-|", options: .AlignAllCenterX, metrics: nil, views: ["cricketDisplay":cricketDisplay!]))
        self.view.addConstraint(NSLayoutConstraint(item: cricketDisplay!, attribute: .Bottom, relatedBy: .Equal, toItem: playerBar, attribute: .Top, multiplier: 1, constant: 0))
        //        self.view.addConstraint(NSLayoutConstraint(item: cricketDisplay!, attribute: .Top, relatedBy: .Equal, toItem: self.view, attribute: .Top, multiplier: 1, constant: 135))
        self.view.addConstraint(NSLayoutConstraint(item: cricketDisplay!, attribute: .Top, relatedBy: .Equal, toItem: scoresBar!, attribute: .Bottom, multiplier: 1, constant: 0))
    }
    
    func addPlayersBar() {
        playerBar = PlayersBar(parent: self, players: gameController.playerNames(), startScore: gameType == .CountDown ? (gameController as! CountdownGame).gameStartScore : 0)
        playerBar.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(playerBar)
        self.view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-100-[playerBar]-100-|", options: .AlignAllCenterX, metrics: nil, views: ["playerBar":playerBar]))
        self.view.addConstraint(NSLayoutConstraint(item: playerBar, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1, constant: 200))
        self.view.addConstraint(NSLayoutConstraint(item: playerBar, attribute: .Bottom, relatedBy: .Equal, toItem: self.view, attribute: .Bottom, multiplier: 1, constant: 0))
    }
    // MARK: End adding UI Elements
    
    /**
     Initiates an instance of a game class depending on the settings chosen in the side menu
     
     - parameter gameSettings: The breadcrumbs from the side menu, but without the prefixes
     - parameter players:      The list of Users from the side menu
     */
    func initiateGameController(gameSettings:[String], players:[User]) {
        gameType = GameClass(rawValue: gameSettings[0])!
        
        switch gameType! {
        case .CountDown:
            let startScore = UInt(gameSettings[1])!
            gameController = CountdownGame(gvc: self,
                                           startScore: startScore,
                                           users: players,
                                           openC: [GameEndsCriteria(rawValue: gameSettings[2])!],
                                           closeC: [GameEndsCriteria(rawValue: gameSettings[3])!])
            gameController.gameType = GameType.Countdown(startValue: startScore)
            break
        case .Cricket:
            let isCutThroat = gameSettings[1] == "Cut-Throat"
            gameController = CricketGame(gameViewController: self, cutThroat: isCutThroat, users: players)
            gameController.gameType = GameType.Cricket(cutThroat: isCutThroat)
            break
        case .Free:
            let numRounds = Int(gameSettings[1])!
            gameController = FreeGame(gameViewController: self, users: players, numRounds: numRounds)
            gameController.gameType = GameType.Free(rounds: numRounds)
            break
        case .World:
            gameController = WorldGame(gvc: self, users: players)
            gameController.gameType = GameType.World
            break
        }
    }
    
    init(gameSettings:[String], players:[User]) {
        super.init(nibName: nil, bundle: nil)
        
        initiateGameController(gameSettings, players: players)
        
        addPlayersBar()
        
        gameController.beginGame()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidAppear(animated: Bool) {
        showHitScore("Start")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        // Create and add the hit label to show the scores that was just hit
        hitLabel.text = ""
        hitLabel.font = UIFont.boldSystemFontOfSize(400)
        hitLabel.textColor = UIColor.whiteColor()
        hitLabel.adjustsFontSizeToFitWidth = true
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
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
