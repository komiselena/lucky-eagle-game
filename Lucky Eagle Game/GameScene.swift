//
//  GameScene.swift
//  Lucky Eagle Game
//
//  Created by Mac on 25.04.2025.
//

import SwiftUI
import SpriteKit
import GameplayKit

class EagleGameScene: SKScene, SKPhysicsContactDelegate {
    
    var gameViewModel: GameViewModel?
    var gameData: GameData?

    var eagle: SKSpriteNode!
    var scoreLabel: SKLabelNode!
    var score = 0
    
    var healthBarBackground: SKSpriteNode!
    var healthBar: SKSpriteNode!
    
    var health: CGFloat = 1.0 {
        didSet {
            updateHealthBar()
        }
    }

    override func didMove(to view: SKView) {
        backgroundColor = .blue
        physicsWorld.gravity = .zero
        physicsWorld.contactDelegate = self
        setupBackground()
        setupEagle()
        setupScoreDisplay()
        setupHealthBar()
        startSpawningEnemies()
        startSpawningCoins()
        startSpawningSmallBirds()

    }

    func setupBackground() {
        for i in 0...1 {
            let bg = SKSpriteNode(imageNamed: gameViewModel?.backgroundImage ?? "loc1")
            bg.name = "background"
            bg.anchorPoint = .zero
            bg.position = CGPoint(x: 0, y: CGFloat(i) * frame.height)
            bg.zPosition = -1
            bg.size = frame.size
            addChild(bg)
        }
    }

    override func update(_ currentTime: TimeInterval) {
        enumerateChildNodes(withName: "background") { node, _ in
            node.position.y -= 2
            if node.position.y <= -self.frame.height {
                node.position.y += self.frame.height * 2
            }
        }
    }


    func setupEagle() {
        eagle = SKSpriteNode(imageNamed: gameViewModel?.eagleSkin ?? "eagle1")
        eagle.setScale(1.8)
        eagle.position = CGPoint(x: size.width / 2, y: size.height / 2)
        eagle.zPosition = 10

        let glowNode = SKEffectNode()
        glowNode.shouldEnableEffects = true
        glowNode.filter = CIFilter(name: "CIGaussianBlur", parameters: [kCIInputRadiusKey: 15])
        glowNode.zPosition = -1

        let glowSprite = SKSpriteNode(texture: eagle.texture)
        glowSprite.color = .white
        glowSprite.colorBlendFactor = 1.0
        glowSprite.alpha = 0.6
        glowSprite.setScale(1.5)


        eagle.physicsBody = SKPhysicsBody(texture: eagle.texture!, size: eagle.size)
        eagle.physicsBody?.categoryBitMask = PhysicsCategory.eagle
        eagle.physicsBody?.contactTestBitMask = PhysicsCategory.arrow | PhysicsCategory.bird | PhysicsCategory.coin
        eagle.physicsBody?.collisionBitMask = 0
        eagle.physicsBody?.isDynamic = true

        glowNode.addChild(glowSprite)
        eagle.addChild(glowNode)
        addChild(eagle)
    }

    func startSpawningSmallBirds() {
        let spawn = SKAction.run {
            self.spawnSmallBird()
        }
        let wait = SKAction.wait(forDuration: Double.random(in: 5.0...8.0)) // реже, чем враги
        let sequence = SKAction.sequence([spawn, wait])
        run(SKAction.repeatForever(sequence))
    }
    
