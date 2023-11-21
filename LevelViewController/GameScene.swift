//
//  GameScene.swift
//  Wheel Logics
//
//  Created by Eduardo Curupana on 14/05/2019.
//  Copyright © 2019 Eduardo Curupana. All rights reserved.
//

import SpriteKit
import AVFoundation

protocol GameSceneDelegate: AnyObject {
    func didStartPlaying()
}

class GameScene: SKScene {
    
    // MARK: - Eduardo's properties
    
    private var beatCounterLabel: SKLabelNode!
    private var accuracyLabel: SKLabelNode!
    private var line: SKShapeNode!
    private var pathToDraw: CGMutablePath!
    private var emitterNode: SKEmitterNode!
    var verticalLine: TouchDivisor!
    var horizontalLine: TouchDivisor!
    
    var logics: GameLogics!
    
    var wheelCounter = 0
    var levelCounter = 0
    var totalAccuracy = 0
    var beatsLeft = 0
    
    var currentLevel: Level!
    var currentWorldID = 1
    
    // MARK: - my properties
    
    var centerNode: SKShapeNode!
    var beatNode: SKShapeNode!
    var pathNodes: [SKShapeNode] = []
    var allBeats: [SKShapeNode] = []
    var correctBeats: [SKShapeNode] = []
    
    var circleRepeatAction: SKAction!
    var testNode: SKShapeNode!
    
    var isStarted = false
    var prevTime: TimeInterval = 0
    
    var sectorsCounter = -1
    var prevSector: CGFloat = -1
    var playWheelState: PlayWheelState = .initial
    
    var beatsCounter = 0
    private var players: [AVAudioPlayer?] = []
    private var usedSectorsForCurrentWheel: [CGFloat] = []
    
    let helper = GameHelper()
    let config = GameConfiguration()
    let settings = UserDefaultSettings()
    
    var playerInteraction: PlayerInteraction!
    var levelVC: LevelViewController!
    
    weak var gameDelegate: GameSceneDelegate?
    
    // MARK: - Life cycle
    
    deinit {
        stopPlayers()
        print("GameScene deinit")
    }
    
    override func didMove(to view: SKView) {
        startLevel(view: view)
        
    }
    
    func startLevel(view: SKView) {
        
        self.emitterNode = SKEmitterNode(fileNamed: "Spark")
        
        logics = GameLogics()
        beatsLeft = currentLevel.numberOfAllBeats(for: wheelCounter)
        
        createNodes()
        let dataSettings = settings.retrieve()
        dataSettings.showCounter ? showTopBeatsCounterNodes() : hideTopBeatsCounterNodes()
        
        dataSettings.gesture == .singleTap ? showDivisorLines() : hideDivisorLines()
        
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
        
        let followAction = SKAction.follow(path, asOffset: false, orientToPath: false, duration: players[0]!.duration)
        circleRepeatAction = SKAction.repeatForever(followAction)
        
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
        
        countdown()
    }
    
    override func update(_ currentTime: TimeInterval) {
        
        // MARK: - my code
        
        guard isStarted, wheelCounter < currentLevel.wheels.count else {
            animateAllBeats()
            return
        }
        
        updateMovingBeatPosition()
        
        guard players.count > 0, let player = players[0] else {
            return
        }
        
        let playerCurrentTime = player.currentTime
        
        if case .started(let startedPosition) = playWheelState {
            let currentAngle = CGFloat(playerCurrentTime / player.duration * 360)
            let sector = helper.getSector(for: currentAngle, config: config)
            
            if sector != prevSector {
                prevSector = sector
                if sectorsCounter > 0 {
                    sectorsCounter -= 1
                    print("sectorsCounter: \(sectorsCounter)")
                }
            }
            
            if sectorsCounter == 0 {
                if prevTime < playerCurrentTime, (prevTime...playerCurrentTime).contains(Double(startedPosition) * player.duration) {
                    playerWheelFinished()
                } else if startedPosition == 0 && playerCurrentTime < prevTime {
                    playerWheelFinished()
                }
            }
        }
        
        if playerCurrentTime < prevTime {
            print("CIRCLE STARTS FROM THE BEGINNING!!!")
            if playWheelState == .finished {
                circleFinished()
            }
        }
        
        prevTime = playerCurrentTime
    }
    
    func countdown() {
        
        var countdown = 1
        
        let wait = SKAction.wait(forDuration: 1)
        let action = SKAction.run { [weak self] in
            if countdown == 1 {
                self?.accuracyLabel.fontSize = 70
                self?.accuracyLabel.text = "GO!"
            } else if countdown == 0 {
                self?.accuracyLabel.fontSize = 30
                self?.accuracyLabel.text = ""
                self?.accuracyLabel.isHidden = false
                self?.startPlaying()
            }
            countdown = countdown - 1
        }
        
        run(SKAction.repeat(SKAction.sequence([wait, action]), count: 2))
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
    
    func stopPlayers() {
        for player in players {
            player?.stop()
        }
        players = []
    }
}

// MARK: - Private methods

private extension GameScene {
    
