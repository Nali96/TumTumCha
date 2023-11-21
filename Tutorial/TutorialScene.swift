//
//  TutorialScene.swift
//  TumTumCha
//
//  Created by Eduardo Curupana on 03/06/2019.
//  Copyright © 2019 Apple Academy. All rights reserved.
//

import UIKit
import SpriteKit
import AVFoundation

class TutorialScene: SKScene {
    
    // MARK: - Eduardo's properties
    
    private var beatCounterLabel: SKLabelNode!
    private var accuracyLabel: SKLabelNode!
    private var line: SKShapeNode!
    private var pathToDraw: CGMutablePath!
    
    private var emitterNode: SKEmitterNode!
    
    var tutorials: [Tutorial] = []
    
    var logics: GameLogics!
    
    var wheelCounter = 0
    var tutorialCounter = 0
    var totalAccuracy = 0
    var beatsLeft = 0
    
    var currentLevel: Level!
    var tutorial: Tutorial!
    var currentWorldID = 1
    
    var loopCount = 0
    
    // MARK: - my properties
    
    var centerNode: SKShapeNode!
    var beatNode: SKShapeNode!
    var pathNodes: [SKShapeNode] = []
    var allBeats: [SKShapeNode] = []
    
    var circleRepeatAction: SKAction!
    var testNode: SKShapeNode!
    
    var isStarted = false
    var prevTime: TimeInterval = 0
    
    var isFirstLoop = true
    
    var stepCounter = 0
    
    var beatsCounter = 0
    private var players: [AVAudioPlayer?] = []
    
    let helper = GameHelper()
    let config = GameConfiguration()
    let decoder = LevelsProvider()
    let settings = UserDefaultSettings()
    
    var playerInteraction: PlayerInteraction!
//    var tutorialView: TutorialViewController!
    var levelVC: LevelViewController!
    
    weak var gameDelegate: GameSceneDelegate?
    
    var pointersNode: SKSpriteNode!
    
    // MARK: - Life cycle
    
    deinit {
        stopPlayers()
        print("GameScene deinit")
    }
    
    override func didMove(to view: SKView) {
        startLevel(view: view)
    }
    
    func startLevel(view: SKView) {
        
        tutorial = currentLevel.tutorial
        
        self.emitterNode = SKEmitterNode(fileNamed: "Spark")
        
        logics = GameLogics()
        beatsLeft = currentLevel.numberOfAllBeats(for: wheelCounter)
        
        createNodes()
        let dataSettings = settings.retrieve()
        dataSettings.showCounter ? showTopBeatsCounterNodes() : hideTopBeatsCounterNodes()
        
        setupAudioPlayers()
        
        beatNode = SKShapeNode(circleOfRadius: config.beatRadius)
        beatNode.fillColor = config.movingBeatColor
        beatNode.strokeColor = config.movingBeatColor
        beatNode.position = CGPoint(x: 0, y: config.pathRadius)
        beatNode.zPosition = 20
        addChild(beatNode)
        
        let path = CGMutablePath()
        path.addArc(center: .zero, radius: config.pathRadius, startAngle: 0.5 * CGFloat.pi, endAngle: 1.5 * CGFloat.pi, clockwise: true)
        path.addArc(center: .zero, radius: config.pathRadius, startAngle: 1.5 * CGFloat.pi, endAngle: 0.5 * CGFloat.pi, clockwise: true)
        
        for _ in 0..<currentLevel.wheels.count {
            let pathNode = SKShapeNode(path: path)
            pathNode.strokeColor = config.wheelColor
            pathNode.lineWidth = config.wheelWidth
            pathNode.zPosition = 10
            pathNodes.append(pathNode)
            addChild(pathNode)
        }
        
        // MARK: - to evaluate precision
        
        let zeroPositionBeat = SKShapeNode(rectOf: CGSize(width: 1, height: 20))
        zeroPositionBeat.strokeColor = .orange
        zeroPositionBeat.position = beatNode.position
        //        pathNodes.last?.addChild(zeroPositionBeat)
        
        // MARK: - Gestures
        
        playerInteraction = PlayerInteraction(view: view, delegate: self, settings: dataSettings)
        playerInteraction.isEnabled = false
        
        // MARK: - Start countdown
        
//        countdown()
        startPlaying()
        
        createPointer()
    }
    
    var positionCount = 0
    
