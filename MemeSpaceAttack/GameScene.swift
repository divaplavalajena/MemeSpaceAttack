//
//  GameScene.swift
//  MemeSpaceAttack
//
//  Created by Matthew Waller on 11/24/15.
//  Copyright (c) 2015 Matthew Waller. All rights reserved.
//

import SpriteKit


class GameScene: SKScene, SKPhysicsContactDelegate {
    
    // Game End
    var gameEnding: Bool = false
    
    // Contact
    var contactQueue = Array<SKPhysicsContact>()
    
    // Bitmask Categories
    let kInvaderCategory: UInt32 = 0x1 << 0
    let kShipFiredBulletCategory: UInt32 = 0x1 << 1
    let kShipCategory: UInt32 = 0x1 << 2
    let kSceneEdgeCategory: UInt32 = 0x1 << 3
    let kInvaderFiredBulletCategory: UInt32 = 0x1 << 4
    
    // Bullet type
    enum BulletType {
        case ShipFired
        case InvaderFired
    }
    
    // Invader movement direction
    enum InvaderMovementDirection {
        case Right
        case Left
        case DownThenRight
        case DownThenLeft
        case None
    }
    
    //1
    enum InvaderType {
        case A
        case B
        case C
    }
    
    var invaderMeme: String!
    var invaderSize: CGSize!
    
    //2
    let kInvaderSize = CGSize(width: 48, height: 32)
    let kInvaderGridSpacing = CGSize(width: 12, height: 12)
    let kInvaderRowCount = 6
    let kInvaderColCount = 6
    
    // 3
    let kInvaderName = "invader"
    
    // 4
    let kShipSize = CGSize(width: 30, height: 16)
    let kShipName = "ship"
    var ship : SKSpriteNode? { return childNodeWithName(kShipName) as? SKSpriteNode }
    
    // 5
    let kScoreHudName = "scoreHud"
    let kHealthHudName = "healthHud"
    
    let kMinInvaderBottomHeight: Float = 32.0
    
    
    // Score and Health
    var score: Int = 0
    var shipHealth: Float = 1.0
    
    // Bullets utils
    let kShipFiredBulletName = "shipFiredBullet"
    let kInvaderFiredBulletName = "invaderFiredBullet"
    let kBulletSize = CGSize(width:4, height: 8)
    
    // Private GameScene Properties
    
    var contentCreated: Bool = false
    
    // Invaders Properties
    var invaderMovementDirection: InvaderMovementDirection = .Right
    var timeOfLastMove: CFTimeInterval = 0.0
    var timePerMove: CFTimeInterval = 1.0
    
    var backgroundNode: SKSpriteNode!
    
    // Queue
    var tapQueue: Array<Int> = []
    
    
    
    //For starry background
    
    // scene bounderies
    let lower_x_boud : CGFloat = 0.0
    let lower_y_boud : CGFloat = 0.0
    var higher_x_bound : CGFloat = 0.0
    var higher_y_bound : CGFloat = 0.0
    
    //star layers one properties
    var star_layer : [[SKSpriteNode]] = []
    var star_layer_speed : [CGFloat]  = []
    var star_layer_color : [SKColor] = []
    var star_layer_count : [Int] = []
    
    // scroll direction
    var x_dir: CGFloat = 0.0
    var y_dir: CGFloat = -1.0
    
    
    //deltaTime
    var lastUpdate : NSTimeInterval = 0
    // 1/60 ~> 0.0166
    var deltaTime : CGFloat = 0.01666
    
    // used to demo 8 way scrolling
    var currentDir = 1
    
    
    // Object Lifecycle Management
    
