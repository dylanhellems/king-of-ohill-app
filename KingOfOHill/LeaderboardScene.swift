//
//  LeaderboardScene.swift
//  KingOfOHill
//
//  Created by Dylan Hellems on 4/2/16.
//  Copyright © 2016 Dylan Hellems. All rights reserved.
//

import SpriteKit

class LeaderboardScene: SKScene {
    
    var titleLabel = SKLabelNode()
    
    var menuButton = SKSpriteNode()
    let menuButtonTex = SKTexture(imageNamed: "Menu")
    
    override func didMoveToView(view: SKView) {
        
        self.backgroundColor = UIColor.orangeColor()
        
        titleLabel = SKLabelNode(fontNamed: "SanFranciscoDisplay-Black")
        titleLabel.text = "Leaderboards"
        titleLabel.fontSize = 32
        titleLabel.fontColor = UIColor.blackColor()
        titleLabel.position = CGPointMake(frame.midX, frame.midY + frame.maxY/4)
        self.addChild(titleLabel)
        
        menuButton = SKSpriteNode(texture: menuButtonTex)
        menuButton.position = CGPointMake(frame.midX, frame.midY)
        self.addChild(menuButton)
        
        let rest = RestApiManager()
        rest.get_leaderboards()
        
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        
        for touch in touches {
            let pos = touch.locationInNode(self)
            let node = self.nodeAtPoint(pos)
            
            if node == menuButton {
                if let view = view {
                    let scene = MenuScene(fileNamed: "MenuScene")
                    scene!.scaleMode = SKSceneScaleMode.AspectFill
                    view.presentScene(scene)
                }
            }
        }
        
    }

}
