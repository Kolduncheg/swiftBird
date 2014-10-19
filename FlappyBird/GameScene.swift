//
//  GameScene.swift
//  FlappyBird
//
//  Created by Denis on 19.10.14.
//  Copyright (c) 2014 Kolduncheg. All rights reserved.
//

import SpriteKit

class GameScene: SKScene, SKPhysicsContactDelegate{
    
    let screenSize : CGRect = UIScreen.mainScreen().bounds
    let kVericalPipeGap : CGFloat = 100
    let pipeTexture1 = SKTexture(imageNamed: "Pipe1")
    let pipeTexture2 = SKTexture(imageNamed: "Pipe2")
    
    var player = SKSpriteNode()
    var movePipesAndRemove : SKAction = SKAction()
    var moving = SKNode.node()
    var pipes = SKNode.node()
    var canRestart = false
    var score = 0
    var scoreLabelNode = SKLabelNode();
    
    let birdCategory  : UInt32  = 1;
    let worldCategory : UInt32  = 2;
    let pipeCategory  : UInt32  = 4;
    let scoreCategory : UInt32  = 8;
    
    
    override func didMoveToView(view: SKView) {
        /* Setup your scene here */
        setupScene()
        addDecoration()
        addPlayer()
    }
    
    func setupScene(){
        canRestart = false
        
        self.backgroundColor = SKColor(red: 113.0/255.0, green: 197.0/255.0, blue: 207.0/255.0, alpha: 1.0)
        self.size = CGSize(width: screenSize.width,height: screenSize.height)
        self.anchorPoint = CGPoint(x: 0,y: 0)
        self.physicsWorld.gravity = CGVectorMake(0.0, -5.0)
        self.physicsWorld.contactDelegate = self
        
        self.addChild(moving)
        moving.addChild(pipes)
        
        pipeTexture1.filteringMode = SKTextureFilteringMode.Nearest;
        pipeTexture2.filteringMode = SKTextureFilteringMode.Nearest;
        //create pipes
        let distanceToMove : CGFloat = self.size.width + 2 * pipeTexture1.size().width
        let movePipes = SKAction.moveByX(-distanceToMove, y: 0, duration: 0.01 * Double(distanceToMove))
        let removePipes = SKAction.removeFromParent()
        
        movePipesAndRemove = SKAction.sequence([movePipes, removePipes])
        
        let spawn = SKAction.runBlock(addPipes)
        let delay = SKAction.waitForDuration(2.0)
        let spawnThenDelay = SKAction.sequence([spawn, delay])
        let spawnThenDelayForever = SKAction.repeatActionForever(spawnThenDelay)
        self.runAction(spawnThenDelayForever)
        //
        
        score = 0
        scoreLabelNode = SKLabelNode(fontNamed: "MarkerFelt-Wide")
        scoreLabelNode.position = CGPointMake(CGRectGetMidX(self.frame), 3 * self.frame.size.height / 4);
        scoreLabelNode.zPosition = 100;
        scoreLabelNode.text = String(format: "%d", score)
        
        self.addChild(scoreLabelNode);
    }
    
    func addPlayer()
    {
        let birdTexture1 = SKTexture(imageNamed: "Bird1")
        birdTexture1.filteringMode = SKTextureFilteringMode.Nearest
        let birdTexture2 = SKTexture(imageNamed: "Bird2")
        birdTexture2.filteringMode = SKTextureFilteringMode.Nearest
        
        let imagesSequence = SKAction.repeatActionForever(SKAction.animateWithTextures([birdTexture1, birdTexture2], timePerFrame: 0.2))
        
        player = SKSpriteNode(texture: birdTexture1)
        player.setScale(2.0)
        player.position = CGPoint(x: self.size.width / 4, y: CGRectGetMidY(self.frame))
        player.runAction(imagesSequence)
        
        player.physicsBody = SKPhysicsBody(circleOfRadius: player.size.height / 2)
        player.physicsBody?.allowsRotation = false;
        
        player.physicsBody?.categoryBitMask = birdCategory;
        player.physicsBody?.collisionBitMask = worldCategory | pipeCategory;
        player.physicsBody?.contactTestBitMask = worldCategory | pipeCategory;
        self.addChild(player)
    }
    
