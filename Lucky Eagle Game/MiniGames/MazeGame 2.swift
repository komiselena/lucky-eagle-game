//
//  MazeGame.swift
//  Lucky Eagle Game
//
//  Created by Mac on 26.04.2025.
//

import Foundation
import UIKit
import SpriteKit



// MARK: - SpriteKit GameScene
class MazeGameScene: SKScene {
    private var mazeNode: SKSpriteNode!
    private var playerNode: SKShapeNode!
    private var mazeCGImage: CGImage?
    private var prizeNode: SKSpriteNode!
    private let playerRadius: CGFloat = 3
    let moveStep: CGFloat = 3
    private let startPoint = CGPoint(x: 186, y: 186) // поставь на праввый верхний угол
    private let exitPoint = CGPoint(x: 100, y: 100) // середина лабиринта должна быть
    var onGameWon: (() -> Void)?
    
    override func didMove(to view: SKView) {
        backgroundColor = .brown2
        
        // Добавляем лабиринт
        mazeNode = SKSpriteNode(imageNamed: "maze") // имя вашей картинки
        mazeNode.anchorPoint = CGPoint(x: 0, y: 0)
        mazeNode.position = CGPoint(x: 0, y: 0)
        mazeNode.size = CGSize(width: 196, height: 196)
        addChild(mazeNode)
        
        // Получаем CGImage для проверки цвета
        if let img = UIImage(named: "maze")?.cgImage {
            mazeCGImage = img
        }
        prizeNode = SKSpriteNode(imageNamed: "prize")
        prizeNode.position = CGPoint(x: 100, y: 100)
        prizeNode.size = CGSize(width: 20, height: 20)
        mazeNode.addChild(prizeNode)

        // Добавляем игрока
        playerNode = SKShapeNode(circleOfRadius: playerRadius)
        playerNode.fillColor = .purple1
        playerNode.strokeColor = .clear
        playerNode.position = startPoint
        mazeNode.addChild(playerNode)
    }
    
    func resetGame() {
        playerNode.position = startPoint
    }
    
    func movePlayer(dx: CGFloat, dy: CGFloat) {
        #if DEBUG
        print("Попытка движения: dx=\(dx), dy=\(dy)")
        #endif
        
        let newPos = CGPoint(x: playerNode.position.x + dx, y: playerNode.position.y + dy)
        
        // Проверка выхода за пределы лабиринта
        guard mazeNode.frame.contains(newPos) else {
            #if DEBUG
            print("Выход за пределы лабиринта")
            #endif
            return
        }
        
        // Проверка центра шарика
        if isWall(at: newPos) {
            #if DEBUG
            print("Столкновение со стеной в центре шарика")
            #endif
            return // Если центр шарика на стене - не двигаем
        }
        
        // Проверка по 12 точкам вокруг окружности игрока
        let offsets: [CGPoint] = [
            // Основные направления
            CGPoint(x: playerRadius, y: 0),                // справа
            CGPoint(x: -playerRadius, y: 0),               // слева
            CGPoint(x: 0, y: playerRadius),                // сверху
            CGPoint(x: 0, y: -playerRadius),               // снизу
            
            // Диагональные направления
            CGPoint(x: playerRadius * 0.7, y: playerRadius * 0.7),    // справа-сверху
            CGPoint(x: -playerRadius * 0.7, y: playerRadius * 0.7),   // слева-сверху
            CGPoint(x: playerRadius * 0.7, y: -playerRadius * 0.7),   // справа-снизу
            CGPoint(x: -playerRadius * 0.7, y: -playerRadius * 0.7),  // слева-снизу
            
            // Дополнительные точки для более точной проверки
            CGPoint(x: playerRadius * 0.4, y: playerRadius * 0.9),    // почти сверху
            CGPoint(x: playerRadius * 0.9, y: playerRadius * 0.4),    // почти справа
            CGPoint(x: -playerRadius * 0.4, y: -playerRadius * 0.9),  // почти снизу
            CGPoint(x: -playerRadius * 0.9, y: -playerRadius * 0.4)   // почти слева
        ]
        
        for offset in offsets {
            let checkPoint = CGPoint(x: newPos.x + offset.x, y: newPos.y + offset.y)
            if isWall(at: checkPoint) {
                #if DEBUG
                print("Столкновение со стеной в точке: \(checkPoint)")
                #endif
                return  // столкновение со стеной — не двигаем игрока
            }
        }
        
        // Если всё ок — двигаем игрока
        #if DEBUG
        print("Движение разрешено, новая позиция: \(newPos)")
        #endif
        playerNode.position = newPos
        
        // Проверка победы
        if hypot(newPos.x - exitPoint.x, newPos.y - exitPoint.y) < playerRadius * 2 {
            #if DEBUG
            print("Достигнут выход!")
            #endif
            onGameWon?()
        }
    }
    
