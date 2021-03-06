//
//  ViewController.swift
//  DartsConnect
//
//  Created by Jordan Lewis on 13/02/2016.
//  Copyright © 2016 Jordan Lewis. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    var menu:SideMenuView!
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        menu.returnToRoot()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        /*
         Initialise and add the Side Menu to the ViewController
         Also, assign constraints so that it can adapt to different screen sizes.
         */
        menu = SideMenuView(parent: self)
        self.view.addSubview(menu)
        menu.translatesAutoresizingMaskIntoConstraints = false
        
        // Set the side menu to the right of the screen
        self.view.addConstraint(NSLayoutConstraint(item: menu, attribute: .Right, relatedBy: .Equal, toItem: self.view, attribute: .Right, multiplier: 1, constant: 0))
        // Set the width of the side menu to a constant
        self.view.addConstraint(NSLayoutConstraint(item: menu, attribute: .Width, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1, constant: menu.width))
        // Vertically place the side menu an equal distance from the top and bottom of the screen
        self.view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|-\(menu.padding)-[menu]-\(menu.padding)-|", options: .AlignAllCenterY, metrics: nil, views: ["menu":menu]))
        
        GlobalVariables.sharedVariables.menuvc = self
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}

