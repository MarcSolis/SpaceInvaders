//
//  GameScene.swift
//  SpaceInvaders
//
//  Created by Guillermo Fernandez on 24/03/2021.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene {
    
    var spaceShip: SKSpriteNode!
    var enemiesContainer: SKSpriteNode!
    var enemiesDirection = CGVector(dx:1, dy:0)
    private let laserShootSound = SKAction.playSoundFileNamed("lasershoot.wav", waitForCompletion: false)
    let bombSound = SKAction.playSoundFileNamed("bomb.wav", waitForCompletion: false)
    let boomSound = SKAction.playSoundFileNamed("boom.wav", waitForCompletion: false)
    private var spaceshipTouch: UITouch?
    var scoreLabel: SKLabelNode!
    var bombTimer: Timer?
    
    var currentScore: Int = 0
    let enemiesVerticaSpacing: CGFloat = 50.0
    var houseImpacts = [0, 0, 0, 0]
    
    override func didMove(to view: SKView) {
        self.enemiesContainer = SKSpriteNode()
        self.enemiesContainer.name = "enemies"
        self.addChild(self.enemiesContainer)
        
        let spaceshipYPositon = -(self.size.height / 2) + 100
        self.backgroundColor = .black
        self.spaceShip = SKSpriteNode(imageNamed: "SpaceShip")
        self.spaceShip.name = "spaceship"
        self.spaceShip.size = CGSize(width: 50, height: 25)
        self.spaceShip.position = CGPoint(x: 0, y: spaceshipYPositon)
        self.spaceShip.physicsBody = SKPhysicsBody(texture: spaceShip.texture!, size: spaceShip.size)
        self.spaceShip.physicsBody?.affectedByGravity = false

        self.spaceShip.physicsBody?.categoryBitMask = 0x00000100
        self.addChild(self.spaceShip)
        
        self.addHouses(spaceshipYPositon)
        
        self.addEnemies(at: 100)        
        
        self.physicsWorld.contactDelegate = self
        
        self.scoreLabel = SKLabelNode(text: "SCORE: 0")
        self.scoreLabel.position = CGPoint(x: 0, y: (self.size.height / 2) - 50)
        self.addChild(self.scoreLabel)
        
        self.bombTimer = Timer.scheduledTimer(timeInterval: 1.5, target: self, selector: #selector(dropBomb), userInfo: nil, repeats: true)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard self.spaceshipTouch == nil else {
            self.createShoot()
            run(self.laserShootSound)
            return
        }
        
        if let touch = touches.first {
            self.spaceshipTouch = touch
            let newPosition = touch.location(in: self)
            let action = SKAction.moveTo(x: newPosition.x, duration: 0.5)
            action.timingMode = .easeInEaseOut
            self.spaceShip.run(action)
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            if touch == self.spaceshipTouch {
                let newPosition = touch.location(in: self)
                let action = SKAction.moveTo(x: newPosition.x, duration: 0.05)
                action.timingMode = .easeInEaseOut
                self.spaceShip.run(action)
            }
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            if touch == self.spaceshipTouch {
                self.spaceshipTouch = nil
            }
        }
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            if touch == self.spaceshipTouch {
                self.spaceshipTouch = nil
            }
        }
    }
    
    
    override func update(_ currentTime: TimeInterval) {
        self.cleanPastShoots()
    }
}

extension GameScene {
    private func cleanPastShoots() {
        for node in children {
            guard node.name == "shoot" || node.name == "bomb" else { continue }
            if node.position.y > 700 || node.position.y < -700{
                node.removeFromParent()
            }
        }
    }
    
    @objc
    private func dropBomb() {
        let bottomEnemies = self.children.filter { node in
            guard let isEnemy = node.name?.hasPrefix("Enemy"), isEnemy == true else { return false }
            let bottomPosition = CGPoint(x: node.position.x, y: node.position.y - self.enemiesVerticaSpacing)
            let enemies = self.nodes(at: bottomPosition)
            
            return !enemies.reduce(false) { $0 || $1.name!.hasPrefix("Enemy") }
        }
        
        guard bottomEnemies.count > 0 else { return }
        
        let shooterEnemyIndex = Int.random(in: 0..<bottomEnemies.count)
        let shooterEnemy = bottomEnemies[shooterEnemyIndex]
        let bombPosition = CGPoint(x: shooterEnemy.position.x,
                                   y: shooterEnemy.position.y - self.enemiesVerticaSpacing / 2)
        self.createBomb(at: bombPosition)
    }
}

