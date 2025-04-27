//
//  MazeGame.swift
//  Lucky Eagle Game
//
//  Created by Mac on 26.04.2025.
//

import Foundation
import SpriteKit

class MazeGameScene: SKScene {
        private var player: SKShapeNode!
        private var maze: SKSpriteNode!
        private var exitPoint: CGPoint = CGPoint.zero
        private var gameTimer: Timer?
        private var timeLeft: Int = 60
        var onTimeUpdate: ((Int) -> Void)?
        var onGameWon: (() -> Void)?
        
        override func didMove(to view: SKView) {
            backgroundColor = .clear

            // Добавляем лабиринт (ваше изображение лабиринта)
            maze = SKSpriteNode(imageNamed: "maze") // замените на имя вашей картинки лабиринта
            maze.position = CGPoint(x: size.width/2, y: size.height/2)
            maze.size = size
            maze.zPosition = 0
            addChild(maze)
            
            // Добавляем игрок - фиолетовый круг
            let radius: CGFloat = 15
            player = SKShapeNode(circleOfRadius: radius)
            player.fillColor = .purple
            player.strokeColor = .clear
            player.position = CGPoint(x: 50, y: 50) // стартовая точка (установите по вашему лабиринту)
            player.zPosition = 1
            addChild(player)
            
            // Устанавливаем точку выхода (примерно справа вверху)
            exitPoint = CGPoint(x: size.width - 50, y: size.height - 50)
            
            startTimer()
        }
        
        func startTimer() {
            timeLeft = 60
            onTimeUpdate?(timeLeft)
            gameTimer?.invalidate()
            gameTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
                guard let self = self else { return }
                self.timeLeft -= 1
                self.onTimeUpdate?(self.timeLeft)
                if self.timeLeft <= 0 {
                    self.gameTimer?.invalidate()
                    // Время вышло - можно добавить логику проигрыша
                }
            }
        }
        
        func resetGame() {
            player.position = CGPoint(x: 50, y: 50)
            startTimer()
        }
        
        // Движение игрока с проверкой выхода за границы сцены и простая проверка выхода из лабиринта
        func movePlayer(direction: Direction) {
            let moveAmount: CGFloat = 30
            var newPosition = player.position
            
            switch direction {
            case .up:
                newPosition.y += moveAmount
            case .down:
                newPosition.y -= moveAmount
            case .left:
                newPosition.x -= moveAmount
            case .right:
                newPosition.x += moveAmount
            }
            
            // Ограничение по границам сцены
            if frame.contains(newPosition) {
                // Можно добавить здесь проверку коллизий с лабиринтом (например, по цвету пикселя лабиринта)
                player.position = newPosition
                
                // Проверка достижения выхода (допустим, радиус 30)
                if player.position.distance(to: exitPoint) < 30 {
                    gameTimer?.invalidate()
                    onGameWon?()
                }
            }
        }
        
        enum Direction {
            case up, down, left, right
        }
    }

    // Вспомогательное расширение для вычисления расстояния между точками
    extension CGPoint {
        func distance(to point: CGPoint) -> CGFloat {
            return hypot(self.x - point.x, self.y - point.y)
        }
    }
