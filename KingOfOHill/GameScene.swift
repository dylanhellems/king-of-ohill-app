//
//  GameScene.swift
//  KingOfOHill
//
//  Created by Dylan Hellems on 4/2/16.
//  Copyright (c) 2016 Dylan Hellems. All rights reserved.
//

import SpriteKit

class GameScene: SKScene {
    
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
            }
            
        }
    }
   
    override func update(currentTime: CFTimeInterval) {
        
        /* Called before each frame is rendered */
        
    }
}