    private func isWall(at point: CGPoint) -> Bool {
        guard let mazeCGImage = mazeCGImage else { return false }
        
        let scaleX = CGFloat(mazeCGImage.width) / mazeNode.size.width
        let scaleY = CGFloat(mazeCGImage.height) / mazeNode.size.height
        
        let imgX = Int(point.x * scaleX)
        let imgY = Int((mazeNode.size.height - point.y) * scaleY)
        
        #if DEBUG
        print("Проверка точки: игровые координаты (\(point.x), \(point.y)), пиксельные координаты (\(imgX), \(imgY))")
        #endif
        
        // Проверка границ изображения
        guard imgX >= 0, imgX < mazeCGImage.width, imgY >= 0, imgY < mazeCGImage.height else {
            return true // Если точка вне изображения - считаем это стеной
        }
        
        // Прямой доступ к данным пикселя
        guard let dataProvider = mazeCGImage.dataProvider,
              let pixelData = dataProvider.data,
              let data = CFDataGetBytePtr(pixelData) else {
            return true // Если не удалось получить данные - считаем стеной
        }
        
        // Получаем информацию о формате изображения
        let bytesPerPixel = mazeCGImage.bitsPerPixel / 8
        let bytesPerRow = mazeCGImage.bytesPerRow
        
        // Вычисляем индекс пикселя с учетом bytesPerRow
        let pixelIndex = bytesPerRow * imgY + imgX * bytesPerPixel
        
        // Проверка выхода за границы данных
        let totalBytes = CFDataGetLength(pixelData)
        guard pixelIndex >= 0, pixelIndex + 2 < totalBytes else {
            #if DEBUG
            print("Предотвращен выход за границы массива данных")
            #endif
            return true // Защита от выхода за границы массива
        }
        
        // Извлекаем компоненты цвета
        let r = CGFloat(data[pixelIndex]) / 255.0
        let g = CGFloat(data[pixelIndex + 1]) / 255.0
        let b = CGFloat(data[pixelIndex + 2]) / 255.0
        
        #if DEBUG
        print("Цвет пикселя: R=\(r), G=\(g), B=\(b)")
        #endif
        
        // Определяем стену как белый цвет (r, g, b > 0.7)
        let isWall = (r > 0.7 && g > 0.7 && b > 0.7)
        
        #if DEBUG
        print("Это \(isWall ? "стена" : "проход")")
        #endif
        
        return isWall
    }
}

