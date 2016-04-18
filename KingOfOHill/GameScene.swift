//
//  GameScene.swift
//  KingOfOHill
//
//  Created by Dylan Hellems on 4/2/16.
//  Copyright (c) 2016 Dylan Hellems. All rights reserved.
//

import SpriteKit
import CoreLocation

class GameScene: SKScene, CLLocationManagerDelegate {
    
    let _locManager = CLLocationManager()
    
    var menuButton = SKSpriteNode()
    let menuButtonTex = SKTexture(imageNamed: "Menu")
    
    override func didMoveToView(view: SKView) {
        
        /* Setup your scene here */
        let myLabel = SKLabelNode(fontNamed:"Chalkduster")
        myLabel.text = "Hello, World!"
        myLabel.fontSize = 45
        myLabel.position = CGPoint(x:CGRectGetMidX(self.frame), y:CGRectGetMidY(self.frame))
        
        self.addChild(myLabel)
        
        menuButton = SKSpriteNode(texture: menuButtonTex)
        let menuButtonSize = menuButton.size
        let screenSize = UIScreen.mainScreen().bounds.size
        menuButton.position = CGPointMake(frame.midX - screenSize.width/2 + menuButtonSize.width/2, frame.minY + menuButtonSize.height/2)
        self.addChild(menuButton)
        
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

                let location = touch.locationInNode(self)
                
                let sprite = SKSpriteNode(imageNamed:"Spaceship")
            
                sprite.xScale = 0.5
                sprite.yScale = 0.5
                sprite.position = location
            
                let action = SKAction.rotateByAngle(CGFloat(M_PI), duration:1)
            
                sprite.runAction(SKAction.repeatActionForever(action))
            
                self.addChild(sprite)
                
                createAlert()
            }
            
        }
    }
   
    override func update(currentTime: CFTimeInterval) {
        
        /* Called before each frame is rendered */
        
    }
    
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
