//
//  GameScene.swift
//  BreakAll
//
//  Created by Ryan Morrison on 17/08/2017.
//  Copyright © 2017 egoDev. All rights reserved.
//

import SpriteKit
import GameplayKit
import AVFoundation

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    var playerPaddle : SKSpriteNode?
    var ball : SKSpriteNode?
    var startImpluse : CGFloat = 50
    
    var label : SKLabelNode?
    var labelInstruct : SKLabelNode?
    var isGameOver : Bool = false
    
    var brickCount = 15
    var brickCountLabel : SKLabelNode?

    var soundIsOn : Bool = true
    
    var soundBtn : UIButton?
    
    var paddleAudioPlayer = AVAudioPlayer()
    var brickAudioPlayer = AVAudioPlayer()
    
    enum bitMasks : UInt32 {
        
        case edgeBitmask = 0b1
        case playerPaddleBitMask = 0b10
        case ballBitMask = 0b100
        
        
    }
    
    override func didMove(to view: SKView) {
        
        physicsWorld.contactDelegate = self
        
        playerPaddle = self.childNode(withName: "playerPaddle") as? SKSpriteNode
        ball = self.childNode(withName: "ball") as? SKSpriteNode
        
        let edgePhysicsBody = SKPhysicsBody(edgeLoopFrom: self.frame)
        edgePhysicsBody.categoryBitMask = bitMasks.edgeBitmask.rawValue
        edgePhysicsBody.contactTestBitMask = bitMasks.ballBitMask.rawValue
        edgePhysicsBody.collisionBitMask = bitMasks.ballBitMask.rawValue
        edgePhysicsBody.friction = 0
        edgePhysicsBody.restitution = 1
        edgePhysicsBody.isDynamic = false
        self.name = "scene"
        
        self.physicsBody = edgePhysicsBody
        
        ball?.physicsBody?.contactTestBitMask = bitMasks.edgeBitmask.rawValue | bitMasks.playerPaddleBitMask.rawValue
        ball?.physicsBody?.collisionBitMask = bitMasks.edgeBitmask.rawValue | bitMasks.playerPaddleBitMask.rawValue
    
        ball?.physicsBody?.applyImpulse(CGVector(dx: startImpluse, dy: startImpluse))
     
        label = SKLabelNode(text: "Game Over")
        label?.fontColor = UIColor.white
        label?.fontSize = 90
        label?.fontName = "Avenir-Light"
        label?.position = CGPoint(x: 0, y: 60)
        
        labelInstruct = SKLabelNode(text: "Touch to play again")
        labelInstruct?.fontColor = UIColor.white
        labelInstruct?.fontSize = 60
        labelInstruct?.fontName = "Avenir-Light"
        labelInstruct?.position = CGPoint(x: 0, y: -20)
        
        brickCountLabel = SKLabelNode(text: "Score: \(brickCount)")
        brickCountLabel?.fontColor = UIColor.white
        brickCountLabel?.fontSize = 30
        brickCountLabel?.fontName = "Avenir-Light"
        brickCountLabel?.position = CGPoint(x: 0, y: -99)
        

//        soundBtn = UIButton(frame: CGRect(x: view.frame.midX, y: view.frame.midY, width: 100, height: 80))
//        soundBtn?.titleLabel?.text = "SOUND OFF"
//        soundBtn?.tintColor = UIColor.black
//        soundBtn?.titleLabel?.textColor = UIColor.white
//        soundBtn?.addTarget(self, action: #selector(stopSound), for: .touchUpInside)
//        self.view?.addSubview(soundBtn!)
        
    }
    
    
    func stopSound() {
        
        soundIsOn = false
        
        
    }
    
    
    func brickAudioPlay() {
        
        
        let path = Bundle.main.path(forResource: "brick", ofType:"mp3")!
        let url = URL(fileURLWithPath: path)
        
        do {
            let sound = try AVAudioPlayer(contentsOf: url)
            brickAudioPlayer = sound
            if soundIsOn == true {
            
                sound.play()
                
            }
        } catch {
            // couldn't load file :(
        }

    }
    
    
    func paddleAudioPlay() {
        
        
        let path = Bundle.main.path(forResource: "pong", ofType:"mp3")!
        let url = URL(fileURLWithPath: path)
        
        do {
            let sound = try AVAudioPlayer(contentsOf: url)
            paddleAudioPlayer = sound
            sound.volume = 0.3
            
            if soundIsOn == true {
                
                sound.play()
                
            }
            
        } catch {
            // couldn't load file :(
        }
        
    }
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
       
        if isGameOver {
            
            if  let scene = SKScene(fileNamed: "GameScene") {
                scene.size = self.frame.size
                scene.scaleMode = .aspectFill
                self.view?.presentScene(scene)
            }
            
            
        }
        
        for t in touches {
            let xLocation = t.location(in: self).x
            playerPaddle?.position = CGPoint(x: xLocation, y: (playerPaddle?.position.y)!)
        
        }
    
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
    
        for t in touches {
            let xLocation = t.location(in: self).x
            playerPaddle?.position = CGPoint(x: xLocation, y: (playerPaddle?.position.y)!)
            
        }

        
    }
    
    
    func didBegin(_ contact: SKPhysicsContact) {
        
        
        var ballNode : SKNode!
        var otherNode : SKNode!
        let xPosition = contact.contactPoint.x
        let yPosition = contact.contactPoint.y
        
        if contact.bodyA.node?.name == "ball" {
            ballNode = contact.bodyA.node
            otherNode = contact.bodyB.node
            paddleAudioPlay()
        } else if contact.bodyB.node?.name == "ball" {
            ballNode = contact.bodyB.node
            otherNode = contact.bodyA.node
            //paddleAudioPlay()
        }
        
        if otherNode.name == "Brick" {
            brickAudioPlay()
            otherNode.removeFromParent()
            brickCount -= 1
            
        let dx = ballNode.physicsBody?.velocity.dx
        let dy = ballNode.physicsBody?.velocity.dy
        
        
            if otherNode.name == "Brick" || otherNode.name == "playerPaddle" {
                if brickCount == 0 {
                    
                    isGameOver = true
                    label?.text = "WIN!"
                    self.addChild(label!)
                    
                    self.addChild(labelInstruct!)
                    //self.addChild(brickCountLabel!)
                }
            }
            ///////////
            if yPosition <= otherNode.frame.minY + 2 {
                
                ballNode.physicsBody?.velocity.dy = 0
                ballNode.physicsBody?.applyImpulse(CGVector(dx: 0, dy: -startImpluse))
                
                
            
            } else if yPosition >= otherNode.frame.maxY - 2 {
                
                ballNode.physicsBody?.velocity.dy = 0
                ballNode.physicsBody?.applyImpulse(CGVector(dx: 0, dy: startImpluse))
            }
            
            if xPosition <= otherNode.frame.minX - 2 {
                ballNode.physicsBody?.velocity.dx = 0
                ballNode.physicsBody?.applyImpulse(CGVector(dx: -startImpluse, dy: 0))
            } else if xPosition >= otherNode.frame.maxX - 2  {
                ballNode.physicsBody?.velocity.dx = 0
                ballNode.physicsBody?.applyImpulse(CGVector(dx: startImpluse, dy: 0))
                
            }
            
            ///////////
            } else if otherNode.name == "scene" {
            
            if yPosition <= self.frame.minY + 5 {
                
                isGameOver = true
                label?.text = "GAME OVER!"
                self.addChild(label!)
                self.addChild(labelInstruct!)
               // self.addChild(brickCountLabel!)
            } else if yPosition >= self.frame.maxY - 5 {
                
                ballNode.physicsBody?.velocity.dy = 0
                ballNode.physicsBody?.applyImpulse(CGVector(dx: 0, dy: -startImpluse))
            }
            
            if xPosition <= otherNode.frame.minX + 5 {
                ballNode.physicsBody?.velocity.dx = 0
                ballNode.physicsBody?.applyImpulse(CGVector(dx: startImpluse, dy: 0))
            } else if xPosition >= otherNode.frame.maxX - 5 {
                    ballNode.physicsBody?.velocity.dx = 0
                ballNode.physicsBody?.applyImpulse(CGVector(dx: -startImpluse, dy: 0))
            
            }
            
            
            
        }
        
        
        
        
        
        
        
        
    }
    
    
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
        
        if isGameOver {
            self.isPaused = true
        }
        
    }
}
