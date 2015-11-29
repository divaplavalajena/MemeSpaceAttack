//
//  GameOverScene.swift
//  MemeSpaceAttack
//
//  Created by Matthew Waller on 11/24/15.
//  Copyright © 2015 Matthew Waller. All rights reserved.
//

import UIKit
import SpriteKit

class GameOverScene: SKScene {
    
    // Private GameScene Properties
    
    var contentCreated = false
    
    // Object Lifecycle Management
    
    // Scene Setup and Content Creation
    
    override func didMoveToView(view: SKView) {
        print("moved here")
        if (!self.contentCreated) {
            self.createContent()
            self.contentCreated = true
        }
        
    }
    
    func createContent() {
        
        let gameOverLabel = SKLabelNode(fontNamed: "Courier")
        gameOverLabel.fontSize = 50
        gameOverLabel.fontColor = SKColor.whiteColor()
        gameOverLabel.text = "Game Over!"
        gameOverLabel.position = CGPointMake(self.size.width/2, 2.0 / 3.0 * self.size.height);
        
        self.addChild(gameOverLabel)
        
        let tapLabel = SKLabelNode(fontNamed: "Courier")
        tapLabel.fontSize = 25
        tapLabel.fontColor = SKColor.whiteColor()
        tapLabel.text = "(Click to Play Again)"
        tapLabel.position = CGPointMake(self.size.width/2, gameOverLabel.frame.origin.y - gameOverLabel.frame.size.height - 40);
        
        self.addChild(tapLabel)
        
        // black space color
        self.backgroundColor = SKColor.blackColor()
 }
}