    func addDecoration(){
        let groundTexture = SKTexture(imageNamed: "Ground")
        groundTexture.filteringMode = SKTextureFilteringMode.Nearest
        
        let moveGroundSprite  = SKAction.moveByX(-groundTexture.size().width * 2.0, y: 0.0, duration: 0.02 * NSTimeInterval(groundTexture.size().width * 2.0))
        let resetGroundSprite = SKAction.moveByX(groundTexture.size().width * 2.0, y: 0.0, duration: 0.0)
        let moveGroundSpritesForever = SKAction.repeatActionForever(SKAction.sequence([moveGroundSprite, resetGroundSprite]))
        
        let dummy = SKNode.node();
        dummy.position = CGPointMake(0, groundTexture.size().height);
        dummy.physicsBody = SKPhysicsBody(rectangleOfSize: CGSizeMake(self.frame.size.width, groundTexture.size().height * 2))
        dummy.physicsBody?.dynamic = false;
        dummy.physicsBody?.categoryBitMask = worldCategory;
        self.addChild(dummy)
        
        for (var i = 0; i < 3 + Int(self.size.width / (groundTexture.size().width * 2)); i++){
            let groundSprite = SKSpriteNode(texture: groundTexture)
            groundSprite.setScale(2.0)
            groundSprite.position = CGPointMake(CGFloat(i * Int(groundSprite.size.width)), groundSprite.size.height / 2)
            groundSprite.runAction(moveGroundSpritesForever)
            
            moving.addChild(groundSprite)
        }
        
        
        let skyTexture = SKTexture(imageNamed: "Skyline")
        skyTexture.filteringMode = SKTextureFilteringMode.Nearest
        
        let moveSkySprite  = SKAction.moveByX(-skyTexture.size().width * 2.0, y: 0.0, duration: 0.1 * NSTimeInterval(skyTexture.size().width * 2.0))
        let resetSkySprite = SKAction.moveByX(skyTexture.size().width * 2.0, y: 0.0, duration: 0.0)
        let moveSkySpritesForever = SKAction.repeatActionForever(SKAction.sequence([moveSkySprite, resetSkySprite]))
        
        for (var i = 0; i < 2 + Int(self.size.width / (skyTexture.size().width * 2)); i++){
            let skySprite = SKSpriteNode(texture: skyTexture)
            skySprite.setScale(2.0)
            skySprite.zPosition = -20
            skySprite.position = CGPointMake(CGFloat(i * Int(skySprite.size.width)), skySprite.size.height / 2 + groundTexture.size().height * 2)
            skySprite.runAction(moveSkySpritesForever)
            
            moving.addChild(skySprite)
        }
    }
    
    func addPipes(){
    
        let pipePair = SKNode.node()
        pipePair.position = CGPointMake(self.size.width + pipeTexture1.size().width, 0)
        pipePair.zPosition = -10
        
        let y = CGFloat(arc4random() % UInt32(self.size.height / 3))
        
        let pipe1 = SKSpriteNode(texture: pipeTexture1)
        pipe1.setScale(2.0)
        pipe1.position = CGPointMake(0, y)
        pipe1.physicsBody = SKPhysicsBody(rectangleOfSize: pipe1.size)
        pipe1.physicsBody?.dynamic = false;
        pipe1.physicsBody?.categoryBitMask = pipeCategory;
        pipe1.physicsBody?.contactTestBitMask = birdCategory;
        pipePair.addChild(pipe1);
        
        let pipe2 = SKSpriteNode(texture: pipeTexture2)
        pipe2.setScale(2.0)
        pipe2.position = CGPointMake(0, y + pipe1.size.height + kVericalPipeGap)
        pipe2.physicsBody = SKPhysicsBody(rectangleOfSize: pipe2.size)
        pipe2.physicsBody?.dynamic = false;
        pipe2.physicsBody?.categoryBitMask = pipeCategory;
        pipe2.physicsBody?.contactTestBitMask = birdCategory;
        pipePair.addChild(pipe2);
        
        let contactNode = SKNode.node();
        contactNode.position = CGPointMake(pipe1.size.width + player.size.width / 2, CGRectGetMidY(self.frame));
        contactNode.physicsBody = SKPhysicsBody(rectangleOfSize: CGSizeMake(pipe2.size.width, self.frame.size.height));
        contactNode.physicsBody?.dynamic = false;
        contactNode.physicsBody?.categoryBitMask = scoreCategory;
        contactNode.physicsBody?.contactTestBitMask = birdCategory;
        
        pipePair.addChild(contactNode);
        
        pipePair.runAction(movePipesAndRemove)
        
        pipes.addChild(pipePair)
    }
    
