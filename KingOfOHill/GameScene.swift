//
//  GameScene.swift
//  KingOfOHill
//
//  Created by Dylan Hellems on 4/2/16.
//  Copyright (c) 2016 Dylan Hellems. All rights reserved.
//
// Based much of base game components on a tutorial found at https://www.raywenderlich.com/87231/make-game-like-mega-jump-sprite-kit-swift-part-1

import SpriteKit
import CoreLocation
import CoreMotion

class GameScene: SKScene, CLLocationManagerDelegate, SKPhysicsContactDelegate {
    
    // Layered Nodes
    var foregroundNode: SKNode!
    var hudNode: SKNode!
    
    var player: SKNode!
    
    var tapToStartNode: SKNode!
    
    var foods: [GameObjectNode]!
    var foodsCount: Int!
    
    var score: Int!
    var scoreNode: SKLabelNode!
    
    var menuButton: SKSpriteNode!
    
    let heightConstant = CGFloat(220 * 16)
    
    var scaleFactor: CGFloat!
    var lastIndex: Int!
    var nextHeight: CGFloat!
    var maxHeight: CGFloat!
    
    // Location manager for gps
    let _locManager = CLLocationManager()
    
    // Motion manager for accelerometer
    let motionManager = CMMotionManager()
    
    // Acceleration value from accelerometer
    var xAcceleration: CGFloat = 0.0
    
    override func didMoveToView(view: SKView) {
        
        scaleFactor = self.size.width / 320.0
        lastIndex = 0
        nextHeight = heightConstant
        maxHeight = 0
        foodsCount = 3
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("pauseGameScene"), name: "PauseGameScene", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("addFood"), name: "AddFood", object: nil)
        
        self.backgroundColor = UIColor.orangeColor()
        
        // Create the game nodes
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
        
        score = 0
        scoreNode = SKLabelNode(text: "\(score)")
        scoreNode.position = CGPointMake(325, frame.maxY - 50)
        scoreNode.fontName = "SanFranciscoDisplay-Black"
        hudNode.addChild(scoreNode)
        
        let menuButtonTex = SKTexture(imageNamed: "Menu")
        menuButton = SKSpriteNode(texture: menuButtonTex)
        let menuButtonSize = menuButton.size
        menuButton.position = CGPointMake(325, frame.minY + menuButtonSize.height/2)
        hudNode.addChild(menuButton)
        
        // Create player
        player = createPlayer()
        foregroundNode.addChild(player)
        
        foods = [GameObjectNode]()
        
        // Add a food
        for i in 1...3 {
            let food = createFoodAtPosition(CGPoint(x: 160, y: 220 * i))
            foods.append(food)
            foregroundNode.addChild(food)
        }
        
        // Config physics
        physicsWorld.contactDelegate = self
        physicsWorld.gravity = CGVector(dx: 0.0, dy: -2.0)
        
        motionManager.accelerometerUpdateInterval = 0.2
        motionManager.startAccelerometerUpdatesToQueue(NSOperationQueue.currentQueue()!, withHandler: { (accelerometerData:CMAccelerometerData?, error: NSError?) in
            let acceleration = accelerometerData!.acceleration
            self.xAcceleration = (CGFloat(acceleration.x) * 0.75) + (self.xAcceleration * 0.50)
        })
        
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
                    
                    if self.view?.paused == true {
                        self.view?.paused = false
                        self.scene?.paused = false
                        tapToStartNode.hidden = true
                    }
                    
                    return
                }
                
                // Remove the Tap to Start node
                tapToStartNode.hidden = true
                
                // Start the player by putting them into the physics simulation
                player.physicsBody?.dynamic = true
                
                player.physicsBody?.applyImpulse(CGVector(dx: 0.0, dy: 100.0))
                
            }
            
        }
    }
   
    override func update(currentTime: CFTimeInterval) {
   
        
        if player != nil {
            
            if player.position.y > maxHeight {
                maxHeight = player.position.y
            }
            
            // Calculate player y offset
            if player.position.y > 200.0 && player.position.y >= maxHeight {
                foregroundNode.position = CGPoint(x: 0.0, y: -(player.position.y - 200.0))
            }
            
            if player.position.y < maxHeight - 500 {
                print("lose")
                self.scene?.paused = true
                postScore()
            }
            
            if foods.count > 0 {
                for food in foods {
                    if food.checkNodeRemoval(player.position.y) == true {
                        foods.removeAtIndex(foods.indexOf(food)!)
                    }
                }
            }
            
        }
        
    }
    
    func pauseGameScene() {
        print("pause game")
        tapToStartNode.hidden = false
        self.view?.paused = true
        self.scene?.paused = true
    }
    
    override func didSimulatePhysics() {
        
        if player != nil {
            
            // Set velocity based on x-axis acceleration
            player.physicsBody?.velocity = CGVector(dx: xAcceleration * 400.0, dy: player.physicsBody!.velocity.dy)
            
            print(player.position.x)
        
            // Check x bounds
            if player.position.x < 320 {
                player.position = CGPoint(x: 320, y: player.position.y)
            } else if (player.position.x > 690) {
                player.position = CGPoint(x: 690, y: player.position.y)
            }
        }
    }
    
    func didBeginContact(contact: SKPhysicsContact) {

        var updateHUD = false
        

        let whichNode = (contact.bodyA.node != player) ? contact.bodyA.node : contact.bodyB.node
        let other = whichNode as! GameObjectNode
        

        updateHUD = other.collisionWithPlayer(player)
        
        // Update the HUD if necessary
        if updateHUD {
            
            foods.removeAtIndex(foods.indexOf(other)!)
            
            score = score + 1
            scoreNode.text = "\(score)"
            
        }
        
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
    
    func addFood() {
        foodsCount = foodsCount + 1
        let food = createFoodAtPosition(CGPoint(x: Int(arc4random_uniform(120) + 100), y: 220 * foodsCount))
        foods.append(food)
        foregroundNode.addChild(food)
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
    
    func postScore() {
        let rest = RestApiManager()
        
        let defaults = NSUserDefaults.standardUserDefaults()
        let name = defaults.stringForKey("id")!
        
        let nearestLoc = getNearestDiningHall()
        let nearestTime = getNearestTimeSlot()
        
        rest.add_score(name, score: "\(score)", time: "\(nearestTime)", location: "\(nearestLoc)", callback: { (response) in
            self.createAlert("\(response["message"]!)")
        })
    }
    
    func createAlert(title: String) {
        let nearestLoc = getNearestDiningHall()
        let nearestTime = getNearestTimeSlot()
        
        let defaults = NSUserDefaults.standardUserDefaults()
        let name = defaults.stringForKey("name")!
        
        let message = "Nickname: \(name), Score: \(score), Dining Hall: \(locations[nearestLoc]), Meal Time: \(timeSlots[nearestTime])"
        let alert = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        
        alert.addAction(UIAlertAction(title: "Menu", style: .Default, handler: {(UIAlertAction) in
            if let view = self.view {
                let scene = MenuScene(fileNamed: "MenuScene")
                scene!.scaleMode = SKSceneScaleMode.AspectFill
                view.presentScene(scene)
            }
        }))
        
        alert.addAction(UIAlertAction(title: "Play Again", style: .Default, handler: { (UIAlertAction) in
            let gameScene = GameScene(size: self.size)
            let transition = SKTransition.doorsCloseHorizontalWithDuration(0.5)
            gameScene.scaleMode = SKSceneScaleMode.AspectFill
            self.scene!.view?.presentScene(gameScene, transition: transition)
        }))
        
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