    func spawnSmallBird() {
        // Выбираем случайную птицу
        let birdNames = ["smallbird1", "smallbird2", "smallbird3", "smallbird4", "smallbird5"]
        let randomBirdName = birdNames.randomElement()!
        
        let bird = SKSpriteNode(imageNamed: randomBirdName)
        bird.name = randomBirdName
        bird.setScale(0.7) // Меньше основного орла
        bird.zPosition = 5
        
        // Стартовая позиция: случайная сторона экрана
        let fromLeft = Bool.random()
        let startX = fromLeft ? -50 : size.width + 50
        let startY = CGFloat.random(in: 100...(size.height - 100))
        bird.position = CGPoint(x: startX, y: startY)
        
        bird.physicsBody = SKPhysicsBody(texture: bird.texture!, size: bird.size)
        bird.physicsBody?.categoryBitMask = PhysicsCategory.bird // Можно завести отдельную категорию smallBird, если нужно
        bird.physicsBody?.contactTestBitMask = PhysicsCategory.eagle
        bird.physicsBody?.collisionBitMask = 0
        bird.physicsBody?.isDynamic = true
        
        addChild(bird)
        
        // Путь полёта: немного вверх/вниз и в сторону
        let dx = fromLeft ? CGFloat.random(in: 300...500) : CGFloat.random(in: -500 ... -300)
        let dy = CGFloat.random(in: -100...100)
        
        let move = SKAction.moveBy(x: dx, y: dy, duration: 8.0)
        let remove = SKAction.removeFromParent()
        bird.run(SKAction.sequence([move, remove]))
    }


    
    func setupScoreDisplay() {
        // 1. Картинка с надписью "Score"
        let scoreTitle = SKSpriteNode(imageNamed: "score")
        scoreTitle.position = CGPoint(x: size.width / 2, y: size.height - 40)
        scoreTitle.zPosition = 100
        addChild(scoreTitle)
        
        // 2. Картинка "scorebar" (панелька под цифры)
        let scoreBar1 = SKSpriteNode(imageNamed: "Group 8")
        scoreBar1.position = CGPoint(x: size.width / 2, y: scoreTitle.position.y - 40)
        scoreBar1.zPosition = 100
        addChild(scoreBar1)
        let scoreBar2 = SKSpriteNode(imageNamed: "coin")
        scoreBar2.position = CGPoint(x: size.width / 2, y: scoreTitle.position.y - 40)
        scoreBar2.zPosition = 101
        addChild(scoreBar2)

        /*
         ZStack{
             Image("Group 8")
                 .resizable()
                 .scaledToFit()
                 .frame(width: g.size.width * 0.13, height: g.size.height * 0.07)
             HStack{
                 Image("coin")
                     .resizable()
                     .scaledToFit()
                     .frame(width: g.size.width * 0.05)
                 Spacer()
             }
             .frame(width: g.size.width * 0.13, height: g.size.height * 0.07)

         */
        
        // 3. Цифры поверх scorebar
        scoreLabel = SKLabelNode(fontNamed: "HelveticaNeue-Bold")
        scoreLabel.fontSize = 28
        scoreLabel.fontColor = .white
        scoreLabel.position = CGPoint(x: size.width / 2, y: scoreBar1.position.y - 5)
        scoreLabel.zPosition = 102 // Чтобы быть поверх scorebar
        scoreLabel.text = "\(gameData?.coins ?? 0)"
        addChild(scoreLabel)
    }

    
    func setupHealthBar() {
        healthBarBackground = SKSpriteNode(color: UIColor.brown, size: CGSize(width: 220, height: 30))
        healthBarBackground.position = CGPoint(x: size.width / 2, y: size.height - 50)
        healthBarBackground.zPosition = 50
        healthBarBackground.cornerRadius = 15
        addChild(healthBarBackground)
        
        healthBar = SKSpriteNode(color: UIColor.red, size: CGSize(width: 200, height: 20))
        healthBar.anchorPoint = CGPoint(x: 0.0, y: 0.5)
        healthBar.position = CGPoint(x: healthBarBackground.position.x - 100, y: healthBarBackground.position.y)
        healthBar.zPosition = 51
        
        healthBar.cornerRadius = 15
        let heart = SKSpriteNode(imageNamed: "heart")
        heart.size = CGSize(width: 30, height: 30)
        heart.position = CGPoint(x: healthBarBackground.position.x - healthBarBackground.size.width / 2,
                                 y: healthBarBackground.position.y)
        heart.zPosition = 52
        addChild(healthBar)
        addChild(heart)
        
    }

    func updateHealthBar() {
        let maxWidth: CGFloat = 220
        let newWidth = max(0, maxWidth * health)
        
        let resize = SKAction.resize(toWidth: newWidth, duration: 0.3)
        healthBar.run(resize)
    }

