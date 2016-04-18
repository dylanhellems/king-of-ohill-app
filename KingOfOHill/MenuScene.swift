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
        super.didMoveToView(view)
        
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
        
        let defaults = NSUserDefaults.standardUserDefaults()
        
        for touch in touches {
            
            let pos = touch.locationInNode(self)
            let node = self.nodeAtPoint(pos)
                
            if node == playButton {
                let id = defaults.stringForKey(nicknameKeys.id)
                let name = defaults.stringForKey(nicknameKeys.name)
                
                if id == nil || name == nil {
                    setNickname("Choose a nickname:")
                } else {
                    let rest = RestApiManager()
                    
                    rest.validate_nickname(name!, id: id!, callback: { (response) in
                        if response["message"] as! String == "invalid" {
                            print("yes")
                            self.setNickname("We lost your nickname, sorry! Choose another:")
                        }
                    })
                }
            }
            
            if node == leaderboardsButton {
                if let view = view {
                    let scene = LeaderboardScene(fileNamed: "LeaderboardScene")
                    scene!.scaleMode = SKSceneScaleMode.AspectFill
                    view.presentScene(scene)
                }
            }
            
        }
    }
    
    struct nicknameKeys {
        static let id = "id"
        static let name = "name"
    }
    
    func setNickname(message: String) {
        let alert = UIAlertController(title: "New User", message: message, preferredStyle: .Alert)
        
        alert.addTextFieldWithConfigurationHandler({ (textField) -> Void in
            textField.text = ""
        })
        
        alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: { (action) -> Void in
            let textField = alert.textFields![0] as UITextField
            print("Text field: \(textField.text)")
            
            let nickname = textField.text!
            
            let rest = RestApiManager()
            rest.add_nickname(nickname, callback: {(response) in
                if let id = response["message"] as? NSInteger {
                
                    let defaults = NSUserDefaults.standardUserDefaults()
                
                    defaults.setValue(id, forKey: nicknameKeys.id)
                    defaults.setValue(nickname, forKey: nicknameKeys.name)
                
                    defaults.synchronize()
                    
                    if let view = self.view {
                        let scene = GameScene(fileNamed: "GameScene")
                        scene!.scaleMode = SKSceneScaleMode.AspectFill
                        view.presentScene(scene)
                    }
                    
                } else if let message = response["message"] as? String {
                    if message == "nickname already in use" {
                        self.setNickname("Nickname already in use! Choose another:")
                    } else {
                        self.setNickname("Server is being slow! Try again:")
                    }
                }
            })
            
        }))
        
        self.view?.window?.rootViewController?.presentViewController(alert, animated: true, completion: nil)
    }
    
}