// MARK: - CGImage Pixel Color Extension
extension CGImage {
    func colorAt(x: Int, y: Int) -> UIColor? {
        guard x >= 0, x < width, y >= 0, y < height else { return nil }
        
        let bytesPerRow = 4
        let dataSize = bytesPerRow * 1 // всего 1 пиксель
        let bitmapInfo = CGImageAlphaInfo.premultipliedLast.rawValue
        
        // Создаем буфер для данных пикселя
        var pixelData = [UInt8](repeating: 0, count: dataSize)
        
        // Создаем контекст размером 1x1 для извлечения цвета пикселя
        guard let context = CGContext(data: &pixelData,
                                    width: 1, height: 1,
                                    bitsPerComponent: 8,
                                    bytesPerRow: bytesPerRow,
                                    space: CGColorSpaceCreateDeviceRGB(),
                                    bitmapInfo: bitmapInfo) else {
            return nil
        }
        
        // Перемещаем контекст к нужному пикселю и рисуем изображение
        context.translateBy(x: CGFloat(-x), y: CGFloat(-y))
        context.draw(self, in: CGRect(x: 0, y: 0, width: width, height: height))
        
        // Извлекаем компоненты цвета
        let r = CGFloat(pixelData[0]) / 255.0
        let g = CGFloat(pixelData[1]) / 255.0
        let b = CGFloat(pixelData[2]) / 255.0
        let a = CGFloat(pixelData[3]) / 255.0
        
        return UIColor(red: r, green: g, blue: b, alpha: a)
    }
}

extension UIColor {
    func isWhite(threshold: CGFloat = 0.9) -> Bool {
        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        getRed(&r, green: &g, blue: &b, alpha: &a)
        return r > threshold && g > threshold && b > threshold
    }
    
    func isLightColor(threshold: CGFloat = 0.7) -> Bool {
        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        getRed(&r, green: &g, blue: &b, alpha: &a)
        // Вычисляем яркость по формуле luminance = 0.299*R + 0.587*G + 0.114*B
        let luminance = 0.299 * r + 0.587 * g + 0.114 * b
        return luminance > threshold
    }
}