    override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
        if moving.speed > 0 {
        /* Called when a touch begins */
            player.physicsBody?.velocity = CGVector(0.0, 0.0)
            player.physicsBody?.applyImpulse(CGVectorMake(0.0, 5.0))
        } else if canRestart {
            reserScene()
        }
    }
    
    func reserScene(){
        // Move bird to original position and reset velocity
        player.position = CGPointMake(self.size.width / 4, CGRectGetMidY(self.frame));
        player.physicsBody?.velocity = CGVectorMake( 0, 0 );
        player.physicsBody?.collisionBitMask = worldCategory | pipeCategory;
        player.zRotation = 0.0
        player.speed = 1.0
        // Remove all existing pipes
        pipes.removeAllChildren();
        
        // Reset _canRestart
        canRestart = false;
        
        // Restart animation
        moving.speed = 1;
        
        score = 0;
        scoreLabelNode.text = String(format: "%d", score);
    }
    
    func clamp(min : CGFloat, max : CGFloat, value : CGFloat) -> CGFloat{
        if value > max {
            return max;
        } else if  value < min {
            return min;
        } else {
            return value;
        }
    }
    
    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
        var coef: CGFloat = 0.0
        if let myDy = player.physicsBody?.velocity.dy {
            if myDy < 0 {
                coef = myDy * 0.003
            } else {
                coef = myDy * 0.001
            }
        }
        if moving.speed > 0 {
            player.zRotation = clamp(-1.0, max: 0.5, value: coef)
        }
    }
    
    func didBeginContact(contact: SKPhysicsContact) {
        // Flash background if contact is detected
        if moving.speed > 0 {
            
            if( ( contact.bodyA.categoryBitMask & scoreCategory ) == scoreCategory || ( contact.bodyB.categoryBitMask & scoreCategory ) == scoreCategory ) {
                // Bird has contact with score entity
                
                score++;
                scoreLabelNode.text = String(format: "%d", score)
                
                // Add a little visual feedback for the score increment
                scoreLabelNode.runAction(SKAction.sequence([SKAction.scaleTo(1.5, duration: 0.1), SKAction.scaleTo(1, duration: 0.1)]))
            } else {
                moving.speed = 0
                
                player.physicsBody?.collisionBitMask = worldCategory;
                
                let rotateAction = SKAction.rotateByAngle(CGFloat(M_PI) * player.position.y * 0.01, duration: 0.003 * Double(player.position.y))
                player.runAction(rotateAction, completion: {self.player.speed = 0})
                
                
                self.removeActionForKey("flash");
                self.runAction(SKAction.sequence([
                    SKAction.repeatAction(SKAction.sequence([
                        SKAction.runBlock({self.backgroundColor = SKColor.redColor()}),
                        SKAction.waitForDuration(0.05),
                        SKAction.runBlock({self.backgroundColor = SKColor(red: 113.0/255.0, green: 197.0/255.0, blue: 207.0/255.0, alpha: 1.0)}),
                        SKAction.waitForDuration(0.05)
                        ]), count: 4), SKAction.runBlock({self.canRestart = true})
                    ]), withKey: "flash")
            }
        }
    }
}