    // Scene Setup and Content Creation
    override func didMoveToView(view: SKView) {
        
        if (!self.contentCreated) {
            self.createContent()
            self.contentCreated = true
            
            // SKScene responds to touches
            self.userInteractionEnabled = true
            
            self.physicsWorld.contactDelegate = self
            
            backgroundColor = SKColor.blackColor()
            
            
            //star background
            
            // set the boundries
            higher_x_bound = self.frame.width
            higher_y_bound = self.frame.height
            
            
            // create a dummy sprite
            let dummySprite = SKSpriteNode(imageNamed: "star")
            
            // create the 3 star layers
            star_layer = [[dummySprite],[dummySprite],[dummySprite]]
            
            //set layer 0
            star_layer_count.append(50)
            star_layer_speed.append(30.0)
            star_layer_color.append(SKColor.whiteColor())
            
            //set layer 1
            star_layer_count.append(50)
            star_layer_speed.append(20.0)
            star_layer_color.append(SKColor.yellowColor())
            
            //set layer 2
            star_layer_count.append(50)
            star_layer_speed.append(10.0)
            star_layer_color.append(SKColor.redColor())
            
            
            
            
            //draw all the stars in all the layers
            for starLayers in 0...2 {
                
                //draw all the stars in a single layer
                for _ in 1...star_layer_count[starLayers] {
                    
                    
                    let sprite = SKSpriteNode(imageNamed: "star.png")
                    // get a random position for the star
                    let x_pos = CGFloat(Float(arc4random()) / Float(UINT32_MAX)) * higher_x_bound
                    let y_pos = CGFloat(Float(arc4random()) / Float(UINT32_MAX)) * higher_y_bound
                    sprite.position = CGPointMake(x_pos, y_pos)
                    // set the correct color for the star in that layer
                    sprite.colorBlendFactor = 1.0
                    sprite.color = star_layer_color[starLayers]
                    star_layer[starLayers].append(sprite)
                    self.addChild(sprite)
                    
                }
            }
            
//            backgroundNode = SKSpriteNode(imageNamed: "SpaceBackground.png")
//            backgroundNode.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame))
//            backgroundNode.size = self.frame.size
//            backgroundNode.name = "Background"
//            backgroundNode.blendMode = .Screen
//            backgroundNode.zPosition = -1
//            self.insertChild(backgroundNode, atIndex: 0)
        }
    }
    
    
    func createContent() {
        
        
        physicsBody = SKPhysicsBody(edgeLoopFromRect: self.frame)
        
        physicsBody!.categoryBitMask = kSceneEdgeCategory
        
        setupInvaders()
        
        setupShip()
        
        setupHud()
        
        // 2 black space color
        self.backgroundColor = SKColor.blackColor()
    }
    
    
    func loadInvaderTexturesOfType(invaderType: InvaderType) -> Array<SKTexture> {
        var prefix: String
        
        switch(invaderType) {
        case .A:
            prefix = String(format: "%@A", invaderMeme)//  "InvaderA"
        case .B:
            prefix = String(format: "%@B", invaderMeme)
        case .C:
            prefix = String(format: "%@C", invaderMeme)
        }
        
        return [SKTexture(imageNamed: String(format: "%@_00.png", prefix)),
            SKTexture(imageNamed: String(format: "%@_01.png", prefix))]
    }

    
    func makeInvaderOfType(invaderType: InvaderType) -> SKNode {
        
        let invaderTextures = self.loadInvaderTexturesOfType(invaderType)
        
        let invader = SKSpriteNode(texture: invaderTextures[0])
        invader.name = kInvaderName
        invader.size = invaderSize
        
        invader.runAction(SKAction.repeatActionForever(SKAction.animateWithTextures(invaderTextures, timePerFrame: self.timePerMove)))
        
        // invaders' bitmasks setup
        invader.physicsBody = SKPhysicsBody(rectangleOfSize: invader.frame.size)
        invader.physicsBody!.dynamic = false
        invader.physicsBody!.categoryBitMask = kInvaderCategory
        invader.physicsBody!.contactTestBitMask = 0x0
        invader.physicsBody!.collisionBitMask = 0x0
        invader.physicsBody!.usesPreciseCollisionDetection = true
        return invader
    }
    
    
    func setupInvaders() {
        
        // 1
        let baseOrigin = CGPointMake(self.size.width / 3, 180)
        
        for var row = 1; row <= kInvaderRowCount; row++ {
            
            // 2
            var invaderType: InvaderType
            
            if row % 3 == 0 {
                
                invaderType = .A
                
            } else if row % 3 == 1 {
                
                invaderType = .B
                
            } else {
                
                invaderType = .C
            }
            
            // 3
            let invaderPositionY = CGFloat(row) * (kInvaderSize.height * 2) + baseOrigin.y
            
            var invaderPosition = CGPointMake(baseOrigin.x, invaderPositionY)
            
            // 4
            for var col = 1; col <= kInvaderColCount; col++ {
                
                // 5
                let invader = self.makeInvaderOfType(invaderType)
                invader.position = invaderPosition
                self.addChild(invader)
                invaderPosition = CGPointMake(invaderPosition.x + kInvaderSize.width + kInvaderGridSpacing.width, invaderPositionY)
                invader.zPosition = 0
                
            }
            
        }
        
    }
    
