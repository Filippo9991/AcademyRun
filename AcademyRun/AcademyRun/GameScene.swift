//
//  GameScene.swift
//  AcademyRun
//
//  Created by Filippo Rota on 12/12/23.
//

import SpriteKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    var player = SKSpriteNode()
    var ground = SKSpriteNode()
    var background = SKSpriteNode()
    var obstacles = [SKSpriteNode]()
    var isGameRunning = true
    var scoreLabel = SKLabelNode()
    var score = 0
    let playerCategory: UInt32 = 0x1 << 0
    let obstacleCategory: UInt32 = 0x1 << 1
    let groundCategory: UInt32 = 0x1 << 2

    override func didMove(to view: SKView) {
        physicsWorld.contactDelegate = self
        createBackground()
        createGround()
        createPlayer()
        setupScore()
        startObstacleSpawn()
        self.physicsWorld.gravity = CGVector(dx: 0, dy: 0) // Adjust gravity for landscape orientation
    }

    func createBackground() {
        let backgroundTexture = SKTexture(imageNamed: "background") // Replace with your background image
        background = SKSpriteNode(texture: backgroundTexture)
        background.position = CGPoint(x: frame.midX, y: frame.midY)
        background.zPosition = -2
        addChild(background)
    }

    func createPlayer() {
        let playerTexture = SKTexture(imageNamed: "player") // Replace with your player image
        player = SKSpriteNode(texture: playerTexture)
        player.position = CGPoint(x: frame.midX, y: ground.position.y)
        player.physicsBody = SKPhysicsBody(texture: playerTexture, size: playerTexture.size())
        player.physicsBody?.affectedByGravity = true
        player.physicsBody?.categoryBitMask = playerCategory
        player.physicsBody?.contactTestBitMask = obstacleCategory
        addChild(player)
    }

    func createGround() {
        let groundTexture = SKTexture(imageNamed: "ground") // Replace with your ground image
        ground = SKSpriteNode(texture: groundTexture)
        ground.position = CGPoint(x: frame.midX, y: groundTexture.size().height / 2)
        ground.zPosition = -1
        addChild(ground)

        ground.physicsBody = SKPhysicsBody(texture: groundTexture, size: groundTexture.size())
        ground.physicsBody?.isDynamic = false
        ground.physicsBody?.categoryBitMask = groundCategory
        ground.physicsBody?.contactTestBitMask = playerCategory

        let centerLimit = SKSpriteNode(color: .clear, size: CGSize(width: frame.size.width, height: 10))
        centerLimit.position = CGPoint(x: frame.midX, y: ground.position.y)
        centerLimit.physicsBody = SKPhysicsBody(rectangleOf: centerLimit.size)
        centerLimit.physicsBody?.isDynamic = false
        centerLimit.physicsBody?.categoryBitMask = obstacleCategory
        centerLimit.physicsBody?.contactTestBitMask = playerCategory
        addChild(centerLimit)
    }

    func setupScore() {
        scoreLabel = SKLabelNode(text: "Score: 0")
        scoreLabel.fontName = "Arial"
        scoreLabel.fontSize = 24
        scoreLabel.position = CGPoint(x: frame.midX, y: frame.maxY - 50)
        addChild(scoreLabel)
    }

    func startObstacleSpawn() {
        let spawnAction = SKAction.run { [weak self] in
            self?.createObstacle()
        }
        let delayAction = SKAction.wait(forDuration: 1.5)
        let spawnDelayAction = SKAction.sequence([spawnAction, delayAction])
        let spawnDelayForever = SKAction.repeatForever(spawnDelayAction)
        run(spawnDelayForever, withKey: "spawnObstacle")
    }

    func createObstacle() {
        let obstacleTexture = SKTexture(imageNamed: "obstacle") // Replace with your obstacle image
        let obstacle = SKSpriteNode(texture: obstacleTexture)
        obstacle.position = CGPoint(x: frame.width + obstacle.size.width, y: frame.midY)
        obstacle.physicsBody = SKPhysicsBody(texture: obstacleTexture, size: obstacleTexture.size())
        obstacle.physicsBody?.isDynamic = false
        obstacle.physicsBody?.categoryBitMask = obstacleCategory
        obstacle.physicsBody?.contactTestBitMask = playerCategory
        obstacles.append(obstacle)
        addChild(obstacle)

        let moveLeftAction = SKAction.moveTo(x: -obstacle.size.width, duration: 5)
        obstacle.run(moveLeftAction) {
            obstacle.removeFromParent()
        }
    }

    func knockdownPlayer() {
        let layDownAction = SKAction.rotate(byAngle: CGFloat(Double.pi / 2), duration: 0.5)
        player.run(layDownAction)
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard isGameRunning else { return }
        player.physicsBody?.velocity = CGVector(dx: 0, dy: 0)
        player.physicsBody?.applyImpulse(CGVector(dx: 0, dy: 50))
    }

    func didBegin(_ contact: SKPhysicsContact) {
        if contact.bodyA.categoryBitMask == playerCategory || contact.bodyB.categoryBitMask == playerCategory {
            isGameRunning = false
            removeAction(forKey: "spawnObstacle") // Stop spawning obstacles when the game ends
            knockdownPlayer() // Trigger knockdown animation
            // Handle game over logic here
            print("Game Over")
        }
    }

    func updateScore() {
        score += 1
        scoreLabel.text = "Score: \(score)"
    }
}