    override func update(_ currentTime: TimeInterval) {
        
        if isStarted, wheelCounter < currentLevel.wheels.count {
            updateMovingBeatPosition()
            
            var currentTime: TimeInterval = 0
            
            if let player = players.first {
                currentTime = player?.currentTime ?? 0
            }
            
            if currentTime < prevTime {
                print("FINISH CIRCLE!!!")
                
                loopCount += 1
                print("Loop Counter: \(loopCount)")
                circleFinished()
            }
            
            prevTime = currentTime
        }
        
        if wheelCounter < currentLevel.wheels.count {
            let position = logics.positionOnWhellOnSixteen(logics.timeToPosition(prevTime, duration: players[0]!.duration))
            
            guard positionCount != position else {
                return
            }
            
            positionCount = position
            print("Position Count: \(positionCount)")
            
            for beat in currentLevel.allBeats(for: wheelCounter) {
                if logics.positionOnWhellOnSixteen(beat.position) == position {
                    pulseBeat()
                }
            }
            
            guard
                stepCounter < tutorial.steps.count,
                positionCount == tutorial.steps[stepCounter].pausePosition,
                loopCount != 0,
                tutorial?.steps[stepCounter].wheelCount == wheelCounter else {
                return
            }
            playerInteraction.isEnabled = true
            accuracyLabel.fontSize = 13
            accuracyLabel.text = tutorial?.steps[stepCounter].message
            
            pausePlayers()
            showPointer()
        }
    }
    
    func pulseBeat() {
        
        let shadowBeat = beatNode.copy() as! SKShapeNode
        shadowBeat.fillColor = .darkGray
        shadowBeat.strokeColor = .darkGray
        shadowBeat.setScale(1.3)
        shadowBeat.position = beatNode.position
        shadowBeat.alpha = 0.0
        addChild(shadowBeat)
        shadowBeat.run(SKAction.fadeAlpha(to: 1, duration: 0.5)) {
            shadowBeat.run(SKAction.fadeAlpha(to: 0, duration: 0.5))
        }
    }
    
    func createPointer() {
        pointersNode = SKSpriteNode(color: .clear, size: CGSize(width: 200, height: 100))
        pointersNode.position = CGPoint(x: 0, y: -self.frame.height/3)
        pointersNode.run(SKAction.repeatForever(SKAction.sequence([SKAction.group([SKAction.scale(by: 0.8, duration: 0.5), SKAction.fadeOut(withDuration: 0.5)]), SKAction.group([SKAction.scale(to: 1, duration: 0.5), SKAction.fadeIn(withDuration: 0.5)])])))
    }
    
    func showPointer() {
        
        pointersNode.removeAllChildren()
        
        if let tutorial = tutorial {
            switch tutorial.steps[stepCounter].beatKind {
            case .main:
                let leftPointer = OnboardingElement(of: .leftPointer)
                let rightPointer = OnboardingElement(of: .rightPointer)
                pointersNode.addChild(leftPointer)
                pointersNode.addChild(rightPointer)
            case .secondary:
                let rightPointer = OnboardingElement(of: .rightPointer)
                pointersNode.addChild(rightPointer)
            case .off:
                let leftPointer = OnboardingElement(of: .leftPointer)
                pointersNode.addChild(leftPointer)
            }
            addChild(pointersNode)
        }
    }
    
    func removePointer() {
        pointersNode.removeFromParent()
    }
    
    func startPlayers() {
        for i in 0...wheelCounter {
            players[i]?.volume = 1
        }
    }
    
    func playPlayers() {
        for player in players {
            player?.play()
        }
    }
    
    func pausePlayers() {
        for player in players {
            player?.pause()
        }
    }
    
    func isPlaying() -> Bool {
        if players.count > 0 {
            return players[0]?.isPlaying ?? false
        } else {
            return false
        }
    }
    
    func stopPlayers() {
        for player in players {
            player?.stop()
        }
        players = []
    }
    
    func createAndCheckTouch(_ type: BeatType, touch: Touch) {
        guard
            wheelCounter < currentLevel.wheels.count,
            beatsCounter < currentLevel.numberOfAllBeats(for: wheelCounter) else {
                return
        }
        
        guard players.count > 0, let player = players[0] else {
            return
        }
        
        let beats = currentLevel.allBeats(for: wheelCounter)
        
        beatsLeft -= 1
        beatCounterLabel.text = "\(beatsLeft)"
        
        if player.isPlaying {
            accuracyLabel.fontSize = 35
            let touchOutput = logics.checkTouchPosition(touch: touch, beats: beats)
            switch touchOutput {
            case .right(let accuracy):
                print("================ Accuracy of Touch: \(accuracy) ================")
                accuracyLabel.text = "PERFECT!"
                addNewBeat(touch: touch)
                totalAccuracy = totalAccuracy + accuracy
            case .outRange, .doubleFail:
                accuracyLabel.text = "OUT!"
            case .wrongTouch:
                accuracyLabel.text = "WRONG!"
            }
        }
    }
}
    
