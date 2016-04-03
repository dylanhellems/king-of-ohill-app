//
//  LeaderboardScene.swift
//  KingOfOHill
//
//  Created by Dylan Hellems on 4/2/16.
//  Copyright © 2016 Dylan Hellems. All rights reserved.
//

import SpriteKit

class LeaderboardScene: SKScene {
    
    var data = ""
    
    var titleLabel = SKLabelNode()
    var dataLabel = SKLabelNode()
    
    var menuButton = SKSpriteNode()
    let menuButtonTex = SKTexture(imageNamed: "Menu")
    
    override func didMoveToView(view: SKView) {
        
        self.backgroundColor = UIColor.orangeColor()
        
        titleLabel = SKLabelNode(fontNamed: "SanFranciscoDisplay-Black")
        titleLabel.text = "Leaderboards"
        titleLabel.fontSize = 32
        titleLabel.fontColor = UIColor.blackColor()
        titleLabel.position = CGPointMake(frame.midX, frame.midY + frame.maxY/3)
        self.addChild(titleLabel)
        
        
        let rest = RestApiManager()
        rest.get_leaderboards() { (response) in
            let leaderboards = response["leaderboards"] as! Dictionary<String, AnyObject>
            let ohill = leaderboards["OHill"] as! Dictionary<String, AnyObject>
            let breakfast = ohill["Breakfast"]
            
            let multiLabel = SKMultilineLabel(text: (breakfast as? String)! , labelWidth: 250, pos: CGPointMake(self.frame.midX, self.frame.midY + self.frame.maxY/3))
            multiLabel.fontName = "SanFranciscoDisplay-Black"
            multiLabel.fontColor = UIColor.blackColor()
            multiLabel.fontSize = 24
            self.addChild(multiLabel)
        }
        
        menuButton = SKSpriteNode(texture: menuButtonTex)
        let menuButtonSize = menuButton.size
        let screenSize = UIScreen.mainScreen().bounds.size
        menuButton.position = CGPointMake(frame.midX - screenSize.width/2 + menuButtonSize.width/2, frame.minY + menuButtonSize.height/2)
        self.addChild(menuButton)
        
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