    func setupShip() {
        
        // 1
        let ship: SKNode = self.makeShip()
        
        // 2
        ship.position = CGPointMake(self.size.width / 2, kShipSize.height / 2)
        
        self.addChild(ship)
    }
    
    func makeShip() -> SKNode {
        
        let ship = SKSpriteNode(imageNamed: "Ship.png")
        ship.color = UIColor.greenColor()
        ship.name = kShipName
        
        // Physic
        // 1
        ship.physicsBody = SKPhysicsBody(rectangleOfSize: ship.frame.size)
        
        // 2
        ship.physicsBody!.dynamic = true
        
        // 3
        ship.physicsBody!.affectedByGravity = false
        
        // 4
        ship.physicsBody!.mass = 0.02
        
        // ship's bitmask setup
        // 1
        ship.physicsBody!.categoryBitMask = kShipCategory
        
        // 2
        ship.physicsBody!.contactTestBitMask = 0x0
        
        // 3
        ship.physicsBody!.collisionBitMask = kSceneEdgeCategory
        
        return ship
    }
    
    
    func setupHud() {
        
        let scoreLabel = SKLabelNode(fontNamed: "Courier")
        
        // 1
        scoreLabel.name = kScoreHudName
        scoreLabel.fontSize = 25
        
        // 2
        scoreLabel.fontColor = SKColor.greenColor()
        scoreLabel.text = String(format: "Score: %04u", 0)
        
        // 3
        print(self.size.height)
        scoreLabel.position = CGPointMake(self.frame.size.width / 2, self.size.height - (40 + scoreLabel.frame.size.height/2))
        self.addChild(scoreLabel)
        
        let healthLabel = SKLabelNode(fontNamed: "Courier")
        
        // 4
        healthLabel.name = kHealthHudName
        healthLabel.fontSize = 25
        
        // 5
        healthLabel.fontColor = SKColor.redColor()
        healthLabel.text = String(format: "Health: %.1f%%", self.shipHealth * 100.0)
        
        // 6
        healthLabel.position = CGPointMake(self.frame.size.width / 2, self.size.height - (80 + healthLabel.frame.size.height / 2))
        self.addChild(healthLabel)
    }
    
    
    func makeBulletOfType(bulletType: BulletType) -> SKNode! {
        
        var bullet: SKNode!
        
        switch bulletType {
        case .ShipFired:
            bullet = SKSpriteNode(color: SKColor.greenColor(), size: kBulletSize)
            bullet.name = kShipFiredBulletName
            
            bullet.physicsBody = SKPhysicsBody(rectangleOfSize: bullet.frame.size)
            bullet.physicsBody!.dynamic = true
            bullet.physicsBody!.affectedByGravity = false
            bullet.physicsBody!.categoryBitMask = kShipFiredBulletCategory
            bullet.physicsBody!.contactTestBitMask = kInvaderCategory
            bullet.physicsBody!.collisionBitMask = 0x0
            
        case .InvaderFired:
            bullet = SKSpriteNode(color: SKColor.magentaColor(), size: kBulletSize)
            bullet.name = kInvaderFiredBulletName
            
            bullet.physicsBody = SKPhysicsBody(rectangleOfSize: bullet.frame.size)
            bullet.physicsBody!.dynamic = true
            bullet.physicsBody!.affectedByGravity = false
            bullet.physicsBody!.categoryBitMask = kInvaderFiredBulletCategory
            bullet.physicsBody!.contactTestBitMask = kShipCategory
            bullet.physicsBody!.collisionBitMask = 0x0
            
        
        }
        
        return bullet
    }
    
    
    // Scene Update
    
    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
        
