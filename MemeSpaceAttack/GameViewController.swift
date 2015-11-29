//
//  GameViewController.swift
//  MemeSpaceAttack
//
//  Created by Matthew Waller on 11/24/15.
//  Copyright (c) 2015 Matthew Waller. All rights reserved.
//

import UIKit
import SpriteKit

class GameViewController: UIViewController {
    
    var gameScene: GameScene?
    
    var invaderMeme: String!
    var invaderSize: CGSize!
    
    
    func configureGestureRecognizers() {
        let tapRecognizer = UITapGestureRecognizer(target: self, action: "selectTarget:")
        
        let swipeRightRecognizer = UISwipeGestureRecognizer(target: self, action: "swipeRightTarget:")
        swipeRightRecognizer.direction = .Right
        
        let swipeLeftRecognizer = UISwipeGestureRecognizer(target: self, action: "swipeLeftTarget:")
        swipeLeftRecognizer.direction = .Left
        
        view.addGestureRecognizer(tapRecognizer)
        view.addGestureRecognizer(swipeLeftRecognizer)
        view.addGestureRecognizer(swipeRightRecognizer)
        
    }
    
    func selectTarget( recognizer: UITapGestureRecognizer ) {
        
        
        let skView = self.view as! SKView
        
        if skView.scene == gameScene {
            gameScene?.fireMissle()
        } else {
            print("gameovertriggeredhere")
            self.view.hidden = true
            self.dismissViewControllerAnimated(false, completion: nil)
                   }
    }
    
    func swipeRightTarget( recognizer: UISwipeGestureRecognizer ) {
        
        gameScene?.moveRight()
    }
    
    func swipeLeftTarget( recognizer: UISwipeGestureRecognizer ) {
        
        gameScene?.moveLeft()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // self.view.hidden = false
        
        //create the backgroundimage

        
        if let scene = GameScene(fileNamed: "GameScene") {
            // Configure the view.
            let skView = self.view as! SKView
            
            /* Sprite Kit applies additional optimizations to improve rendering performance */
            skView.ignoresSiblingOrder = false
            
            /* Set the scale mode to scale to fit the window */
            scene.scaleMode = .ResizeFill
            
            //            invaderMeme = "Invader"
            //            invaderSize = CGSize(width: 48, height: 32)
            
            scene.invaderMeme = invaderMeme
            
            scene.invaderSize = invaderSize
            
            skView.presentScene(scene)
            
            gameScene = scene
            
            configureGestureRecognizers()
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }
    
    
   }