/*

import SpriteKit
import UIKit

class MazeGameScene1: SKScene {
    // MARK: - Nodes
    private var mazeNode: SKSpriteNode!
    private var playerNode: SKShapeNode!
    
    // MARK: - UI
    private var timerLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
    private var upButton: SKSpriteNode!
    private var downButton: SKSpriteNode!
    private var leftButton: SKSpriteNode!
    private var rightButton: SKSpriteNode!
    private var restartButton = SKLabelNode(fontNamed: "AvenirNext-Bold")
    private var rewardButton = SKLabelNode(fontNamed: "AvenirNext-Bold")
    
    // MARK: - Game State
    private var timeRemaining: TimeInterval = 60
    private var lastUpdateTime: TimeInterval = 0
    private var startPoint = CGPoint.zero
    private var exitPoint = CGPoint.zero
    private var rewardCollected = false
    
    override func didMove(to view: SKView) {
        // Background transparent so underlying UI or background shows
        backgroundColor = .clear
        scaleMode = .resizeFill
        setupMaze()
        setupPlayer()
        setupUI()
    }
    
    // MARK: - Setup Methods
    private func setupMaze() {
        let texture = SKTexture(imageNamed: "maze")
        // Scale maze to fill ~60% width, keep aspect
        let aspect = texture.size().height / texture.size().width
        let mazeWidth = size.width * 0.6
        let mazeHeight = mazeWidth * aspect
        mazeNode = SKSpriteNode(texture: texture, size: CGSize(width: mazeWidth, height: mazeHeight))
//        mazeNode.anchorPoint = .bottomLeft
        mazeNode.position = CGPoint(x: frame.minX + 10, y: frame.midY - mazeHeight / 2)
        addChild(mazeNode)
        
        // Define start/exit relative to the original image size
        startPoint = CGPoint(x: 20, y: 20)
        exitPoint = CGPoint(x: texture.size().width - 20, y: texture.size().height - 20)
    }
    
    private func setupPlayer() {
        let radius: CGFloat = 7
        playerNode = SKShapeNode(circleOfRadius: radius)
        playerNode.fillColor = .purple
        playerNode.strokeColor = .clear
        // Convert startPoint from image coords to scaled coords
        let scaleX = mazeNode.size.width / mazeNode.texture!.size().width
        let scaleY = mazeNode.size.height / mazeNode.texture!.size().height
        let startScaled = CGPoint(x: startPoint.x * scaleX, y: startPoint.y * scaleY)
        playerNode.position = mazeNode.position + startScaled
        playerNode.zPosition = 1
        addChild(playerNode)
    }
    
    private func setupUI() {
        // Timer
        timerLabel.fontSize = 24
        timerLabel.fontColor = .white
        timerLabel.position = CGPoint(x: frame.midX, y: frame.maxY - 40)
        addChild(timerLabel)
        
        // Semi-transparent panel for controls
        let panelSize = CGSize(width: size.width * 0.35, height: size.height * 0.4)
        let panel = SKSpriteNode(color: UIColor.black.withAlphaComponent(0.5), size: panelSize)
        panel.position = CGPoint(x: frame.maxX - panelSize.width/2 - 10, y: frame.midY)
        panel.zPosition = 0
        addChild(panel)
        
        // Arrow buttons (use arrow image assets)
        let btnSize = CGSize(width: 50, height: 50)
        upButton = makeArrow(name: "up", at: CGPoint(x: panel.position.x, y: panel.position.y + 60), size: btnSize)
        downButton = makeArrow(name: "down", at: CGPoint(x: panel.position.x, y: panel.position.y - 60), size: btnSize)
        leftButton = makeArrow(name: "left", at: CGPoint(x: panel.position.x - 60, y: panel.position.y), size: btnSize)
        rightButton = makeArrow(name: "right", at: CGPoint(x: panel.position.x + 60, y: panel.position.y), size: btnSize)
        
        // Restart button
        restartButton.text = "Restart"
        restartButton.fontSize = 20
        restartButton.fontColor = .yellow
        restartButton.position = CGPoint(x: panel.position.x, y: panel.position.y - panelSize.height/2 + 30)
        restartButton.name = "restart"
        addChild(restartButton)
        
        // Reward button (hidden until exit)
        rewardButton.text = "+40 Coins"
        rewardButton.fontSize = 20
        rewardButton.fontColor = .green
        rewardButton.position = CGPoint(x: panel.position.x, y: restartButton.position.y + 40)
        rewardButton.name = "reward"
        rewardButton.isHidden = true
        addChild(rewardButton)
    }
    
    private func makeArrow(name: String, at pos: CGPoint, size: CGSize) -> SKSpriteNode {
        let node = SKSpriteNode(imageNamed: "mazeArrowControl")
        node.size = size
        node.position = pos
        node.name = name
        addChild(node)
        return node
    }
    
    // MARK: - Game Loop
    override func update(_ currentTime: TimeInterval) {
        if lastUpdateTime == 0 { lastUpdateTime = currentTime }
        let delta = currentTime - lastUpdateTime
        lastUpdateTime = currentTime
        
        if timeRemaining > 0 {
            timeRemaining -= delta
            timerLabel.text = "Time: \(Int(timeRemaining))"
            if timeRemaining <= 0 {
                timerLabel.text = "Time's Up!"
                isUserInteractionEnabled = false
            }
        }
    }
    
    // MARK: - Touch Handling
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let loc = touches.first?.location(in: self) else { return }
        nodes(at: loc).forEach { node in
            switch node.name {
            case "up":    tryMove(by: CGVector(dx: 0, dy: 20))
            case "down":  tryMove(by: CGVector(dx: 0, dy: -20))
            case "left":  tryMove(by: CGVector(dx: -20, dy: 0))
            case "right": tryMove(by: CGVector(dx: 20, dy: 0))
            case "restart": restartGame()
            case "reward": collectReward()
            default: break
            }
        }
    }
    
    // MARK: - Movement & Collision
    private func tryMove(by offset: CGVector) {
        let newPos = playerNode.position + CGPoint(x: offset.dx, y: offset.dy)
        if canMove(to: newPos) {
            playerNode.position = newPos
            if reachedExit() && !rewardCollected {
                rewardButton.isHidden = false
            }
        }
    }
    
    private func canMove(to pos: CGPoint) -> Bool {
        // Check 4 sample points around the circle's edge
        let local = convert(pos, to: mazeNode)
        let radius = playerNode.frame.width / 2
        let samples = [
            CGPoint(x: local.x + radius, y: local.y),
            CGPoint(x: local.x - radius, y: local.y),
            CGPoint(x: local.x, y: local.y + radius),
            CGPoint(x: local.x, y: local.y - radius)
        ]
        for point in samples {
            guard let color = mazeNode.texture?.pixelColor(at: CGPoint(x: point.x / mazeNode.size.width * mazeNode.texture!.size().width,
                                                                       y: point.y / mazeNode.size.height * mazeNode.texture!.size().height)),
                  color.isApproximatelyEqual(to: .white, tolerance: 0.1) else {
                return false
            }
        }
        return true
    }
    
    private func reachedExit() -> Bool {
        let texture = mazeNode.texture!
        let scaleX = mazeNode.size.width / texture.size().width
        let scaleY = mazeNode.size.height / texture.size().height
        let exitScaled = CGPoint(x: exitPoint.x * scaleX, y: exitPoint.y * scaleY)
        let exitWorld = mazeNode.position + exitScaled
        return playerNode.position.distance(to: exitWorld) < playerNode.frame.width
    }
    
    // MARK: - Game Control
    private func restartGame() {
        timeRemaining = 60
        lastUpdateTime = 0
        timerLabel.text = "Time: 60"
        rewardCollected = false
        rewardButton.isHidden = true
        // Reset player position
        let scaleX = mazeNode.size.width / mazeNode.texture!.size().width
        let scaleY = mazeNode.size.height / mazeNode.texture!.size().height
        let startScaled = CGPoint(x: startPoint.x * scaleX, y: startPoint.y * scaleY)
        playerNode.position = mazeNode.position + startScaled
        isUserInteractionEnabled = true
    }
    
    private func collectReward() {
        rewardCollected = true
        rewardButton.text = "+40 Coins!"
        // TODO: добавить логику начисления монет
    }
}

// MARK: - Helpers

extension SKTexture {
    func pixelColor(at point: CGPoint) -> UIColor? {
       let cg = cgImage()
        guard let data = cg.dataProvider?.data,
              let ptr = CFDataGetBytePtr(data) else { return nil }
        let bpp = cg.bitsPerPixel / 8
        let bpr = cg.bytesPerRow
        let x = Int(point.x), y = Int(point.y)
        guard x >= 0, y >= 0, x < cg.width, y < cg.height else { return nil }
        let offset = y * bpr + x * bpp
        let r = ptr[offset], g = ptr[offset+1], b = ptr[offset+2], a = ptr[offset+3]
        return UIColor(red: CGFloat(r)/255, green: CGFloat(g)/255, blue: CGFloat(b)/255, alpha: CGFloat(a)/255)
    }
}

extension UIColor {
    func isApproximatelyEqual(to other: UIColor, tolerance: CGFloat = 0.05) -> Bool {
        var r1: CGFloat=0, g1: CGFloat=0, b1: CGFloat=0, a1: CGFloat=0
        var r2: CGFloat=0, g2: CGFloat=0, b2: CGFloat=0, a2: CGFloat=0
        guard getRed(&r1, green:&g1, blue:&b1, alpha:&a1), other.getRed(&r2, green:&g2, blue:&b2, alpha:&a2) else { return false }
        return abs(r1-r2)<tolerance && abs(g1-g2)<tolerance && abs(b1-b2)<tolerance
    }
}

extension CGPoint {
    static func + (l: CGPoint, r: CGPoint) -> CGPoint { CGPoint(x: l.x + r.x, y: l.y + r.y) }
    func distance(to p: CGPoint) -> CGFloat { hypot(x-p.x, y-p.y) }
}


*/
