//
//  MazeGameScene.swift
//  Lucky Eagle Game
//
//  Created by Mac on 28.04.2025.
//

import Foundation
import SpriteKit
import UIKit

class MazeGameScene3: SKScene {

    private var mazeNode: SKSpriteNode!
    private var playerNode: SKShapeNode!
    private var timerLabel: SKLabelNode!
    
    private var buttons: [SKSpriteNode] = []
    private var directions = ["up", "down", "left", "right"]
    private var moves = [CGPoint(x:0,y:20), CGPoint(x:0,y:-20), CGPoint(x:-20,y:0), CGPoint(x:20,y:0)]
    
    private var lastUpdateTime: TimeInterval = 0
    private var remainingTime: TimeInterval = 60
    
    override func didMove(to view: SKView) {
        backgroundColor = .black
        setupMaze()
        setupPlayer()
        setupButtons()
        setupTimerLabel()
    }
    
    private func setupMaze() {
        let texture = SKTexture(imageNamed: "maze")
        mazeNode = SKSpriteNode(texture: texture)
        mazeNode.size = CGSize(width: frame.width * 0.6, height: frame.width * 0.6)
        mazeNode.position = CGPoint(x: frame.minX + mazeNode.size.width/2 + 20, y: frame.midY)
        mazeNode.name = "maze"
        addChild(mazeNode)
    }
    
    private func setupPlayer() {
        playerNode = SKShapeNode(circleOfRadius: 10)
        playerNode.fillColor = .purple
        playerNode.position = CGPoint(x: mazeNode.frame.minX + 15, y: mazeNode.frame.minY + 15)
        playerNode.zPosition = 1
        addChild(playerNode)
    }
    
    private func setupButtons() {
        let buttonSize = CGSize(width: 50, height: 50)
        let positions = [
            CGPoint(x: frame.maxX - 80, y: frame.midY + 60),
            CGPoint(x: frame.maxX - 80, y: frame.midY - 60),
            CGPoint(x: frame.maxX - 130, y: frame.midY),
            CGPoint(x: frame.maxX - 30, y: frame.midY)
        ]
        
        for i in 0..<4 {
            let button = SKSpriteNode(color: .gray, size: buttonSize)
            button.position = positions[i]
            button.name = directions[i]
            addChild(button)
            buttons.append(button)
        }
        
        let restartButton = SKLabelNode(text: "Restart")
        restartButton.name = "restart"
        restartButton.fontColor = .yellow
        restartButton.position = CGPoint(x: frame.maxX - 80, y: frame.minY + 50)
        addChild(restartButton)
    }
    
    private func setupTimerLabel() {
        timerLabel = SKLabelNode(text: "Time: 60")
        timerLabel.fontColor = .white
        timerLabel.position = CGPoint(x: frame.midX, y: frame.maxY - 50)
        addChild(timerLabel)
    }
    
    override func update(_ currentTime: TimeInterval) {
        if lastUpdateTime == 0 { lastUpdateTime = currentTime }
        
        let dt = currentTime - lastUpdateTime
        lastUpdateTime = currentTime
        
        remainingTime -= dt
        timerLabel.text = "Time: \(Int(remainingTime))"
        
        if remainingTime <= 0 {
            timerLabel.text = "Time's up!"
            isUserInteractionEnabled = false
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let location = touches.first?.location(in: self) else { return }
        guard let nodeName = nodes(at: location).first?.name else { return }

        if nodeName == "restart" {
            restartGame()
        } else if directions.contains(nodeName), let idx = directions.firstIndex(of: nodeName) {
            movePlayer(by: moves[idx])
        }
    }
    
    private func movePlayer(by offset: CGPoint) {
        let newPosition = playerNode.position + offset
        if canMove(to: newPosition) {
            playerNode.position = newPosition
        }
    }
    
    private func canMove(to position: CGPoint) -> Bool {
        let localPoint = convert(position, to: mazeNode)
        let texture = mazeNode.texture!
        
        let x = Int((localPoint.x + mazeNode.size.width / 2) / mazeNode.size.width * texture.size().width)
        let y = Int((localPoint.y + mazeNode.size.height / 2) / mazeNode.size.height * texture.size().height)
        
        guard let pixelColor = texture.pixelColor(at: CGPoint(x: x, y: y)) else { return false }
        
        // Теперь проверяем наоборот: игрок может идти по красно-коричневому (пути), а белые пиксели — это стены.
        return !pixelColor.isApproximatelyEqual(to: .white)
    }

    private func restartGame() {
        playerNode.position = CGPoint(x: mazeNode.frame.minX + 15, y: mazeNode.frame.minY + 15)
        remainingTime = 60
        timerLabel.text = "Time: 60"
        isUserInteractionEnabled = true
    }
}

extension SKTexture {
    func pixelColor(at point: CGPoint) -> UIColor? {
        let cgImage = cgImage()
        guard let data = cgImage.dataProvider?.data else { return nil }
        let ptr = CFDataGetBytePtr(data)
        let bytesPerPixel = 4
        let bytesPerRow = cgImage.width * bytesPerPixel
        let offset = Int(point.y) * bytesPerRow + Int(point.x) * bytesPerPixel
        if offset < 0 || offset + 3 >= CFDataGetLength(data) { return nil }
        return UIColor(red: CGFloat(ptr![offset])/255.0,
                       green: CGFloat(ptr![offset+1])/255.0,
                       blue: CGFloat(ptr![offset+2])/255.0,
                       alpha: CGFloat(ptr![offset+3])/255.0)
    }
}

extension UIColor {
    func isApproximatelyEqual(to other: UIColor, tolerance: CGFloat = 0.2) -> Bool {
        var r1:CGFloat=0, g1:CGFloat=0, b1:CGFloat=0, a1:CGFloat=0
        var r2:CGFloat=0, g2:CGFloat=0, b2:CGFloat=0, a2:CGFloat=0
        getRed(&r1, green:&g1, blue:&b1, alpha:&a1)
        other.getRed(&r2, green:&g2, blue:&b2, alpha:&a2)
        return abs(r1-r2)<tolerance && abs(g1-g2)<tolerance && abs(b1-b2)<tolerance && abs(a1-a2)<tolerance
    }
}

fileprivate func +(left: CGPoint, right: CGPoint) -> CGPoint {
    CGPoint(x: left.x + right.x, y: left.y + right.y)
}