private extension TutorialScene {
        
    func createNodes() {
        beatCounterLabel = SKLabelNode(text: "\(beatsLeft)")
        beatCounterLabel.fontName = FontName.caviarDreams
        beatCounterLabel.fontSize = 25
        let beatCounterLabelPosition = CGPoint(x: 0, y: 200)
        beatCounterLabel.position = beatCounterLabelPosition
        beatCounterLabel.numberOfLines = 3
        beatCounterLabel.lineBreakMode = .byWordWrapping
        beatCounterLabel.horizontalAlignmentMode = .center
        beatCounterLabel.verticalAlignmentMode = .center
        
        accuracyLabel = SKLabelNode(text: "Listen Carefully!")
        accuracyLabel.fontName = FontName.caviarDreams
        accuracyLabel.fontSize = 15
        accuracyLabel.numberOfLines = 2
        accuracyLabel.lineBreakMode = .byWordWrapping
        accuracyLabel.position = CGPoint(x: 0, y: 0)
        accuracyLabel.verticalAlignmentMode = .center
        accuracyLabel.horizontalAlignmentMode = .center
        
        line = SKShapeNode()
        pathToDraw = CGMutablePath()
        pathToDraw.move(to: CGPoint(x: beatCounterLabelPosition.x - 80, y: beatCounterLabelPosition.y - 20))
        pathToDraw.addLine(to: CGPoint(x: beatCounterLabelPosition.x + 80, y: beatCounterLabelPosition.y - 20 ))
        line.path = pathToDraw
        line.strokeColor = SKColor.lightGray
        
        addChild(line)
        addChild(beatCounterLabel)
        addChild(accuracyLabel)
    }
    
    func showTopBeatsCounterNodes() {
        beatCounterLabel.isHidden = false
        line.isHidden = false
    }
    
    func hideTopBeatsCounterNodes() {
        beatCounterLabel.isHidden = true
        line.isHidden = true
    }
        
        func setupAudioPlayers() {
            
            do {
                try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
                try AVAudioSession.sharedInstance().setActive(true)
            } catch let error {
                print("AVAudioSession set category error: \(error.localizedDescription)")
            }
            
            for i in 0..<currentLevel.wheels.count {
                
                guard let url = Bundle.main.url(forResource: currentLevel.wheels[i].audioName, withExtension: nil) else {
                    players.append(nil)
                    return
                }
                
                let player = try? AVAudioPlayer(contentsOf: url, fileTypeHint: AVFileType.mp3.rawValue)
                
                player?.delegate = self
                player?.numberOfLoops = -1
                player?.volume = 0
                player?.prepareToPlay()
                
                players.append(player)
            }
        }
        
        func startPlaying() {
            
            unmutePlayerForCurrentWheel()
            
            for player in players {
                player?.play()
            }
            
            isStarted = true
            
            gameDelegate?.didStartPlaying()
        }
        
        func unmutePlayerForCurrentWheel() {
            if wheelCounter < players.count {
                players[wheelCounter]?.volume = 1
            }
        }
        
        func updateMovingBeatPosition() {
            
            guard players.count > 0, let player = players[0] else {
                return
            }
            
            let currentAngle = 360 * CGFloat(player.currentTime / player.duration)
            let translatedAngle = helper.translateAngleToHalfCircle(currentAngle)
            
            let x = config.pathRadius * cos(translatedAngle * helper.degreesToRadians)
            let y = config.pathRadius * sin(translatedAngle * helper.degreesToRadians)
            
            let updatedPosition = CGPoint(x: x, y: y)
            beatNode.position = updatedPosition
        }
        
