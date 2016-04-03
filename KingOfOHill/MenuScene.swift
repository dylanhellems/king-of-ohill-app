//
//  MenuScene.swift
//  KingOfOHill
//
//  Created by Dylan Hellems on 4/2/16.
//  Copyright © 2016 Dylan Hellems. All rights reserved.
//

import SpriteKit

class MenuScene: SKScene {
    
    var titleLabel = SKLabelNode()

    var playButton = SKSpriteNode()
    let playButtonTex = SKTexture(imageNamed: "Play")
    
    var leaderboardsButton = SKSpriteNode()
    let leaderboardsButtonTex = SKTexture(imageNamed: "Leaderboards")
    
    override func didMoveToView(view: SKView) {
        
        self.backgroundColor = UIColor.orangeColor()
        
        titleLabel = SKLabelNode(fontNamed: "SanFranciscoDisplay-Black")
        titleLabel.text = "King of O'Hill"
        titleLabel.fontSize = 32
        titleLabel.fontColor = UIColor.blackColor()
        titleLabel.position = CGPointMake(frame.midX, frame.midY + frame.maxY/4)
        self.addChild(titleLabel)
        
        playButton = SKSpriteNode(texture: playButtonTex)
        playButton.position = CGPointMake(frame.midX, frame.midY)
        self.addChild(playButton)
        
        leaderboardsButton = SKSpriteNode(texture: leaderboardsButtonTex)
        leaderboardsButton.position = CGPointMake(frame.midX, frame.midY - frame.maxY/6)
        self.addChild(leaderboardsButton)
        
    }
    
        
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        
        for touch in touches {
            let pos = touch.locationInNode(self)
            let node = self.nodeAtPoint(pos)
                
            if node == playButton {
                if let view = view {
                    let scene = GameScene(fileNamed: "GameScene")
                    scene!.scaleMode = SKSceneScaleMode.AspectFill
                    view.presentScene(scene)
                }
            }
        }
    }
    
}