    func createNodes() {
        
        beatCounterLabel = SKLabelNode(text: "\(beatsLeft)")
        beatCounterLabel.fontName = FontName.caviarDreams
        beatCounterLabel.fontSize = 25
        let beatCounterLabelPosition = CGPoint(x: 0, y: 260)
        beatCounterLabel.position = beatCounterLabelPosition
        beatCounterLabel.numberOfLines = 3
        beatCounterLabel.lineBreakMode = .byWordWrapping
        beatCounterLabel.horizontalAlignmentMode = .center
        beatCounterLabel.verticalAlignmentMode = .center
        let background = SKSpriteNode(color: .black, size: CGSize(width: CGFloat(beatCounterLabel.frame.size.width), height:CGFloat(beatCounterLabel.frame.size.height)))
        beatCounterLabel.addChild(background)
        
        accuracyLabel = SKLabelNode(text: "Get Ready!")
        accuracyLabel.fontName = FontName.caviarDreams
        accuracyLabel.fontSize = 30
        accuracyLabel.numberOfLines = 2
        accuracyLabel.lineBreakMode = .byWordWrapping
        accuracyLabel.position = CGPoint(x: 0, y: 0)
        accuracyLabel.verticalAlignmentMode = .center
        accuracyLabel.horizontalAlignmentMode = .center
        
        line = SKShapeNode()
        pathToDraw = CGMutablePath()
        pathToDraw.move(to: CGPoint(x: beatCounterLabelPosition.x - 80, y: beatCounterLabelPosition.y - 20))
        pathToDraw.addLine(to: CGPoint(x: beatCounterLabelPosition.x + 80, y: beatCounterLabelPosition.y - 20))
        line.path = pathToDraw
        line.strokeColor = #colorLiteral(red: 0.4039215686, green: 0.4039215686, blue: 0.4039215686, alpha: 1)
        
        verticalLine = TouchDivisor(of: .vertical, view: (scene?.view)!)
        horizontalLine = TouchDivisor(of: .horizontal, view: (scene?.view)!)
        
        addChild(verticalLine)
        addChild(horizontalLine)
        addChild(line)
        addChild(beatCounterLabel)
        addChild(accuracyLabel)
    }
    
    func showDivisorLines() {
        verticalLine.isHidden = false
        horizontalLine.isHidden = false
    }
    
    func hideDivisorLines() {
        verticalLine.isHidden = true
        horizontalLine.isHidden = true
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
            print("Player duration: \(String(describing: player?.duration))")
            players.append(player)
        }
    }
    