        func animateAllBeats() {
            
            if testNode != nil {
                
                let testAngle = atan2(testNode.position.y, testNode.position.x)
                let testAngleInDegrees = testAngle * helper.radiansToDegrees
                let testAdjustedAngle = helper.adjustAngleInDegrees(testAngleInDegrees)
                
                let testSector = helper.getSector(for: testAdjustedAngle, config: config)
                
                for beat in allBeats {
                    let angle = atan2(beat.position.y, beat.position.x)
                    let angleInDegrees = angle * helper.radiansToDegrees
                    let adjustedAngle = helper.adjustAngleInDegrees(angleInDegrees)
                    
                    let sector = helper.getSector(for: adjustedAngle, config: config)
                    if sector == testSector {
                        let scaleAction = SKAction.scale(to: 1.5, duration: 0.2)
                        scaleAction.timingMode = .easeIn
                        let reversedAction = SKAction.scale(to: 1, duration: 0.2)
                        reversedAction.timingMode = .easeOut
                        let sequence = SKAction.sequence([scaleAction, reversedAction])
                        beat.run(sequence)
                    }
                }
            }
        }
        
        func addEtalonBeatInWheelEnd() {
            
            let etalonBeat = SKShapeNode(rectOf: CGSize(width: 1, height: 20))
            etalonBeat.strokeColor = .blue
            etalonBeat.position = beatNode.position
            pathNodes.last?.addChild(etalonBeat)
        }
        
        func addNewBeatOnWheel() {
            
            if let newBeat = beatNode.copy() as? SKShapeNode {
                newBeat.removeAllActions()
                allBeats.append(newBeat)
                pathNodes[wheelCounter].addChild(newBeat)
                beatsCounter += 1
                
                newBeat.fillColor = .yellow
                let angle = atan2(newBeat.position.y, newBeat.position.x)
                let angleInDegrees = angle * helper.radiansToDegrees
                let adjustedAngle = helper.adjustAngleInDegrees(angleInDegrees)
                
                let sector = helper.getSector(for: adjustedAngle, config: config)
                let newAngle = helper.translateAngleToHalfCircle(sector)
                let x = config.pathRadius * cos(newAngle * helper.degreesToRadians)
                let y = config.pathRadius * sin(newAngle * helper.degreesToRadians)
                let newPosition = CGPoint(x: x, y: y)
                
                let moveAction = SKAction.move(to: newPosition, duration: 0.2)
                moveAction.timingMode = .easeIn
                
                newBeat.run(moveAction) { [weak self] in
                    self?.copyBeatOnHigherWheels()
                }
            }
        }
        
    func addNewBeat(touch: Touch) {
            
            guard
                wheelCounter < currentLevel.wheels.count,
                beatsCounter < currentLevel.numberOfAllBeats(for: wheelCounter) else {
                    return
            }
            
            let newBeat = SKShapeNode(circleOfRadius: config.beatRadius)
            newBeat.position = beatNode.position
            newBeat.zPosition = 30
            
            var beatColor: UIColor = UIColor(named: "Yellow") ?? .yellow // configure from level color
            
            let angle = atan2(newBeat.position.y, newBeat.position.x)
            let angleInDegrees = angle * helper.radiansToDegrees
            let adjustedAngle = helper.adjustAngleInDegrees(angleInDegrees)
            
            let sector = helper.getSector(for: adjustedAngle, config: config)
            
            var isCorrect = false
            let currentPosition = sector / 360
            print("currentPosition: \(currentPosition)")
            
            for beat in currentLevel.allBeats(for: wheelCounter) {
                print("beat position: \(beat.position)")
                if beat.position == Float(currentPosition) && beat.kind == touch.type {
                    isCorrect = true
                }
            }
            
            if !isCorrect {
                beatColor = config.wheelColor
            }
            
            switch touch.type {
            case .main:
                newBeat.fillColor = beatColor
                newBeat.strokeColor = beatColor
                
            case .secondary:
                newBeat.strokeColor = beatColor
                let innerCircle = SKShapeNode(circleOfRadius: config.beatRadius / 2)
                innerCircle.strokeColor = beatColor
                newBeat.addChild(innerCircle)
                let innerDot = SKShapeNode(circleOfRadius: 1)
                innerDot.fillColor = beatColor
                innerDot.strokeColor = beatColor
                newBeat.addChild(innerDot)
                
            case .off:
                newBeat.strokeColor = beatColor
            }
            
            allBeats.append(newBeat)
            pathNodes[wheelCounter].addChild(newBeat)
            beatsCounter += 1
            
            let newAngle = helper.translateAngleToHalfCircle(sector)
            let x = config.pathRadius * cos(newAngle * helper.degreesToRadians)
            let y = config.pathRadius * sin(newAngle * helper.degreesToRadians)
            let newPosition = CGPoint(x: x, y: y)
            
            let moveAction = SKAction.move(to: newPosition, duration: 0.2)
            moveAction.timingMode = .easeIn
            
            newBeat.run(moveAction)
            //        newBeat.run(moveAction) { [weak self] in
            //            self?.copyBeatOnHigherWheels()
            //        }
        }
        
