//
//  CricketClosedDisplay.swift
//  DartsConnect
//
//  Created by Jordan Lewis on 17/05/2016.
//  Copyright © 2016 Jordan Lewis. All rights reserved.
//

import UIKit

/// The row containing the image views to show the lines to indicate whether a section has been closed or not and label to show the number.
class CricketClosedColumnRow: UIStackView {
    
    let imageview = UIImageView()
    
    func setCloseStage(stage:Int) {
        imageview.image = UIImage(named: "Cricket Close Icon \(stage)")
    }
    
    init(number:Int) {
        let label = UILabel()
        label.text = "\(number)"
        label.font = UIFont.systemFontOfSize(100)
        label.adjustsFontSizeToFitWidth = true
        label.textAlignment = .Center
        label.textColor = kColorWhite
        
        let divider = UIView()
        divider.backgroundColor = kColorBlue
        divider.translatesAutoresizingMaskIntoConstraints = false
        
        super.init(frame:CGRectZero)
        
        self.axis = .Horizontal
        self.distribution = .EqualCentering
        self.alignment = .Center
        self.spacing = 10
        self.addArrangedSubview(label)
        self.addArrangedSubview(divider)
        self.addArrangedSubview(imageview)
        
        self.addConstraint(NSLayoutConstraint(item: imageview, attribute: .Height, relatedBy: .Equal, toItem: self, attribute: .Height, multiplier: 0.8, constant: 0))
        self.addConstraint(NSLayoutConstraint(item: imageview, attribute: .Width, relatedBy: .Equal, toItem: imageview, attribute: .Height, multiplier: 1, constant: 0))
        
        self.addConstraint(NSLayoutConstraint(item: label, attribute: .Height, relatedBy: .Equal, toItem: self, attribute: .Height, multiplier: 1, constant: 0))
        self.addConstraint(NSLayoutConstraint(item: label, attribute: .Width, relatedBy: .Equal, toItem: label, attribute: .Width, multiplier: 1, constant: 0))
        
        self.addConstraint(divider.bindAttribute(.Height, toView: imageview))
        self.addConstraint(divider.exactAttributeConstraint(.Width, value: 2, relatedTo: nil))
        
        if isDebugging {self.backgroundColor = UIColor.purpleColor()}
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

/// A vertical stackview containing CricketClosedColumnRows
class CricketClosedColumn: UIView {
    let closeStack:UIStackView = UIStackView()
    let numbers = [15,16,17,18,19,20,25]
    
    
    init() {
        super.init(frame: CGRectZero)
        
        self.backgroundColor = kColorBlack
        self.applyDropShadow()
        if isDebugging {self.backgroundColor = UIColor.redColor()}
        
        closeStack.axis = .Vertical
        closeStack.distribution = .EqualSpacing
        closeStack.alignment = .Center
        closeStack.spacing = 10
        closeStack.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(closeStack)
        
        for number in numbers {
            let row = CricketClosedColumnRow(number: number)
            
            closeStack.addArrangedSubview(row)
            closeStack.addConstraint(NSLayoutConstraint(item: row, attribute: .Height, relatedBy: .Equal, toItem: closeStack, attribute: .Height, multiplier: 0.128, constant: 0))
            closeStack.addConstraint(NSLayoutConstraint(item: row, attribute: .Width, relatedBy: .Equal, toItem: row, attribute: .Height, multiplier: 2.1, constant: 0))
            closeStack.addConstraint(NSLayoutConstraint(item: row, attribute: .CenterX, relatedBy: .Equal, toItem: closeStack, attribute: .CenterX, multiplier: 1, constant: 0))
        }
        
        self.addConstraints(closeStack.fullVerticalConstraint)
        self.addConstraints(closeStack.fullHorizontalConstraint)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

/// A horizontal stackview of CricketClosedColumns for each player
class CricketClosedDisplay: UIView {
    
    let columnStack:UIStackView = UIStackView()
    
    /**
     Update the close stage to ... for player
     
     - parameter index:       Index of the player in a list of players
     - parameter closeNumber: The number to be updated
     - parameter toStage:     The stage of closure.
     */
    func updateCloseStageFor(index:Int, closeNumber:Int, toStage:Int) {
        let spacerAdj = GlobalVariables.sharedVariables.currentGame!.players.count > 2 ? 0 : 1
        let adjustedIndex = index + spacerAdj
        let column = columnStack.arrangedSubviews[adjustedIndex] as! CricketClosedColumn
        let row = column.closeStack.arrangedSubviews[column.numbers.indexOf(closeNumber)!] as! CricketClosedColumnRow
        row.setCloseStage(toStage)
    }
    
    func applyColumnConstraintsTo(column:UIView) {
        columnStack.addConstraint(NSLayoutConstraint(item: column, attribute: .Width, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1, constant: 300))
        columnStack.addConstraint(NSLayoutConstraint(item: column, attribute: .Height, relatedBy: .Equal, toItem: columnStack, attribute: .Height, multiplier: 1, constant: 0))
    }
    
    /**
     Add a blank column for aligning the other (visible) columns to the player bar at the bottom of the screen
     */
    func addBlankColumn() {
        let column = UIView()
        if isDebugging {column.backgroundColor = UIColor.redColor()}
        column.translatesAutoresizingMaskIntoConstraints = false
        columnStack.addArrangedSubview(column)
        applyColumnConstraintsTo(column)
    }
    
    init(numPlayers:Int) {
        super.init(frame: CGRectZero)
        
        self.translatesAutoresizingMaskIntoConstraints = false
        
        if isDebugging {self.backgroundColor = UIColor.greenColor()}
        
        columnStack.axis = .Horizontal
        columnStack.spacing = 10
        columnStack.distribution = .EqualSpacing
        columnStack.alignment = .Center
        
        if numPlayers <= 2 {addBlankColumn()}
        
        // Create a CricketClosedColumn and apply its constraints for every player
        for _ in 0..<numPlayers {
            let column = CricketClosedColumn()
            column.translatesAutoresizingMaskIntoConstraints = false
            columnStack.addArrangedSubview(column)
            applyColumnConstraintsTo(column)
        }
        
        if numPlayers <= 2 {addBlankColumn()}
        
        self.addSubview(columnStack)
        columnStack.translatesAutoresizingMaskIntoConstraints = false
        self.addConstraints(columnStack.fullVerticalConstraint)
        self.addConstraints(columnStack.fullHorizontalConstraint)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
