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
    
    var lastPlayerPositions = [CGPoint]()
    let maxPositionHistory = 10
    var enemyBirds = [SKSpriteNode]()
    var arrows = [SKSpriteNode]()

    var health: CGFloat = 1.0 {
        didSet {
            
        }
    }
    
    var lastUpdateTime: TimeInterval = 0

    // Уменьшаем частоту появления врагов
    let enemySpawnInterval: TimeInterval = 2.5 // Было 2.5
    let maxEnemiesOnScreen = 3 // Максимальное количество врагов на экране

    // Увеличиваем скорость врагов
    let enemySpeedMultiplier: CGFloat = 2.5 // Было 1.3

    // Новые параметры для поведения врагов
    let enemyApproachAngleRange: CGFloat = .pi/3 // ±60 градусов для подрезания
    let enemyUpdateInterval: TimeInterval = 1.0 // Частота смены стратегии


    
    let minEnemyDistance: CGFloat = 800  // Минимальная дистанция появления
    let maxEnemyDistance: CGFloat = 1200 // Максимальная дистанция
    let arrowSpawnInterval: TimeInterval = 4.0 // Стрелы тоже реже

    
    var enemySpawnTimer: TimeInterval = 0
    var arrowSpawnTimer: TimeInterval = 0

    
    // Настройки движения и камеры
    let cameraNode = SKCameraNode()
    let eagleSpeed: CGFloat = 150
    var eagleVelocity: CGVector = .zero
    var eagleRotation: CGFloat = 0
    
    // Для бесконечного поля
    var backgroundLayers = [SKSpriteNode]()
    let backgroundSize = CGSize(width: 2000, height: 2000)
    
    // Управление поворотом
    var leftButtonPressed = false
    var rightButtonPressed = false
    var rotationTime: TimeInterval = 0
    let maxRotationSpeed: CGFloat = 0.15
    let minRotationSpeed: CGFloat = 0.05
    
    
    let coinSpawnInterval: TimeInterval = 4.0
    var coinSpawnTimer: TimeInterval = 0
    let coinSize: CGFloat = 4.0 // Увеличено с 3.5
    let coinLifetime: TimeInterval = 30.0 // Увеличено с 20 до 30 секунд
    var currentCoin: SKSpriteNode?
    var coinIndicator: SKSpriteNode!


    override func didMove(to view: SKView) {
        backgroundColor = .clear // Прозрачный фон, чтобы был виден только наш background
        physicsWorld.speed = 1.0
//        physicsWorld.timeStep = 1.0/60.0  // Фиксированный шаг физики

        physicsWorld.gravity = .zero
        physicsWorld.contactDelegate = self
        self.physicsBody = SKPhysicsBody(edgeLoopFrom: CGRect(
            x: -size.width * 2,
            y: -size.height * 2,
            width: size.width * 5,
            height: size.height * 5
        ))
        
        // Настройка камеры
        addChild(cameraNode)
        camera = cameraNode
        
        setupInfiniteBackground()
        setupEagle()
        setupScoreDisplay()
        startSpawningEnemies()
        startSpawningSmallBirds()
        setupCoinIndicator()

    }
    
    func setupCoinIndicator() {
        // Создаем белый прямоугольник
        coinIndicator = SKSpriteNode(color: .white, size: CGSize(width: 20, height: 5))
        coinIndicator.zPosition = 100
        coinIndicator.alpha = 0.7 // Полупрозрачный
        coinIndicator.name = "coinIndicator"
        addChild(coinIndicator)
    }


    func spawnStaticCoin() {
        // Удаляем предыдущую монету, если она есть
        currentCoin?.removeFromParent()
        
        let coin = SKSpriteNode(imageNamed: "coin")
        coin.name = "coin"
        coin.zPosition = 5
        coin.setScale(coinSize)
        
        // Физическое тело для точного определения столкновений
        coin.physicsBody = SKPhysicsBody(circleOfRadius: coin.size.width/2)
        coin.physicsBody?.categoryBitMask = PhysicsCategory.coin
        coin.physicsBody?.contactTestBitMask = PhysicsCategory.eagle
        coin.physicsBody?.collisionBitMask = 0
        coin.physicsBody?.isDynamic = false
        
        let angle = CGFloat.random(in: 0..<(.pi*2))
        let distance = size.width * 0.8
        let spawnPosition = CGPoint(
            x: cameraNode.position.x + cos(angle) * distance,
            y: cameraNode.position.y + sin(angle) * distance
        )
        
        coin.position = spawnPosition
        addChild(coin)
        
        // Анимация появления
        coin.alpha = 0
        coin.run(SKAction.sequence([
            SKAction.wait(forDuration: 0.5),
            SKAction.group([
                SKAction.fadeIn(withDuration: 0.5),
                SKAction.scale(to: coinSize, duration: 0.5)
            ])
        ]))
        
        currentCoin = coin
        
    }
    // Новый метод для удаления монеты
    func removeCoin(coin: SKSpriteNode) {
        let fadeOut = SKAction.fadeOut(withDuration: 0.5)
        coin.run(fadeOut) {
            coin.removeFromParent()
            if self.currentCoin == coin {
                self.currentCoin = nil
            }
        }
    }


    func setupInfiniteBackground() {
        // Создаем 3 слоя фона для параллакс-эффекта
        for i in 0..<3 {
            let bg = SKSpriteNode(imageNamed: gameViewModel?.backgroundImage ?? "loc1")
            bg.name = "background_\(i)"
            bg.texture?.filteringMode = .nearest

            bg.anchorPoint = CGPoint(x: 0.5, y: 0.5)
            bg.position = CGPoint.zero
            bg.zPosition = CGFloat(-10 - i)
            bg.size = backgroundSize
            addChild(bg)
            backgroundLayers.append(bg)
        }
    }

    override func update(_ currentTime: TimeInterval) {
        // Сохраняем позиции игрока
        lastPlayerPositions.insert(eagle.position, at: 0)
        if lastPlayerPositions.count > maxPositionHistory {
            lastPlayerPositions.removeLast()
        }
        let deltaTime = lastUpdateTime == 0 ? 0 : currentTime - lastUpdateTime
        lastUpdateTime = currentTime

        
        // Обновляем таймеры спавна
        enemySpawnTimer += 1.0 / 60.0
        arrowSpawnTimer += 1.0 / 60.0
        
        // Спавн вражеских птиц
        if enemySpawnTimer >= enemySpawnInterval {
            enemySpawnTimer = 0
            spawnEnemyBird()
        }
        
        // Спавн стрел
        if arrowSpawnTimer >= arrowSpawnInterval {
            arrowSpawnTimer = 0
            spawnArrow()
        }
        updateEaglePosition(deltaTime: deltaTime)

        
        if let coin = currentCoin {
            updateCoinIndicator(coinPosition: coin.position)
        } else {
            coinIndicator.alpha = 0
        }
        
        // Спавн монет
        coinSpawnTimer += deltaTime
        if coinSpawnTimer >= coinSpawnInterval && currentCoin == nil {
            coinSpawnTimer = 0
            spawnStaticCoin()
        }

        
        updateRotation()
        updateEaglePosition()
        updateCameraAndBackground()
    }

    func updateEaglePosition(deltaTime: TimeInterval) {
        guard eagle != nil else { return }
        
        let direction = CGVector(dx: sin(eagleRotation), dy: cos(eagleRotation))
        eagleVelocity = CGVector(dx: direction.dx * eagleSpeed,
                                dy: direction.dy * eagleSpeed)
        
        // Используем реальный deltaTime
        eagle.position.x += eagleVelocity.dx * CGFloat(deltaTime)
        eagle.position.y += eagleVelocity.dy * CGFloat(deltaTime)
        
        eagle.zRotation = -eagleRotation
    }

    
    // Метод для обновления индикатора
    func updateCoinIndicator(coinPosition: CGPoint) {
        let cameraRect = CGRect(
            x: cameraNode.position.x - size.width/2,
            y: cameraNode.position.y - size.height/2,
            width: size.width,
            height: size.height
        )
        
        // Если монета на экране - скрываем индикатор
        if cameraRect.contains(coinPosition) {
            coinIndicator.alpha = 0
            return
        }
        
        // Показываем индикатор
        coinIndicator.alpha = 0.7
        
        // Вычисляем направление к монете
        let direction = CGPoint(
            x: coinPosition.x - cameraNode.position.x,
            y: coinPosition.y - cameraNode.position.y
        )
        let angle = atan2(direction.y, direction.x)
        
        // Позиция на краю экрана
        let edgeMargin: CGFloat = 30
        let maxDistance = min(size.width/2, size.height/2) - edgeMargin
        let indicatorPosition = CGPoint(
            x: cameraNode.position.x + cos(angle) * maxDistance,
            y: cameraNode.position.y + sin(angle) * maxDistance
        )
        
        // Обновляем позицию и поворот
        coinIndicator.position = indicatorPosition
        coinIndicator.zRotation = angle
        
        
        let baseColor = UIColor.white
//        let targetColor = UIColor.yellow
//        let currentColor = blend(color1: baseColor, color2: targetColor, ratio: 1.0 - colorRatio)
        
        coinIndicator.color = baseColor
    }
    