        func addNodeToTestAnimations() {
            
            testNode = SKShapeNode(circleOfRadius: config.beatRadius)
            testNode.strokeColor = .green
            testNode.position = CGPoint(x: 0, y: config.pathRadius)
            
            addChild(testNode)
            testNode.run(circleRepeatAction)
        }
        
        func copyBeatOnHigherWheels() {
            
            if wheelCounter < currentLevel.wheels.count {
                for i in wheelCounter + 1 ..< currentLevel.wheels.count {
                    if let beat = allBeats.last?.copy() as? SKShapeNode {
                        allBeats.append(beat)
                        pathNodes[i].addChild(beat)
                    }
                }
            }
        }
        
        func circleFinished() {
            
            guard
                wheelCounter < currentLevel.wheels.count,
                beatsCounter >= currentLevel.numberOfAllBeats(for: wheelCounter) else {
                    return
            }
            
            let numberOfBeats = currentLevel.numberOfAllBeats(for: wheelCounter)
            let accuracy = logics.calculateAverage(totalAccuracy: totalAccuracy, numberOfBeats: numberOfBeats)
            
            currentLevel.wheels[wheelCounter].accuracy = accuracy
            totalAccuracy = 0
            wheelCounter += 1
            
            if wheelCounter < currentLevel.wheels.count {
                beatsLeft = currentLevel.numberOfAllBeats(for: wheelCounter)
                beatCounterLabel.text = "\(beatsLeft)"
            } else {
                accuracyLabel.text = ""
            }
            
            beatsCounter = 0
            
            guard wheelCounter < currentLevel.wheels.count else {
                
                beatNode.removeFromParent()
                pausePlayers()
                print("finish tutorial")
                
                // MARK: - calculate general accuracy (Eduardo) and save results (Marco)
                let finalAccuracy = logics.calculateWheelsAverage(wheels: currentLevel.wheels)
                let highscore = logics.getHighscore(levelId: currentLevel.id, worldId: currentWorldID)
                
                
                if finalAccuracy > highscore {
                    logics.saveLevelAccuracy(accuracy: finalAccuracy, worldId: currentWorldID, levelId: currentLevel.id)
                }
                
                levelVC.showPopUp(messages: ["Tutorial Completed", "You did great!"], buttons: [.restart, .levels, .next])
                
                return
            }
            
            for i in 0..<wheelCounter {
                let size = pathNodes[i].frame.size
                let factor = (size.width - 6 * config.beatRadius) / size.width
                let scaleAction = SKAction.scale(by: factor, duration: 0.4)
                scaleAction.timingMode = .easeOut
                pathNodes[i].run(scaleAction)
            }
            
            unmutePlayerForCurrentWheel()
        }
    }
    
    // MARK: - PlayerInteractionDelegate
    
extension TutorialScene: PlayerInteractionDelegate {
        
    func didPutBeatOfType(_ type: BeatType) {
        
        let step = tutorial.steps[stepCounter]
        
        if type == step.beatKind {
            let position = logics.positionOnWhellOnOne(Float(step.pausePosition))
            let touch = Touch(position: position, type: type)
            removePointer()
            playPlayers()
            createAndCheckTouch(type, touch: touch)
            playerInteraction.isEnabled = false
            stepCounter += 1
        }
    }
}
    
    // MARK: - AVAudioPlayerDelegate
    
extension TutorialScene: AVAudioPlayerDelegate {
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        print("audioPlayerDidFinishPlaying successfully: \(flag), current: \(player.currentTime)")
    }
}

extension TutorialScene {
    
    func touchDown(atPoint pos : CGPoint) {
        if let n = self.emitterNode?.copy() as! SKEmitterNode? {
            n.position = pos
            n.particleColor = SKColor.yellow
            self.addChild(n)
        }
    }
    
    func touchMoved(toPoint pos : CGPoint) {
        if let n = self.emitterNode?.copy() as! SKEmitterNode? {
            n.position = pos
            n.particleColor = SKColor.yellow
            self.addChild(n)
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchDown(atPoint: t.location(in: self)) }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchMoved(toPoint: t.location(in: self)) }
    }
}