    func reduceHealth() {
        health -= 0.1
        print("Оставшееся здоровье: \(health)")
        if health <= 0 {
            print("Game Over Condition Met!")
            gameOver()
            print("gameViewModel?.isGameOver set to true")
        }
    }

    func gameOver() {
        guard gameViewModel?.isGameOver == false else { return }
        eagle.removeFromParent()
        gameViewModel?.isGameOver = true
        health = 1
        score = 0
    }
    


    func moveEagle(left: Bool) {
        guard eagle != nil else { return }
        let dx: CGFloat = left ? -50 : 50
        let newX = min(max(eagle.position.x + dx, 0), size.width)
        eagle.run(SKAction.moveTo(x: newX, duration: 0.1))
    }

    func startSpawningEnemies() {
        let spawn = SKAction.run {
            self.spawnArrow()

            self.spawnEnemyBird()
            self.spawnEnemyBird()
        }
        let wait = SKAction.wait(forDuration: Double.random(in: 3.0...5.0))
        let sequence = SKAction.sequence([spawn, wait])
        run(SKAction.repeatForever(sequence))
    }

    func spawnArrow() {
        let arrow = SKSpriteNode(imageNamed: "arrow")
        let fromLeft = Bool.random()
        let startX = fromLeft ? -50 : size.width + 50
        let startY = CGFloat.random(in: size.height / 2 ... size.height)
        arrow.position = CGPoint(x: startX, y: startY)
        arrow.zPosition = 5
        arrow.physicsBody = SKPhysicsBody(texture: arrow.texture!, size: arrow.size)
        arrow.physicsBody?.categoryBitMask = PhysicsCategory.arrow
        arrow.physicsBody?.contactTestBitMask = PhysicsCategory.eagle
        arrow.physicsBody?.collisionBitMask = 0
        arrow.physicsBody?.isDynamic = true
        addChild(arrow)

        let angle: CGFloat = fromLeft ? -.pi / 3 : .pi / 3
        arrow.zRotation = angle

        let dx = fromLeft ? size.width + 100 : -(size.width + 100)
        let dy = fromLeft ? -size.height / 2 : -size.height / 2

        let move = SKAction.moveBy(x: dx, y: dy, duration: 4)
        let remove = SKAction.removeFromParent()

        arrow.run(SKAction.sequence([move, remove]))
    }

    func spawnEnemyBird() {
        let bird = SKSpriteNode(imageNamed: "enemyBird")
        let x = CGFloat.random(in: 50...(size.width - 50))
        bird.position = CGPoint(x: x, y: size.height + 50)
        bird.zPosition = 5

        bird.physicsBody = SKPhysicsBody(texture: bird.texture!, size: bird.size)
        bird.physicsBody?.categoryBitMask = PhysicsCategory.bird
        bird.physicsBody?.contactTestBitMask = PhysicsCategory.eagle
        bird.physicsBody?.collisionBitMask = 0
        bird.physicsBody?.isDynamic = true
        bird.setScale(1.7)
        
        let moveDown = SKAction.moveBy(x: 0, y: -(size.height + 100), duration: 5)
        let remove = SKAction.removeFromParent()
        bird.run(SKAction.sequence([moveDown, remove]))
        addChild(bird)

    }

    func startSpawningCoins() {
        let spawn = SKAction.run {
            self.spawnCoin()
        }
        let wait = SKAction.wait(forDuration: 0.8)
        run(SKAction.repeatForever(SKAction.sequence([spawn, wait])))
    }

