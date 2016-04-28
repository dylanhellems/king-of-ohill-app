//
//  GameScene.swift
//  KingOfOHill
//
//  Created by Dylan Hellems on 4/2/16.
//  Copyright (c) 2016 Dylan Hellems. All rights reserved.
//
// Based much of main game components on a tutorial found at https://www.raywenderlich.com/87231/make-game-like-mega-jump-sprite-kit-swift-part-1

import SpriteKit
import CoreLocation

class GameScene: SKScene, CLLocationManagerDelegate, SKPhysicsContactDelegate {
    
    // Layered Nodes
    var backgroundNode: SKNode!
    var foregroundNode: SKNode!
    var hudNode: SKNode!
    
    var player: SKNode!
    
    var tapToStartNode: SKNode!
    
    var foods: [SKNode]!
    
    var score: Int!
    var scoreNode: SKLabelNode!
    
    // To Accommodate iPhone 6
    var scaleFactor: CGFloat!
    
    let _locManager = CLLocationManager()
    
    var menuButton = SKSpriteNode()
    let menuButtonTex = SKTexture(imageNamed: "Menu")
    
    override func didMoveToView(view: SKView) {
        
        scaleFactor = self.size.width / 320.0
        
        
        // Create the game nodes
        backgroundNode = createBackgroundNode()
        self.addChild(backgroundNode)
        
        foregroundNode = SKNode()
        foregroundNode.zPosition = 1
        self.addChild(foregroundNode)
        
        hudNode = SKNode()
        hudNode.zPosition = 2
        self.addChild(hudNode)
        
        // Create HUD
        tapToStartNode = SKSpriteNode(imageNamed: "TapToStart")
        tapToStartNode.position = CGPoint(x: self.size.width / 2, y: 180.0)
        hudNode.addChild(tapToStartNode)
        
        let screenSize = UIScreen.mainScreen().bounds.size
        
        score = 0
        scoreNode = SKLabelNode(text: "\(score)")
        scoreNode.position = CGPointMake(frame.midX - screenSize.width/2 + 20, frame.maxY - 50)
        scoreNode.fontName = "SanFranciscoDisplay-Black"
        hudNode.addChild(scoreNode)
        
        menuButton = SKSpriteNode(texture: menuButtonTex)
        let menuButtonSize = menuButton.size
        menuButton.position = CGPointMake(frame.midX - screenSize.width/2 + menuButtonSize.width/2, frame.minY + menuButtonSize.height/2)
        hudNode.addChild(menuButton)
        
        // Create player
        player = createPlayer()
        foregroundNode.addChild(player)
        
        foods = [SKNode]()
        
        // Add a food
        for i in 1...3 {
            foods.append(createFoodAtPosition(CGPoint(x: 160, y: 220 * i)))
            foregroundNode.addChild(foods[i - 1])
        }
        
        // Config physics
        physicsWorld.contactDelegate = self
        physicsWorld.gravity = CGVector(dx: 0.0, dy: -2.0)
        
        runLocationServices()
        
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {

        /* Called when a touch begins */
        for touch in touches {
            
            let pos = touch.locationInNode(self)
            let node = self.nodeAtPoint(pos)
            
            if node == menuButton {
                if let view = view {
                    let scene = MenuScene(fileNamed: "MenuScene")
                    scene!.scaleMode = SKSceneScaleMode.AspectFill
                    view.presentScene(scene)
                }
            } else {
                
                // If we're already playing, ignore touches
                if player.physicsBody!.dynamic {
                    return
                }
                
                // Remove the Tap to Start node
                tapToStartNode.removeFromParent()
                
                // Start the player by putting them into the physics simulation
                player.physicsBody?.dynamic = true
                
                player.physicsBody?.applyImpulse(CGVector(dx: 0.0, dy: 20.0))
                
            }
            
        }
    }
   
    override func update(currentTime: CFTimeInterval) {
        
        // Calculate player y offset
        if player != nil && player.position.y > 200.0 {
            backgroundNode.position = CGPoint(x: 0.0, y: -((player.position.y - 200.0)))
            foregroundNode.position = CGPoint(x: 0.0, y: -(player.position.y - 200.0))
        }
        
    }
    
    func didBeginContact(contact: SKPhysicsContact) {

        var updateHUD = false
        

        let whichNode = (contact.bodyA.node != player) ? contact.bodyA.node : contact.bodyB.node
        let other = whichNode as! GameObjectNode
        

        updateHUD = other.collisionWithPlayer(player)
        
        // Update the HUD if necessary
        if updateHUD {
            
            let num_foods = foods.count + 1
            foods.append(createFoodAtPosition(CGPoint(x: 160, y: 220 * num_foods)))
            foregroundNode.addChild(foods[num_foods - 1])
            
            score = score + 1
            scoreNode.text = "\(score)"
            
        }
        
    }
    
    func createBackgroundNode() -> SKNode {
        
        // Create the node
        let backgroundNode = SKNode()
        let ySpacing = 64 * scaleFactor
        
        // Go through images until the entire background is built
        for index in 0...19 {

            let node = SKSpriteNode(imageNamed:String(format: "Background%02d", index + 1))

            node.setScale(scaleFactor)
            node.anchorPoint = CGPoint(x: 0.5, y: 0.0)
            node.position = CGPoint(x: self.size.width / 2, y: ySpacing * CGFloat(index))

            backgroundNode.addChild(node)
        }
        
        // Return the completed background node
        return backgroundNode
        
    }
    
    func createPlayer() -> SKNode {
        let playerNode = SKNode()
        playerNode.position = CGPoint(x: self.size.width / 2, y: 80.0)
        
        let sprite = SKSpriteNode(imageNamed: "Player")
        playerNode.addChild(sprite)
        
        // Config physics body
        playerNode.physicsBody = SKPhysicsBody(circleOfRadius: sprite.size.width / 2)
        playerNode.physicsBody?.dynamic = false
        playerNode.physicsBody?.allowsRotation = false
        playerNode.physicsBody?.restitution = 1.0
        playerNode.physicsBody?.friction = 0.0
        playerNode.physicsBody?.angularDamping = 0.0
        playerNode.physicsBody?.linearDamping = 0.0
        
        playerNode.physicsBody?.usesPreciseCollisionDetection = true
        playerNode.physicsBody?.categoryBitMask = CollisionCategoryBitmask.Player
        playerNode.physicsBody?.collisionBitMask = 0
        playerNode.physicsBody?.contactTestBitMask = CollisionCategoryBitmask.Food | CollisionCategoryBitmask.Platform
        
        return playerNode
    }

    func createFoodAtPosition(position: CGPoint) -> FoodNode {

        let node = FoodNode()
        let thePosition = CGPoint(x: position.x * scaleFactor, y: position.y)
        node.position = thePosition
        node.name = "NODE_FOOD"
    
        var sprite: SKSpriteNode
        sprite = SKSpriteNode(imageNamed: "Star")
        node.addChild(sprite)
    
        node.physicsBody = SKPhysicsBody(circleOfRadius: sprite.size.width / 2)
        node.physicsBody?.dynamic = false
        
        node.physicsBody?.categoryBitMask = CollisionCategoryBitmask.Food
        node.physicsBody?.collisionBitMask = 0
        
        return node
    }
    
    // Location Stuff
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let loc = locations[0] as CLLocation
        print(loc)
    }
    
    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        print(status)
        if (status == CLAuthorizationStatus.AuthorizedAlways || status == CLAuthorizationStatus.AuthorizedWhenInUse) {
            _locManager.startUpdatingLocation()
        }
    }
    
    func runLocationServices() {
        _locManager.delegate = self
        _locManager.distanceFilter = kCLDistanceFilterNone
        _locManager.desiredAccuracy = kCLLocationAccuracyBest
        _locManager.requestWhenInUseAuthorization()
        _locManager.startUpdatingLocation()
    }
    
    let locations = ["OHill", "Runk", "Newcomb"]
    let timeSlots = ["Breakfast", "Lunch", "Dinner", "Midnight Snack"]
    
    func createAlert() {
        let nearestLoc = getNearestDiningHall()
        let nearestTime = getNearestTimeSlot()
        
        let defaults = NSUserDefaults.standardUserDefaults()
        let name = defaults.stringForKey("name")!
        
        let message = "Nickname: \(name), Score: 1000, Dining Hall: \(locations[nearestLoc]), Meal Time: \(timeSlots[nearestTime])"
        let alert = UIAlertController(title: "New High Score", message: message, preferredStyle: .Alert)
        
        alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
        
        self.view?.window?.rootViewController?.presentViewController(alert, animated: true, completion: nil)
    }
    
    func getNearestDiningHall() -> NSInteger {
        let OHill = (38.0349233, -78.5147533)
        let Runk = (38.02876655, -78.518471)
        let Newcomb = (38.03627, -78.506753)
        let locs = [OHill, Runk, Newcomb]
        
        let loc = _locManager.location
        
        var leastDist = CLLocationDistance(0)
        var leastLoc = -1
        for (index, (lat, long)) in locs.enumerate() {
            let dist = CLLocation(latitude: lat , longitude: long).distanceFromLocation(loc!)
            
            if leastDist == 0 || dist < leastDist {
                leastDist = dist
                leastLoc = index
            }
            print("dist \(dist)")
        }
        
        return leastLoc
    }
    
    func getNearestTimeSlot() -> NSInteger {
        let date = _locManager.location?.timestamp
        let calendar = NSCalendar.currentCalendar()
        let components = calendar.components(.Hour, fromDate: date!)
        let hour = components.hour
        print("hour: \(hour)")
        
        if hour > 6 && hour <= 11 {
            return 0
        } else if hour > 11 && hour <= 16 {
            return 1
        } else if hour > 16 && hour <= 21 {
            return 2
        } else {
            return 3
        }
    }
    
}
