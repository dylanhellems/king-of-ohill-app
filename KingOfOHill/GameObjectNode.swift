//
//  GameObjectNode.swift
//  KingOfOHill
//
//  Created by user116333 on 4/26/16.
//  Copyright © 2016 Dylan Hellems. All rights reserved.
//

import SpriteKit

struct CollisionCategoryBitmask {
    static let Player: UInt32 = 0x00
    static let Food: UInt32 = 0x01
    static let Platform: UInt32 = 0x02
}

class GameObjectNode: SKNode {
    
    func collisionWithPlayer(player: SKNode) -> Bool {
        return false
    }
    
    func checkNodeRemoval(playerY: CGFloat) -> Bool {
        if playerY > self.position.y + 200 {
            self.removeFromParent()
            NSNotificationCenter.defaultCenter().postNotificationName("AddFood", object: self)
            return true
        }
        
        return false
    }
    
}

class FoodNode: GameObjectNode {
    
    override func collisionWithPlayer(player: SKNode) -> Bool {
        
        // Boost the player up
        player.physicsBody?.velocity = CGVector(dx: player.physicsBody!.velocity.dx, dy: 425.0)
        
        // Remove this Food
        self.removeFromParent()
        NSNotificationCenter.defaultCenter().postNotificationName("AddFood", object: self)
        
        // The HUD needs updating to show the new stars and score
        return true
        
    }
    
}