    func spawnCoin() {
        let coin = SKSpriteNode(imageNamed: "coin")
        let x = CGFloat.random(in: 50...(size.width - 50))
        coin.position = CGPoint(x: x, y: size.height + 50)
        coin.zPosition = 5
        coin.setScale(2.7)

        coin.physicsBody = SKPhysicsBody(texture: coin.texture!, size: coin.size)
        coin.physicsBody?.categoryBitMask = PhysicsCategory.coin
        coin.physicsBody?.contactTestBitMask = PhysicsCategory.eagle
        coin.physicsBody?.collisionBitMask = 0
        coin.physicsBody?.isDynamic = true
        addChild(coin)

        let move = SKAction.moveBy(x: 0, y: -size.height - 100, duration: 5)
        let remove = SKAction.removeFromParent()
        coin.run(SKAction.sequence([move, remove]))

        let bag = SKSpriteNode(imageNamed: "bag")
        bag.position = CGPoint(x: x + 30, y: coin.position.y + 50)
        bag.setScale(0.5)
        bag.zPosition = 4
        addChild(bag)

        let bagMove = SKAction.moveBy(x: -30, y: -50, duration: 1)
        let bagRemove = SKAction.removeFromParent()
        bag.run(SKAction.sequence([bagMove, bagRemove]))
    }

//    func didBegin(_ contact: SKPhysicsContact) {
//        
//        let firstBody: SKPhysicsBody
//        let secondBody: SKPhysicsBody
//
//        if contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask {
//            firstBody = contact.bodyA
//            secondBody = contact.bodyB
//        } else {
//            firstBody = contact.bodyB
//            secondBody = contact.bodyA
//        }
//
//        if firstBody.categoryBitMask == PhysicsCategory.eagle &&
//            secondBody.categoryBitMask == PhysicsCategory.coin {
//            score += 1
//            gameData?.coins += 1
//            scoreLabel.text = "Счёт: \(gameData?.coins ?? 0)"
//            secondBody.node?.removeFromParent()
//        }
//                    
//
//        if firstBody.categoryBitMask == PhysicsCategory.eagle &&
//            (secondBody.categoryBitMask == PhysicsCategory.arrow || secondBody.categoryBitMask == PhysicsCategory.bird) {
//            reduceHealth()
//            secondBody.node?.removeFromParent()
//        }
//    }
    func didBegin(_ contact: SKPhysicsContact) {
//        guard let nodeA = contact.bodyA, let nodeB = contact.bodyB else { return }
        
        let firstBody: SKPhysicsBody
        let secondBody: SKPhysicsBody
        
        if contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask {
            firstBody = contact.bodyA
            secondBody = contact.bodyB
        } else {
            firstBody = contact.bodyB
            secondBody = contact.bodyA
        }
        
        if firstBody.node == eagle {
            if secondBody.node?.name == "enemyBird" || secondBody.node?.name == "arrow" {
                reduceHealth()
                secondBody.node?.removeFromParent()
            } else if secondBody.node?.name?.contains("smallbird") == true {
                // Если поймали smallbird
                score += 5 // +10 очков за мелкую птицу
                scoreLabel.text = "\(score)"
                
                if secondBody.node?.name == "smallbird2" {
                    health = min(1.0, health + 0.2) // Прибавляем здоровье за smallbird2
                }
                
                secondBody.node?.removeFromParent()
            } else if secondBody.node?.name == "coin" {
                score += 1
                scoreLabel.text = "\(score)"
                secondBody.node?.removeFromParent()
                
            }
        }
        if firstBody.categoryBitMask == PhysicsCategory.eagle &&
            (secondBody.categoryBitMask == PhysicsCategory.arrow || secondBody.categoryBitMask == PhysicsCategory.bird) {
            reduceHealth()
            secondBody.node?.removeFromParent()
        }
        
    }
    
}

enum PhysicsCategory {
    static let eagle: UInt32 = 0x1 << 0
    static let arrow: UInt32 = 0x1 << 1
    static let bird: UInt32 = 0x1 << 2
    static let coin: UInt32 = 0x1 << 3
}

extension SKSpriteNode {
    var cornerRadius: CGFloat {
        get { return 0 } // нам не нужно получать, только устанавливать
        set {
            let shape = SKShapeNode(rectOf: size, cornerRadius: newValue)
            shape.fillColor = self.color
            shape.strokeColor = .clear
            let textureView = SKView()
            let texture = textureView.texture(from: shape)
            self.texture = texture
        }
    }
}