        if self.isGameOver() {
            
            self.endGame()
        }
        
        self.processContactsForUpdate(currentTime)
        
        self.processUserTapsForUpdate(currentTime)
        
        
        self.moveInvadersForUpdate(currentTime)
        
        self.fireInvaderBulletsForUpdate(currentTime)
        
        //for star field
        deltaTime = CGFloat( currentTime - lastUpdate)
        lastUpdate = currentTime
        
        if deltaTime > 1.0 {
            deltaTime = 0.0166
        }
        
        //move starfield
        for index in 0...2 {
            
            MoveSingleLayer(star_layer[index], speed: star_layer_speed[index])
            
        }
        

    }
    
    
    //star filed movement
    func MoveSingleLayer(star_layer:[SKSpriteNode],speed:CGFloat) {
        
        var sprite:SKSpriteNode
        var new_x:CGFloat = 0.0
        var new_y:CGFloat = 0.0
        
        for index in 0...star_layer.count-1 {
            
            sprite = star_layer[index]
            new_x = sprite.position.x + x_dir * speed * deltaTime
            new_y = sprite.position.y + y_dir * speed * deltaTime
            
            sprite.position = boundCheck( CGPointMake(new_x, new_y) )
        }
        
        
    }
    
    func boundCheck(pos: CGPoint) -> CGPoint {
        var x = pos.x
        var y = pos.y
        
        
        if x < 0 {
            x += higher_x_bound
        }
        
        if y < 0 {
            
            y += higher_y_bound
        }
        
        if x > higher_x_bound {
            x -= higher_x_bound
        }
        
        if y > higher_y_bound {
            y -= higher_y_bound
        }
        
        return CGPointMake(x, y)
        
    }
    
    //ship movement
    
    func moveLeft() {
        ship?.physicsBody!.applyForce(CGVectorMake(-100.0, 0))
    }
    
    func moveRight() {
        ship?.physicsBody!.applyForce(CGVectorMake(100, 0))
    }
    
    func fireMissle() {
        self.tapQueue.append(1)
    }
    
    
    // Scene Update Helpers
    
    func moveInvadersForUpdate(currentTime: CFTimeInterval) {
        
        // 1
        if (currentTime - self.timeOfLastMove < self.timePerMove) {
            return
        }
        
        // logic to change movement direction
        self.determineInvaderMovementDirection()
        
        // 2
        enumerateChildNodesWithName(kInvaderName) {
            node, stop in
            
            switch self.invaderMovementDirection {
            case .Right:
                node.position = CGPointMake(node.position.x + 10, node.position.y)
                node.zPosition = 0
            case .Left:
                node.position = CGPointMake(node.position.x - 10, node.position.y)
                node.zPosition = 0
            case .DownThenLeft, .DownThenRight:
                node.position = CGPointMake(node.position.x, node.position.y - 10)
                node.zPosition = 0
            case .None:
                break
            }
            
            // 3
            self.timeOfLastMove = currentTime
            
        }
    }
    
    func secureChildNodeWithName(name: String) -> SKSpriteNode! {
        
        var shipNode: SKSpriteNode!
        
        // enumerate to find the ship node
        self.enumerateChildNodesWithName(kShipName) {
            node, stop in
            
            shipNode = node as! SKSpriteNode
            
        }
        
        // if found return it
        if shipNode != nil {
            return shipNode
        } else {
            return nil
        }
    }
    
    
    func processUserTapsForUpdate(currentTime: CFTimeInterval) {
        
        // 1
        for tapCount in self.tapQueue {
            
            if tapCount == 1 {
                
                // 2
                self.fireShipBullets()
            }
            
            // 3
            self.tapQueue.removeAtIndex(0)
        }
    }
    
    
    func fireInvaderBulletsForUpdate(currentTime: CFTimeInterval) {
        
        let existingBullet = self.childNodeWithName(kInvaderFiredBulletName)
        
        // 1
        if existingBullet == nil {
            
            var allInvaders = Array<SKNode>()
            
            // 2
            self.enumerateChildNodesWithName(kInvaderName) {
                node, stop in
                
                allInvaders.append(node)
            }
            
            if allInvaders.count > 0 {
                
                // 3
                let allInvadersIndex = Int(arc4random_uniform(UInt32(allInvaders.count)))
                
                let invader = allInvaders[allInvadersIndex]
                
                // 4
                let bullet = self.makeBulletOfType(.InvaderFired)
                bullet.position = CGPoint(x: invader.position.x, y: invader.position.y - invader.frame.size.height / 2 + bullet.frame.size.height / 2)
                bullet.zPosition = 0
                
                // 5
                let bulletDestination = CGPoint(x: invader.position.x, y: -(bullet.frame.size.height / 2))
                
                // 6
                self.fireBullet(bullet, toDestination: bulletDestination, withDuration: 2.0, andSoundFileName: "InvaderBullet.wav")
            }
        }
    }
    
    
    func processContactsForUpdate(currentTime: CFTimeInterval) {
        
        for contact in self.contactQueue {
            self.handleContact(contact)
            
            if let index = (self.contactQueue as NSArray).indexOfObject(contact) as Int? {
                self.contactQueue.removeAtIndex(index)
            }
        }
    }
    
    // Invader Movement Helpers
    
    func adjustInvaderMovementToTimePerMove(newTimerPerMove: CFTimeInterval) {
        
        // 1
        if newTimerPerMove <= 0 {
            return
        }
        
        // 2
        let ratio: CGFloat = CGFloat(self.timePerMove / newTimerPerMove)
        self.timePerMove = newTimerPerMove
        
        enumerateChildNodesWithName(kInvaderName) {
            node, stop in
            // 3
            node.speed = node.speed * ratio
        }
    }
    
    func determineInvaderMovementDirection() {
        
        // 1
        var proposedMovementDirection: InvaderMovementDirection = self.invaderMovementDirection
        
        // 2
        enumerateChildNodesWithName(kInvaderName) {
            node, stop in
            
            switch self.invaderMovementDirection {
                
            case .Right:
                //3
                if (CGRectGetMaxX(node.frame) >= node.scene!.size.width - 1.0) {
                    proposedMovementDirection = .DownThenLeft
                    
                    stop.memory = true
                }
            case .Left:
                //4
                if (CGRectGetMinX(node.frame) <= 1.0) {
                    proposedMovementDirection = .DownThenRight
                    
                    stop.memory = true
                }
                
            case .DownThenLeft:
                proposedMovementDirection = .Left
                
                // Add the following line
                self.adjustInvaderMovementToTimePerMove(self.timePerMove * 0.8)
                
                stop.memory = true
                
            case .DownThenRight:
                proposedMovementDirection = .Right
                
                // Add the following line
                self.adjustInvaderMovementToTimePerMove(self.timePerMove * 0.8)
                
                stop.memory = true
                
            default:
                break
                
            }
            
        }
        
        //7
        if (proposedMovementDirection != self.invaderMovementDirection) {
            self.invaderMovementDirection = proposedMovementDirection
        }
    }
    
    
    // Bullet Helpers
    
    func fireBullet(bullet: SKNode, toDestination destination:CGPoint, withDuration duration:CFTimeInterval, andSoundFileName soundName: String) {
        
        // 1
        let bulletAction = SKAction.sequence([SKAction.moveTo(destination, duration: duration), SKAction.waitForDuration(3.0/60.0), SKAction.removeFromParent()])
        
        // 2
        let soundAction = SKAction.playSoundFileNamed(soundName, waitForCompletion: true)
        
        // 3
        bullet.runAction(SKAction.group([bulletAction, soundAction]))
        
        // 4
        self.addChild(bullet)
    }
    
    func fireShipBullets() {
        
        if let ship = ship {
            let bullet = self.makeBulletOfType(.ShipFired)
            bullet.position = CGPoint(x: ship.position.x, y: ship.position.y + ship.frame.size.height - bullet.frame.size.height / 2)
            bullet.zPosition = 0
            let bulletDestination = CGPoint(x: ship.position.x, y: self.frame.size.height + bullet.frame.size.height / 2)
            self.fireBullet(bullet, toDestination: bulletDestination, withDuration: 1.0, andSoundFileName: "ShipBullet.wav")
            
        }
    }
    
    
    // HUD Helpers
    
    func adjustScoreBy(points: Int) {
        
        self.score += points
        
        let score = self.childNodeWithName(kScoreHudName) as! SKLabelNode
        
        score.text = String(format: "Score: %04u", self.score)
    }
    
    func adjustShipHealthBy(healthAdjustment: Float) {
        
        // 1
        self.shipHealth = max(self.shipHealth + healthAdjustment, 0)
        
        let health = self.childNodeWithName(kHealthHudName) as! SKLabelNode
        
        health.text = String(format: "Health: %.1f%%", self.shipHealth * 100)
        
    }
    
    // Physics Contact Helpers
    
    func didBeginContact(contact: SKPhysicsContact) {
        
        if contact as SKPhysicsContact? != nil {
            self.contactQueue.append(contact)
        }
    }
    
    func handleContact(contact: SKPhysicsContact) {
        
        // Ensure you haven't already handled this contact and removed its nodes
        if (contact.bodyA.node?.parent == nil || contact.bodyB.node?.parent == nil) {
            return
        }
        
        let nodeNames = [contact.bodyA.node!.name!, contact.bodyB.node!.name!]
        
        if (nodeNames as NSArray).containsObject(kShipName) && (nodeNames as NSArray).containsObject(kInvaderFiredBulletName) {
            
            // Invader bullet hit a ship
            self.runAction(SKAction.playSoundFileNamed("ShipHit.wav", waitForCompletion: false))
            
            // 1
            self.adjustShipHealthBy(-0.334)
            
            if self.shipHealth <= 0.0 {
                
                // 2
                contact.bodyA.node!.removeFromParent()
                contact.bodyB.node!.removeFromParent()
                
            } else {
                
                // 3
                let ship = self.childNodeWithName(kShipName)
                
                ship!.alpha = CGFloat(self.shipHealth)
                
                if contact.bodyA.node == ship {
                    
                    contact.bodyB.node!.removeFromParent()
                    
                } else {
                    
                    contact.bodyA.node!.removeFromParent()
                }
                
            }
            
        } else if (nodeNames as NSArray).containsObject(kInvaderName) && (nodeNames as NSArray).containsObject(kShipFiredBulletName) {
            
            // Ship bullet hit an invader
            self.runAction(SKAction.playSoundFileNamed("InvaderHit.wav", waitForCompletion: false))
            
            print("This is the first zposition \(contact.bodyA.node?.zPosition)")
            print("This is the second zposition \(contact.bodyB.node?.zPosition)")
            
            contact.bodyA.node!.removeFromParent()
            contact.bodyB.node!.removeFromParent()
            
            // 4
            self.adjustScoreBy(100)
        }
    }
    
    
    
    
    
    // Game End Helpers
    
    func isGameOver() -> Bool {
        
        // 1
        let invader = self.childNodeWithName(kInvaderName)
        
        // 2
        var invaderTooLow = false
        
        enumerateChildNodesWithName(kInvaderName) {
            node, stop in
            
            if Float(CGRectGetMinY(node.frame)) <= self.kMinInvaderBottomHeight {
                
                invaderTooLow = true
                stop.memory = true
            }
        }
        
        // 3
        let ship = self.childNodeWithName(kShipName)
        
        // 4
        return invader == nil || invaderTooLow || ship == nil
    }
    
    func endGame() {
        // 1
        if !self.gameEnding {
            
            self.gameEnding = true
            
            let gameOverScene: GameOverScene = GameOverScene(size: self.size)
            
            view!.presentScene(gameOverScene, transition: SKTransition.doorsOpenHorizontalWithDuration(1.0))
        }
    }
    
    
}