    func startPlaying() {
        
        unmutePlayerForCurrentWheel()
        
        for player in players {
            player?.play()
        }
        
        isStarted = true
        playerInteraction.isEnabled = true
        
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
            
            for beat in correctBeats {
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
    
    func addNewBeat(kind: BeatType) {
        guard
            wheelCounter < currentLevel.wheels.count,
            beatsCounter < currentLevel.numberOfAllBeats(for: wheelCounter) else {
                return
        }
        
        guard players.count > 0, let player = players[0] else {
            return
        }
        
        let newBeat = SKShapeNode(circleOfRadius: config.beatRadius)
        newBeat.position = beatNode.position
        newBeat.zPosition = 30
        
        var beatColor: UIColor = UIColor(named: "Yellow") ?? .yellow // configure from level color
        
        let currentAngle = CGFloat(player.currentTime / player.duration * 360)
        let sector = helper.getSector(for: currentAngle, config: config)
        let currentPosition = sector / 360
        
        if playWheelState == .initial {
            print("STARTED POSITION: \(currentPosition)")
            playWheelState = .started(position: currentPosition)
            sectorsCounter = config.numberOfSectors
        }
        
        var isCorrect = false
        for beat in currentLevel.allBeats(for: wheelCounter) {
            if beat.position == Float(currentPosition) && beat.kind == kind {
                isCorrect = true
            }
        }
        
        if !isCorrect {
            beatColor = config.wheelColor
        } else {
            correctBeats.append(newBeat)
        }
        
        if usedSectorsForCurrentWheel.contains(sector) {
            print("=== beats overlay ===")
            beatColor = beatColor.withAlphaComponent(0.4)
        }
        usedSectorsForCurrentWheel.append(sector)
        
        switch kind {
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
    }
    
    func addNodeToAnimateCorrectBeats() {
        
        testNode = SKShapeNode(circleOfRadius: config.beatRadius)
        testNode.strokeColor = .clear
        testNode.position = CGPoint(x: 0, y: config.pathRadius)
        
        addChild(testNode)
        testNode.run(circleRepeatAction)
    }
    
    func createAndCheckTouch(_ type: BeatType) {
        guard
            wheelCounter < currentLevel.wheels.count,
            beatsCounter < currentLevel.numberOfAllBeats(for: wheelCounter) else {
                return
        }
        
        guard players.count > 0, let player = players[0] else {
            return
        }
        
        let touch = Touch(position: logics.timeToPosition(player.currentTime, duration: player.duration), type: type)
        let beats = currentLevel.allBeats(for: wheelCounter)
        
        beatsLeft -= 1
        beatCounterLabel.text = "\(beatsLeft)"
        
        if player.isPlaying {
            let touchOutput = logics.checkTouchPosition(touch: touch, beats: beats)
            switch touchOutput {
            case .right(let accuracy):
                print("================ Accuracy of Touch: \(accuracy) ================")
                
                if accuracy >= 95 {
                    accuracyLabel.text = "Perfect!"
                } else if accuracy >= 80 {
                    accuracyLabel.text = "Great!"
                } else if accuracy >= 50 {
                    accuracyLabel.text = "Cool!"
                } else {
                    accuracyLabel.text = "Bad!"
                }
                totalAccuracy = totalAccuracy + accuracy
            case .outRange, .doubleFail:
                accuracyLabel.text = "OUT!"
            case .wrongTouch:
                accuracyLabel.text = "WRONG!"
            }
        }
        
        
    }
    
    func playerWheelFinished() {
        
        print("CURRENT WHEEL FINISHED!!!")
        
        playWheelState = .finished
//        playerInteraction.isEnabled = false
        sectorsCounter = -1
        prevSector = -1
        
        circleFinished()
    }
    
    func circleFinished() {
        
        print("CIRCLE FINISHED!!!")
        guard
            (wheelCounter < currentLevel.wheels.count &&
            beatsCounter >= currentLevel.numberOfAllBeats(for: wheelCounter)) ||
            playWheelState == .finished else {
                return
        }
        
        if playWheelState == .finished {
            playWheelState = .initial
//            playerInteraction.isEnabled = true
        }
        
        let numberOfBeats = currentLevel.numberOfAllBeats(for: wheelCounter)
        let accuracy = logics.calculateAverage(totalAccuracy: totalAccuracy, numberOfBeats: numberOfBeats)
        
        currentLevel.wheels[wheelCounter].accuracy = accuracy
        totalAccuracy = 0
        wheelCounter += 1
        usedSectorsForCurrentWheel = []
        
        if wheelCounter < currentLevel.wheels.count {
            beatsLeft = currentLevel.numberOfAllBeats(for: wheelCounter)
            beatCounterLabel.text = "\(beatsLeft)"
        } else {
            accuracyLabel.text = ""
        }
        
        beatsCounter = 0
        
        guard wheelCounter < currentLevel.wheels.count else {
            
            beatNode.removeFromParent()
//            pausePlayers()
            print("finish level")
            addNodeToAnimateCorrectBeats()
            
            accuracyLabel.isHidden = true
            
            // MARK: - calculate general accuracy (Eduardo) and save results (Marco)
            let finalAccuracy = logics.calculateWheelsAverage(wheels: currentLevel.wheels)
            let highscore = logics.getHighscore(levelId: currentLevel.id, worldId: currentWorldID)
            
            let highscoreMessage = logics.highscoreMessage(newScore: finalAccuracy, oldScore: highscore)
            let (mainMessage, accuracyMessage) = logics.passMessage(newScore: finalAccuracy)
            
            var buttonKinds: [PopUpButtonKind] = []
            
            if finalAccuracy > highscore {
                logics.saveLevelAccuracy(accuracy: finalAccuracy, worldId: currentWorldID, levelId: currentLevel.id)
            }
            
            if logics.didPass(accuracy: finalAccuracy) {
                buttonKinds = [.restart, .levels, .next]
            } else {
                buttonKinds = [.restart, .levels]
            }
            
            levelVC.showPopUp(messages: [mainMessage, highscoreMessage, accuracyMessage], buttons: buttonKinds)
            
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

extension GameScene {
    
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

// MARK: - PlayerInteractionDelegate

extension GameScene: PlayerInteractionDelegate {
    
    func didPutBeatOfType(_ type: BeatType) {
        
        createAndCheckTouch(type)
        addNewBeat(kind: type)
        
        guard wheelCounter < currentLevel.wheels.count else {
            return
        }
        
        if beatsCounter >= currentLevel.numberOfAllBeats(for: wheelCounter) {
            print("number of wheel beats is reached!")
        }
    }
}

// MARK: - AVAudioPlayerDelegate

extension GameScene: AVAudioPlayerDelegate {
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        print("audioPlayerDidFinishPlaying successfully: \(flag), current: \(player.currentTime)")
    }
}