//    func blend(color1: UIColor, color2: UIColor, ratio: CGFloat) -> UIColor {
//        let ratio = max(0, min(1, ratio))
//        let components1 = color1.cgColor.components ?? [1, 1, 1, 1]
//        let components2 = color2.cgColor.components ?? [1, 1, 0, 1]
//        
//        let r = components1[0] * (1 - ratio) + components2[0] * ratio
//        let g = components1[1] * (1 - ratio) + components2[1] * ratio
//        let b = components1[2] * (1 - ratio) + components2[2] * ratio
//        
//        return UIColor(red: r, green: g, blue: b, alpha: 1)
//    }


    func updateRotation() {
        if leftButtonPressed || rightButtonPressed {
            rotationTime += 1.0 / 60.0
            let rotationSpeed = min(maxRotationSpeed, minRotationSpeed + CGFloat(rotationTime) * 0.02)
            
            if leftButtonPressed {
                eagleRotation -= rotationSpeed
            }
            if rightButtonPressed {
                eagleRotation += rotationSpeed
            }
        } else {
            rotationTime = 0
        }
    }
    
    func updateEaglePosition() {
        guard eagle != nil else { return }
        
        // Рассчитываем скорость на основе текущего угла
        let direction = CGVector(dx: sin(eagleRotation), dy: cos(eagleRotation))
        eagleVelocity = CGVector(dx: direction.dx * eagleSpeed,
                                dy: direction.dy * eagleSpeed)
        
        // Применяем скорость к позиции орла
        let deltaTime = 1.0 / 60.0
        eagle.position.x += eagleVelocity.dx * CGFloat(deltaTime)
        eagle.position.y += eagleVelocity.dy * CGFloat(deltaTime)
        
        // Поворачиваем орла в направлении движения
        eagle.zRotation = -eagleRotation
    }
    
    func updateCameraAndBackground() {
        // Плавное движение камеры за орлом
        cameraNode.position = eagle.position
        
        // Параллакс-эффект для фона
        for (index, bg) in backgroundLayers.enumerated() {
            let parallaxFactor = CGFloat(index + 1) * 0.3
            bg.position = CGPoint(
                x: eagle.position.x * parallaxFactor,
                y: eagle.position.y * parallaxFactor
            )
        }
    }
    
    func rotateEagle(clockwise: Bool, start: Bool) {
        if start {
            clockwise ? (rightButtonPressed = true) : (leftButtonPressed = true)
        } else {
            clockwise ? (rightButtonPressed = false) : (leftButtonPressed = false)
        }
    }

    func setupEagle() {
        let eagleImageName = gameViewModel?.eagleSkin ?? "eagle1"
        eagle = SKSpriteNode(imageNamed: eagleImageName)
        eagle.name = eagleImageName
        
        if eagle.name == "eagle2" || eagle.name == "eagle3" {
            eagle.setScale(0.2)
        } else {
            eagle.setScale(1.8)
        }
        
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
    
//    func moveEagle(left: Bool, startMoving: Bool) {
//        if startMoving {
//            if left {
//                isMovingLeft = true
//                isMovingRight = false
//            } else {
//                isMovingRight = true
//                isMovingLeft = false
//            }
//        } else {
//            // Останавливаем движение, если кнопка отпущена
//            if left {
//                isMovingLeft = false
//            } else {
//                isMovingRight = false
//            }
//        }
//    }

    func startSpawningSmallBirds() {
        let spawn = SKAction.run {
            self.spawnSmallBird()
        }
        let wait = SKAction.wait(forDuration: Double.random(in: 5.0...8.0))
        let sequence = SKAction.sequence([spawn, wait])
        run(SKAction.repeatForever(sequence))
    }
    
    func spawnSmallBird() {
        let birdNames = ["smallbird1", "smallbird2", "smallbird3", "smallbird4", "smallbird5"]
        let randomBirdName = birdNames.randomElement()!
        
        let bird = SKSpriteNode(imageNamed: randomBirdName)
        bird.name = randomBirdName
        bird.setScale(0.1)
        bird.zPosition = 5
        
        let fromLeft = Bool.random()
        let startX = fromLeft ? -50 : size.width + 50
        let startY = CGFloat.random(in: 100...(size.height - 100))
        bird.position = CGPoint(x: startX, y: startY)
        
        bird.physicsBody = SKPhysicsBody(texture: bird.texture!, size: bird.size)
        bird.physicsBody?.categoryBitMask = PhysicsCategory.bird
        bird.physicsBody?.contactTestBitMask = PhysicsCategory.eagle
        bird.physicsBody?.collisionBitMask = 0
        bird.physicsBody?.isDynamic = true
        
        addChild(bird)
        
        let dx = fromLeft ? CGFloat.random(in: 300...500) : CGFloat.random(in: -500 ... -300)
        let dy = CGFloat.random(in: -100...100)
        
        let move = SKAction.moveBy(x: dx, y: dy, duration: 4.0)
        let remove = SKAction.removeFromParent()
        bird.run(SKAction.sequence([move, remove]))
    }


    
    func setupScoreDisplay() {
        let scoreTitle = SKSpriteNode(imageNamed: "score")
        scoreTitle.setScale(2.7)
        scoreTitle.position = CGPoint(x: 0, y: size.height/2 - scoreTitle.size.height/2 - 20)
        scoreTitle.zPosition = 1000 // Очень высокий zPosition
        cameraNode.addChild(scoreTitle) // Добавляем к камере, а не к сцене
        
        let scoreBar = SKSpriteNode(imageNamed: "Group 8")
        scoreBar.setScale(2.9)
        scoreBar.position = CGPoint(x: 0, y: scoreTitle.position.y - scoreTitle.size.height/2 - scoreBar.size.height/2 - 3)
        scoreBar.zPosition = 1000
        cameraNode.addChild(scoreBar)
        
        let coin = SKSpriteNode(imageNamed: "coin")
        coin.setScale(2.8)
        coin.position = CGPoint(
            x: -scoreBar.size.width * 0.315,
            y: scoreBar.position.y
        )
        coin.zPosition = 1001
        cameraNode.addChild(coin)
        
        scoreLabel = SKLabelNode(fontNamed: "HelveticaNeue-Bold")
        scoreLabel.fontSize = 20
        scoreLabel.fontColor = .white
        scoreLabel.text = "\(gameData?.coins ?? 0)"
        scoreLabel.verticalAlignmentMode = .center
        scoreLabel.horizontalAlignmentMode = .left
        scoreLabel.position = CGPoint(
            x: coin.position.x + coin.size.width/2 + 10,
            y: coin.position.y
        )
        scoreLabel.zPosition = 1001
        cameraNode.addChild(scoreLabel)
    }
    
//    func setupHealthBar() {
//        healthBarBackground = SKSpriteNode(color: UIColor.brown, size: CGSize(width: 180, height: 20))
//        healthBarBackground.position = CGPoint(x: size.width / 2, y: size.height - 90)
//        healthBarBackground.zPosition = 50
//        healthBarBackground.cornerRadius = 15
//        addChild(healthBarBackground)
//
//        healthBar = SKSpriteNode(color: UIColor.red, size: CGSize(width: 165, height: 15))
//        healthBar.anchorPoint = CGPoint(x: 0.0, y: 0.5)
//        healthBar.position = CGPoint(x: healthBarBackground.position.x - 100, y: healthBarBackground.position.y)
//        healthBar.zPosition = 51
//
//        healthBar.cornerRadius = 15
//        let heart = SKSpriteNode(imageNamed: "heart")
//        heart.size = CGSize(width: 30, height: 30)
//        heart.position = CGPoint(x: healthBarBackground.position.x - healthBarBackground.size.width / 2,
//                                 y: healthBarBackground.position.y)
//        heart.zPosition = 52
//        addChild(healthBar)
//        addChild(heart)
//
//    }
//
//    func updateHealthBar() {
//        let maxWidth: CGFloat = 180
//        let newWidth = max(0, maxWidth * health)
//
//        let resize = SKAction.resize(toWidth: newWidth, duration: 0.3)
//        healthBar.run(resize)
//    }
//
//    func reduceHealth() {
//        health -= 0.05
//        print("Оставшееся здоровье: \(health)")
//        if health <= 0 {
//            print("Game Over Condition Met!")
//            gameOver()
//            print("gameViewModel?.isGameOver set to true")
//        }
//    }

    func gameOver() {
        guard gameViewModel?.isGameOver == false else { return }
        eagle.removeFromParent()
        DispatchQueue.main.async {
            self.gameViewModel?.isGameOver = true

        }
//        health = 1
        score = 0

    }
    

    func startSpawningEnemies() {
        let spawn = SKAction.run {
            self.spawnArrow()

            self.spawnEnemyBird()
//            self.spawnEnemyBird()
        }
        let wait = SKAction.wait(forDuration: Double.random(in: 2.0...5.0))
        let sequence = SKAction.sequence([spawn, wait])
        run(SKAction.repeatForever(sequence))
    }
    
    func updateEnemyBirds() {
        for bird in enemyBirds {
            // Дополнительная логика для птиц
            // Например, можно добавить случайные маневры
            if Int.random(in: 0...100) < 5 {
                let randomAngle = CGFloat.random(in: -0.3...0.3)
                let impulse = CGVector(dx: CGFloat.random(in: -50...50),
                                  dy: CGFloat.random(in: -50...50))
                bird.physicsBody?.applyImpulse(impulse)
            }
        }
    }


    // Новая версия spawnArrow()
    func spawnArrow() {
        let arrow = SKSpriteNode(imageNamed: "arrow")
        arrow.zPosition = 5
        arrow.name = "arrow"
        
        // Физическое тело
        arrow.physicsBody = SKPhysicsBody(texture: arrow.texture!, size: arrow.size)
        arrow.physicsBody?.categoryBitMask = PhysicsCategory.arrow
        arrow.physicsBody?.contactTestBitMask = PhysicsCategory.eagle
        arrow.physicsBody?.collisionBitMask = 0
        arrow.physicsBody?.isDynamic = true
        
        // Стартовая позиция - случайная точка в радиусе 1000px от орла
        let angle = CGFloat.random(in: 0..<(.pi * 2))
        let distance: CGFloat = 1000
        let startPosition = CGPoint(
            x: eagle.position.x + cos(angle) * distance,
            y: eagle.position.y + sin(angle) * distance
        )
        
        arrow.position = startPosition
        
        // Направление не точно в орла, а с небольшим отклонением
        let deviation = CGFloat.random(in: -0.2...0.2)
        let targetPosition = CGPoint(
            x: eagle.position.x + cos(angle + .pi + deviation) * 200,
            y: eagle.position.y + sin(angle + .pi + deviation) * 200
        )
        
        // Поворот стрелы
        let dx = targetPosition.x - startPosition.x
        let dy = targetPosition.y - startPosition.y
        arrow.zRotation = atan2(dy, dx)
        
        addChild(arrow)
        
        // Движение стрелы
        let speed: CGFloat = 400
        let distanceToTarget = hypot(dx, dy)
        let duration = TimeInterval(distanceToTarget / speed)
        
        let moveAction = SKAction.move(to: targetPosition, duration: duration)
        let removeAction = SKAction.removeFromParent()
        arrow.run(SKAction.sequence([moveAction, removeAction]))
    }

    func spawnEnemyBird() {
        // Проверяем количество уже существующих врагов
        let currentEnemies = children.filter { $0.name == "enemyBird" }.count
        if currentEnemies >= maxEnemiesOnScreen {
            return
        }
        
        let bird = SKSpriteNode(imageNamed: "enemyBird")
        bird.name = "enemyBird"
        bird.zPosition = 5
        bird.setScale(1.7)
        
        bird.physicsBody = SKPhysicsBody(texture: bird.texture!, size: bird.size)
        bird.physicsBody?.categoryBitMask = PhysicsCategory.enemyBird
        bird.physicsBody?.contactTestBitMask = PhysicsCategory.eagle
        bird.physicsBody?.collisionBitMask = 0
        bird.physicsBody?.isDynamic = true
        
        // Стартовая позиция - не прямо сзади, а сбоку
        let baseAngle = atan2(eagleVelocity.dy, eagleVelocity.dx)
        let sideAngle = Bool.random() ? baseAngle + .pi/2 : baseAngle - .pi/2
        let distance = CGFloat.random(in: minEnemyDistance...maxEnemyDistance)
        
        bird.position = CGPoint(
            x: eagle.position.x + cos(sideAngle) * distance,
            y: eagle.position.y + sin(sideAngle) * distance
        )
        
        // Начальный поворот в сторону игрока
        let initialAngle = atan2(eagle.position.y - bird.position.y,
                               eagle.position.x - bird.position.x)
//        bird.zRotation = initialAngle - .pi/2
        
        addChild(bird)
        
        // Переменные для управления поведением
        var currentApproachAngle = CGFloat.random(in: -enemyApproachAngleRange...enemyApproachAngleRange)
        var lastBehaviorUpdate = 0.0
        
        bird.run(SKAction.repeatForever(SKAction.sequence([
            SKAction.run { [weak self, weak bird] in
                guard let self = self, let bird = bird else { return }
                
                // Обновляем стратегию каждые enemyUpdateInterval секунд
                lastBehaviorUpdate += 1.0/60.0
                if lastBehaviorUpdate >= enemyUpdateInterval {
                    lastBehaviorUpdate = 0
                    // Случайно меняем угол подлета
                    currentApproachAngle = CGFloat.random(in: -enemyApproachAngleRange...enemyApproachAngleRange)
                }
                
                // Рассчитываем направление к игроку с учетом угла подлета
                let toPlayer = CGVector(
                    dx: self.eagle.position.x - bird.position.x,
                    dy: self.eagle.position.y - bird.position.y
                )
                
                // Нормализуем и поворачиваем вектор для подрезания
                let distanceToPlayer = hypot(toPlayer.dx, toPlayer.dy)
                let normalizedDirection = CGVector(
                    dx: toPlayer.dx/distanceToPlayer,
                    dy: toPlayer.dy/distanceToPlayer
                )
                
                // Поворачиваем вектор направления для подрезания
                let approachDirection = CGVector(
                    dx: normalizedDirection.dx * cos(currentApproachAngle) - normalizedDirection.dy * sin(currentApproachAngle),
                    dy: normalizedDirection.dx * sin(currentApproachAngle) + normalizedDirection.dy * cos(currentApproachAngle)
                )
                
                // Применяем движение
                let birdSpeed = self.eagleSpeed * self.enemySpeedMultiplier
                bird.position.x += approachDirection.dx * birdSpeed * CGFloat(1.0/60.0)
                bird.position.y += approachDirection.dy * birdSpeed * CGFloat(1.0/60.0)
                
                // Плавный поворот в направлении движения (без вращения вокруг оси)
                let targetAngle = atan2(approachDirection.dy, approachDirection.dx) - .pi/2
                let angleDifference = (targetAngle - bird.zRotation + .pi).truncatingRemainder(dividingBy: .pi*2) - .pi
                bird.zRotation += angleDifference * 0.1
                
                // Удаляем, если слишком далеко от игрока
                if distanceToPlayer > self.maxEnemyDistance * 2 {
                    bird.removeFromParent()
                }
            },
            SKAction.wait(forDuration: 1.0/60.0)
        ])))
    }

//    func startSpawningCoins() {
//        let spawn = SKAction.run {
//            self.spawnCoin()
//        }
//        let wait = SKAction.wait(forDuration: 0.8)
//        run(SKAction.repeatForever(SKAction.sequence([spawn, wait])))
//    }


    func didBegin(_ contact: SKPhysicsContact) {
        
        let firstBody: SKPhysicsBody
        let secondBody: SKPhysicsBody
        
        if contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask {
            firstBody = contact.bodyA
            secondBody = contact.bodyB
        } else {
            firstBody = contact.bodyB
            secondBody = contact.bodyA
        }
        
        if firstBody.categoryBitMask == PhysicsCategory.eagle {
            if secondBody.node?.name?.contains("smallbird") == true {
                gameData?.coins += 5
                scoreLabel.text = "\(gameData?.coins ?? 0)"
                if secondBody.node?.name == "smallbird2" {
                    health = min(1.0, health + 0.2)
                }
                secondBody.node?.removeFromParent()
            }
        }
        if firstBody.categoryBitMask == PhysicsCategory.eagle &&
            (secondBody.categoryBitMask == PhysicsCategory.arrow || secondBody.categoryBitMask == PhysicsCategory.enemyBird) {
//            reduceHealth()
            secondBody.node?.removeFromParent()
        }
        if firstBody.categoryBitMask == PhysicsCategory.eagle &&
           secondBody.categoryBitMask == PhysicsCategory.coin {
            
            guard let coin = secondBody.node as? SKSpriteNode, coin == currentCoin else { return }
            
            // Эффект сбора
            let collectAction = SKAction.sequence([
                SKAction.group([
                    SKAction.fadeOut(withDuration: 0.3),
                    SKAction.scale(to: 0.1, duration: 0.3)
                ]),
                SKAction.removeFromParent()
            ])
            
            // Начисление очков
            gameData?.coins += 5
            score += 5
            scoreLabel.text = "\(gameData?.coins ?? 0)"
            
            coin.run(collectAction)
            currentCoin = nil
            coinSpawnTimer = 0
        }

        
    }
    
}
extension CGPoint {
    func lerp(to point: CGPoint, factor: CGFloat) -> CGPoint {
        return CGPoint(
            x: self.x + (point.x - self.x) * factor,
            y: self.y + (point.y - self.y) * factor
        )
    }
}



enum PhysicsCategory {
    static let eagle: UInt32 = 0x1 << 0
    static let arrow: UInt32 = 0x1 << 1
    static let bird: UInt32 = 0x1 << 2
    static let coin: UInt32 = 0x1 << 3
    static let enemyBird: UInt32 = 0x1 << 4

}

extension SKSpriteNode {
    var cornerRadius: CGFloat {
        get { return 0 }
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
extension CGVector {
    func normalized() -> CGVector {
        let length = sqrt(dx*dx + dy*dy)
        return length > 0 ? CGVector(dx: dx/length, dy: dy/length) : .zero
    }
}
