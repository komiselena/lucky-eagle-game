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
    
    var backgroundTiles = [SKSpriteNode]()
    let tileSize = CGSize(width: 1024, height: 1024) // Размер одного тайла фона
    var lastCameraPosition = CGPoint.zero
    var loadedTilePositions = Set<CGPoint>() // Для отслеживания уже загруженных тайлов
    var backgroundTexture: SKTexture!
    
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
            updateHealthBar()
        }
    }
    var isInvulnerable = false
    let invulnerabilityDuration: TimeInterval = 1.0 // 1 секунда неуязвимости после удара

    var lastUpdateTime: TimeInterval = 0

    // Уменьшаем частоту появления врагов
    let enemySpawnInterval: TimeInterval = 2.4 // Было 2.5
    let maxEnemiesOnScreen = 3 // Максимальное количество врагов на экране

    // Увеличиваем скорость врагов
    let enemySpeedMultiplier: CGFloat = 2.0 // Было 1.3

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
    let eagleSpeed: CGFloat = 100
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
        backgroundColor = .clear
        physicsWorld.gravity = .zero
        physicsWorld.contactDelegate = self
        
        // Загружаем текстуру фона один раз
        backgroundTexture = SKTexture(imageNamed: gameViewModel?.backgroundImage ?? "loc1")
        backgroundTexture.filteringMode = .linear // Для плавности
        
        setupInfiniteSeamlessBackground()
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
        
        setupEagle()
        setupScoreDisplay()
        setupHealthBar()
        startSpawningEnemies()
        startSpawningSmallBirds()
        setupCoinIndicator()

    }
    

    func setupInfiniteSeamlessBackground() {
        // Удаляем старые тайлы если есть
        backgroundTiles.forEach { $0.removeFromParent() }
        backgroundTiles.removeAll()
        loadedTilePositions.removeAll()
        
        // Создаем начальные тайлы
        updateSeamlessBackground()
    }

    func updateSeamlessBackground() {
        let cameraTileX = Int(round(cameraNode.position.x / tileSize.width))
        let cameraTileY = Int(round(cameraNode.position.y / tileSize.height))
        
        // Определяем область 3x3 тайла вокруг камеры
        let loadRadius = 1
        var tilesToKeep = Set<CGPoint>()
        
        for x in (cameraTileX - loadRadius)...(cameraTileX + loadRadius) {
            for y in (cameraTileY - loadRadius)...(cameraTileY + loadRadius) {
                let tilePos = CGPoint(x: x, y: y)
                tilesToKeep.insert(tilePos)
                
                if !loadedTilePositions.contains(tilePos) {
                    addSeamlessTile(at: tilePos)
                    loadedTilePositions.insert(tilePos)
                }
            }
        }
        
        // Удаляем тайлы вне области видимости
        var tilesToRemove = [SKSpriteNode]()
        for tile in backgroundTiles {
            let tileX = Int(round(tile.position.x / tileSize.width))
            let tileY = Int(round(tile.position.y / tileSize.height))
            let tilePos = CGPoint(x: tileX, y: tileY)
            
            if !tilesToKeep.contains(tilePos) {
                tilesToRemove.append(tile)
                loadedTilePositions.remove(tilePos)
            }
        }
        
        tilesToRemove.forEach { $0.removeFromParent() }
        backgroundTiles.removeAll(where: { tilesToRemove.contains($0) })
    }

    func addSeamlessTile(at tilePos: CGPoint) {
        let tile = SKSpriteNode(texture: backgroundTexture)
        tile.name = "backgroundTile"
        tile.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        tile.position = CGPoint(
            x: tilePos.x * tileSize.width,
            y: tilePos.y * tileSize.height
        )
        tile.size = tileSize
        tile.zPosition = -100
        
        // Ключевое изменение - делаем текстуру немного больше тайла
        let textureScale: CGFloat = 1.02 // 2% увеличение
        let textureRect = CGRect(
            x: 0.5 - 0.5/textureScale,
            y: 0.5 - 0.5/textureScale,
            width: 1/textureScale,
            height: 1/textureScale
        )
        tile.texture = SKTexture(rect: textureRect, in: backgroundTexture)
        
        addChild(tile)
        backgroundTiles.append(tile)
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

        let cameraMovement = hypot(cameraNode.position.x - lastCameraPosition.x,
                                 cameraNode.position.y - lastCameraPosition.y)
        if cameraMovement > tileSize.width * 0.3 {
            updateSeamlessBackground()
            lastCameraPosition = cameraNode.position
        }

        
        updateRotation()
        updateEaglePosition()
        updateCameraAndBackground()
    }
    
    func addBackgroundTile(at tilePos: CGPoint) {
        let texture = SKTexture(imageNamed: gameViewModel?.backgroundImage ?? "loc1")
        texture.filteringMode = .linear // Для плавности
        
        let background = SKSpriteNode(texture: texture)
        background.name = "backgroundTile"
        background.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        background.position = CGPoint(
            x: tilePos.x * tileSize.width,
            y: tilePos.y * tileSize.height
        )
        background.size = tileSize
        background.zPosition = -100
        
        // Добавляем небольшое смещение текстуры для разных тайлов
        let offsetX = CGFloat(Int(tilePos.x) % 2) * 0.5
        let offsetY = CGFloat(Int(tilePos.y) % 2) * 0.5
        
        // Создаем новую текстуру с учетом смещения
        let textureRect = CGRect(x: offsetX, y: offsetY, width: 0.5, height: 0.5)
        background.texture = SKTexture(rect: textureRect, in: texture)
        
        addChild(background)
        backgroundTiles.append(background)
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
        coinIndicator.color = baseColor
    }
    


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
    

    func startSpawningSmallBirds() {
        let spawn = SKAction.run { [weak self] in
            self?.spawnSmallBird()
        }
        let wait = SKAction.wait(forDuration: Double.random(in: 4.0...7.0)) // Реже появляются
        let sequence = SKAction.sequence([spawn, wait])
        run(SKAction.repeatForever(sequence), withKey: "smallBirdSpawning")
    }
    
    func spawnSmallBird() {
        let birdNames = ["smallbird1", "smallbird2", "smallbird3", "smallbird4", "smallbird5"]
        let randomBirdName = birdNames.randomElement()!
        
        let bird = SKSpriteNode(imageNamed: randomBirdName)
        bird.name = "smallBird" // Унифицированное имя для всех маленьких птичек
        bird.setScale(0.1)
        bird.zPosition = 5
        
        // Случайная стартовая позиция на краю экрана
        let edge = Int.random(in: 0..<4) // 0: верх, 1: право, 2: низ, 3: лево
        var startPosition = CGPoint.zero
        
        switch edge {
        case 0: // Верх
            startPosition = CGPoint(
                x: CGFloat.random(in: -size.width/2...size.width/2),
                y: size.height/2 + 50
            )
        case 1: // Право
            startPosition = CGPoint(
                x: size.width/2 + 50,
                y: CGFloat.random(in: -size.height/2...size.height/2)
            )
        case 2: // Низ
            startPosition = CGPoint(
                x: CGFloat.random(in: -size.width/2...size.width/2),
                y: -size.height/2 - 50
            )
        default: // Лево
            startPosition = CGPoint(
                x: -size.width/2 - 50,
                y: CGFloat.random(in: -size.height/2...size.height/2)
            )
        }
        
        bird.position = startPosition
        
        // Физическое тело
        bird.physicsBody = SKPhysicsBody(texture: bird.texture!, size: bird.size)
        bird.physicsBody?.categoryBitMask = PhysicsCategory.bird
        bird.physicsBody?.contactTestBitMask = PhysicsCategory.eagle
        bird.physicsBody?.collisionBitMask = 0
        bird.physicsBody?.isDynamic = true
        
        addChild(bird)
        
        // Начальное направление - слегка внутрь экрана
        let inwardDirection = CGPoint(
            x: -startPosition.x * CGFloat.random(in: 0.1...0.3),
            y: -startPosition.y * CGFloat.random(in: 0.1...0.3)
        ).normalized()
        
        var currentDirection = CGVector(dx: inwardDirection.x, dy: inwardDirection.y)
        var lastDirectionChange = 0.0
        
        // Анимация полета
        let flapDuration = 0.2
        let flapUp = SKAction.scaleY(to: 0.09, duration: flapDuration)
        let flapDown = SKAction.scaleY(to: 0.11, duration: flapDuration)
        bird.run(SKAction.repeatForever(SKAction.sequence([flapUp, flapDown])))
        
        // Движение птички
        bird.run(SKAction.repeatForever(SKAction.sequence([
            SKAction.run { [weak bird, weak self] in
                guard let bird = bird, let self = self else { return }
                
                lastDirectionChange += 1.0/60.0
                
                // Меняем направление каждые 1-3 секунды
                if lastDirectionChange >= Double.random(in: 1.0...3.0) {
                    lastDirectionChange = 0
                    
                    // Новое случайное направление
                    let randomAngle = CGFloat.random(in: -.pi...(.pi))
                    currentDirection = CGVector(
                        dx: cos(randomAngle),
                        dy: sin(randomAngle)
                    )
                }
                
                // Плавное изменение направления
                let interpolationFactor: CGFloat = 0.05
                let targetX = currentDirection.dx
                let targetY = currentDirection.dy
                currentDirection.dx = currentDirection.dx * (1 - interpolationFactor) + targetX * interpolationFactor
                currentDirection.dy = currentDirection.dy * (1 - interpolationFactor) + targetY * interpolationFactor
                
                // Нормализация
                let length = sqrt(currentDirection.dx * currentDirection.dx + currentDirection.dy * currentDirection.dy)
                if length > 0 {
                    currentDirection.dx /= length
                    currentDirection.dy /= length
                }
                
                // Скорость движения
                let speed = CGFloat.random(in: 50...100)
                
                // Применяем движение
                bird.position.x += currentDirection.dx * speed * CGFloat(1.0/60.0)
                bird.position.y += currentDirection.dy * speed * CGFloat(1.0/60.0)
                
                // Плавный поворот в направлении движения
                let targetAngle = atan2(currentDirection.dy, currentDirection.dx)
                let angleDifference = (targetAngle - bird.zRotation).truncatingRemainder(dividingBy: .pi * 2)
                let shortestAngle = angleDifference > .pi ? angleDifference - .pi * 2 :
                                 angleDifference < -.pi ? angleDifference + .pi * 2 : angleDifference
                
                bird.zRotation += shortestAngle * 0.1
                
                // Удаляем, если улетели далеко за экран
                if abs(bird.position.x) > self.size.width * 1.5 || abs(bird.position.y) > self.size.height * 1.5 {
                    bird.removeFromParent()
                }
            },
            SKAction.wait(forDuration: 1.0/60.0)
        ])))
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
    
    func setupHealthBar() {
        // Создаем контейнер для health bar (для удобства позиционирования)
        let healthContainer = SKSpriteNode(color: .clear, size: CGSize(width: 200, height: 40))
        healthContainer.position = CGPoint(x: 0, y: scoreLabel.position.y - 90) // Чуть ниже score
        healthContainer.zPosition = 1000 // Высокий zPosition, чтобы был поверх всего
        cameraNode.addChild(healthContainer)
        
        // Фон health bar
        healthBarBackground = SKSpriteNode(color: UIColor(white: 0.4, alpha: 0.6), size: CGSize(width: 180, height: 20))
        healthBarBackground.position = CGPoint(x: 0, y: scoreLabel.position.y - 90)
        healthBarBackground.zPosition = 1
        healthBarBackground.cornerRadius = 10
        healthContainer.addChild(healthBarBackground)

        // Сам health bar
        healthBar = SKSpriteNode(color: UIColor.red, size: CGSize(width: 175, height: 15))
        healthBar.anchorPoint = CGPoint(x: 0.0, y: 0.5)
        healthBar.position = CGPoint(x: -healthBarBackground.size.width/2 + 2.5, y: scoreLabel.position.y - 90)
        healthBar.zPosition = 2
        healthBar.cornerRadius = 7
        healthContainer.addChild(healthBar)

        // Иконка сердца
        let heart = SKSpriteNode(imageNamed: "heart")
        heart.size = CGSize(width: 25, height: 25)
        heart.position = CGPoint(x: -healthBarBackground.size.width/2 - heart.size.width/2 - 5,
                                y: scoreLabel.position.y - 90)
        heart.zPosition = 3
        healthContainer.addChild(heart)
        
        // Добавляем белую рамку для лучшей видимости
        let border = SKShapeNode(rect: CGRect(x: -healthBarBackground.size.width/2,
                                             y: -healthBarBackground.size.height/2,
                                             width: healthBarBackground.size.width,
                                             height: healthBarBackground.size.height),
                                cornerRadius: 10)
        border.strokeColor = .white
        border.lineWidth = 1.5
        border.zPosition = 4
        healthBarBackground.addChild(border)
    }
    func updateHealthBar() {
        let maxWidth: CGFloat = 175
        let newWidth = max(0, maxWidth * health)
        
        
        // Сначала сбрасываем цвет
        healthBar.removeAllActions()
        healthBar.color = .red
        
        // Затем анимируем изменение размера
        healthBar.run(SKAction.resize(toWidth: newWidth, duration: 0.2))
    }
    var lastHitTime: TimeInterval = 0
    let hitCooldown: TimeInterval = 0.5 // Защита от быстрых последовательных ударов

    func reduceHealth() {
        let now = CACurrentMediaTime()
        guard now - lastHitTime > hitCooldown else { return }
        lastHitTime = now
        
        health -= 0.05 // Уменьшаем здоровье на 5%
        
        // Эффект "мигания" при ударе
        let flashRed = SKAction.run {
            self.healthBar.color = .red
            self.healthBar.colorBlendFactor = 1.0
        }
        let restoreColor = SKAction.run {
            self.updateHealthBar() // Восстанавливаем правильный цвет
        }
        
        healthBar.run(SKAction.sequence([
            flashRed,
            SKAction.wait(forDuration: 0.1),
            restoreColor
        ]))
        
        if health <= 0 {
            gameOver()
        }
    }

    func gameOver() {
        guard gameViewModel?.isGameOver == false else { return }
        eagle.removeFromParent()
        DispatchQueue.main.async {
            self.gameViewModel?.isGameOver = true

        }
        health = 1
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
        
        // Выбираем сторону появления (лево или право)
        let side: CGFloat = Bool.random() ? 1 : -1
        
        // Стартовая позиция - сбоку от орла на некотором расстоянии
        let baseAngle = atan2(eagleVelocity.dy, eagleVelocity.dx)
        let sideAngle = baseAngle + (side * .pi/2) // 90 градусов влево или вправо
        
        // Расстояние появления
        let distance = CGFloat.random(in: minEnemyDistance...maxEnemyDistance)
        
        bird.position = CGPoint(
            x: eagle.position.x + cos(sideAngle) * distance,
            y: eagle.position.y + sin(sideAngle) * distance
        )
        
        // Начальный поворот
        bird.zRotation = baseAngle - .pi/2
        
        addChild(bird)
        
        // Переменные для управления поведением
        var currentDirection = CGVector(dx: sin(baseAngle), dy: cos(baseAngle))
        var targetDirection = currentDirection
        var lastBehaviorUpdate = 0.0
        var lastDirectionChange = 0.0
        var currentSpeed = eagleSpeed * enemySpeedMultiplier * CGFloat.random(in: 0.8...1.2)
        
        bird.run(SKAction.repeatForever(SKAction.sequence([
            SKAction.run { [weak self, weak bird] in
                guard let self = self, let bird = bird else { return }
                
                // Время с последнего обновления
                lastBehaviorUpdate += 1.0/60.0
                lastDirectionChange += 1.0/60.0
                
                // Обновляем цель каждые 0.5-1.5 секунды
                if lastDirectionChange >= Double.random(in: 0.5...1.5) {
                    lastDirectionChange = 0
                    
                    // Рассчитываем базовое направление к игроку
                    let toPlayer = CGVector(
                        dx: self.eagle.position.x - bird.position.x,
                        dy: self.eagle.position.y - bird.position.y
                    )
                    
                    // Нормализуем вектор
                    let distanceToPlayer = hypot(toPlayer.dx, toPlayer.dy)
                    let normalizedDirection = CGVector(
                        dx: toPlayer.dx/distanceToPlayer,
                        dy: toPlayer.dy/distanceToPlayer
                    )
                    
                    // Добавляем случайное отклонение
                    let randomAngle = CGFloat.random(in: -.pi/3 ... .pi/3)
                    targetDirection = CGVector(
                        dx: normalizedDirection.dx * cos(randomAngle) - normalizedDirection.dy * sin(randomAngle),
                        dy: normalizedDirection.dx * sin(randomAngle) + normalizedDirection.dy * cos(randomAngle)
                    )
                    
                    // Плавное изменение скорости
                    currentSpeed = self.eagleSpeed * self.enemySpeedMultiplier * CGFloat.random(in: 0.8...1.2)
                }
                
                // Плавное изменение направления (интерполяция)
                let interpolationFactor: CGFloat = 0.1 // Меньше значение = плавнее поворот
                currentDirection.dx = currentDirection.dx * (1 - interpolationFactor) + targetDirection.dx * interpolationFactor
                currentDirection.dy = currentDirection.dy * (1 - interpolationFactor) + targetDirection.dy * interpolationFactor
                
                // Нормализуем вектор направления
                let length = sqrt(currentDirection.dx * currentDirection.dx + currentDirection.dy * currentDirection.dy)
                if length > 0 {
                    currentDirection.dx /= length
                    currentDirection.dy /= length
                }
                
                // Применяем движение
                bird.position.x += currentDirection.dx * currentSpeed * CGFloat(1.0/60.0)
                bird.position.y += currentDirection.dy * currentSpeed * CGFloat(1.0/60.0)
                
                // Плавный поворот птицы в направлении движения
                let targetAngle = atan2(currentDirection.dy, currentDirection.dx)
                let angleDifference = (targetAngle - bird.zRotation - .pi/2).truncatingRemainder(dividingBy: .pi * 2)
                let shortestAngle = angleDifference > .pi ? angleDifference - .pi * 2 :
                                   angleDifference < -.pi ? angleDifference + .pi * 2 : angleDifference
                
                let rotationSpeed: CGFloat = 0.05 // Меньше значение = плавнее поворот
                bird.zRotation += shortestAngle * rotationSpeed
                
                // Удаляем, если слишком далеко от игрока
                let currentDistance = hypot(self.eagle.position.x - bird.position.x,
                                          self.eagle.position.y - bird.position.y)
                if currentDistance > self.maxEnemyDistance * 2 {
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
            if secondBody.node?.name == "smallBird" {
                gameData?.coins += 5
                scoreLabel.text = "\(gameData?.coins ?? 0)"
                if secondBody.node?.name == "smallbird2" {
                    health = min(1.0, health + 0.2)
                }
                secondBody.node?.removeFromParent()
            }
        }
        if firstBody.categoryBitMask == PhysicsCategory.eagle &&
               (secondBody.categoryBitMask == PhysicsCategory.arrow ||
                secondBody.categoryBitMask == PhysicsCategory.enemyBird) {
                reduceHealth()
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
extension CGPoint {
    func normalized() -> CGPoint {
        let length = sqrt(x * x + y * y)
        return length > 0 ? CGPoint(x: x / length, y: y / length) : .zero
    }
}
