//
//  MenuViewController.swift
//  MemeSpaceAttack
//
//  Created by Matthew Waller on 11/24/15.
//  Copyright © 2015 Matthew Waller. All rights reserved.
//

import Foundation

import UIKit

class MenuViewController: UIViewController {
    

    
    var invaderMeme: String!
    var invaderSize: CGSize!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func memeButton1Pressed(sender: UIButton) {
        
        print("meme clicked")
        
        invaderMeme = "LaserShark"
        invaderSize = CGSize(width: 22, height: 64)
        
        let gameViewController = self.storyboard?.instantiateViewControllerWithIdentifier("GameViewController") as! GameViewController
        
        gameViewController.invaderMeme = invaderMeme
        gameViewController.invaderSize = invaderSize
        
        self.presentViewController(gameViewController, animated: true, completion: nil)
    }
   
    @IBAction func memeButton2Pressed(sender: UIButton) {
        
        invaderMeme = "Invader"
        invaderSize = CGSize(width: 48, height: 32)
        
        let gameViewController = self.storyboard?.instantiateViewControllerWithIdentifier("GameViewController") as! GameViewController
        
        gameViewController.invaderMeme = invaderMeme
        gameViewController.invaderSize = invaderSize
        
        self.presentViewController(gameViewController, animated: true, completion: nil)
        
    }
    
    @IBAction func memeButton3Pressed(sender: UIButton) {
    }
    
   
    @IBAction func memeButton4Pressed(sender: UIButton) {
    }
    
}
