//
//  HomeScene.swift
//  TumTumCha
//
//  Created by annalisa tarantino on 24/05/2019.
//  Copyright © 2019 Apple Academy. All rights reserved.
//

import SpriteKit
import AVFoundation

class HomeScene: SKScene{
    
    var player: AVAudioPlayer?
    
    var title: SKLabelNode!
    var playButton: SKLabelNode!
    
    var movingBeatNode: SKShapeNode!
    var allBeats: [SKShapeNode] = []
    
    let helper = GameHelper()
    let config = GameConfiguration()
    let circleDuration: TimeInterval = 3
    
    override func sceneDidLoad() {
        super.sceneDidLoad()
        guard let url = Bundle.main.url(forResource: "HOME JINGLE", withExtension: "mp3") else { print("audio not found")
            return }
        do{
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
            
            player = try AVAudioPlayer(contentsOf: url, fileTypeHint: AVFileType.mp3.rawValue)
            
            guard let player = player else{return}
            player.numberOfLoops = -1
            player.volume = 0.5
            player.play()
            
        }catch let error{
            print(error.localizedDescription)
        }
    }
    
    override func didMove(to view: SKView) {
        
        title = SKLabelNode(text: "Rhitme")
        title.fontName = FontName.caviarDreams
        title.fontSize = 34
        title.position = CGPoint(x: 0, y: 200)
        addChild(title)
        
        playButton = SKLabelNode(text: "Start")
        playButton.fontName = FontName.caviarDreams
        playButton.fontSize = 24
        playButton.position = CGPoint(x: 0, y: -200)
        addChild(playButton)
        
        let externalRadius = config.homePathRadius
        let middleRadius = config.homePathRadius - (3 * config.beatRadius)
        let internalRadius = config.homePathRadius - (6 * config.beatRadius)
        
        // external circle
        
        let externalPath = createCirclePath(with: externalRadius)
        let externalPathNode = SKShapeNode(path: externalPath)
        externalPathNode.strokeColor = #colorLiteral(red: 0.2549019754, green: 0.2549019754, blue: 0.2549019754, alpha: 1)
        addChild(externalPathNode)
        
        // middle circle
        
        let middlePath = createCirclePath(with: middleRadius)
        let middlePathNode = SKShapeNode(path: middlePath)
        middlePathNode.strokeColor = #colorLiteral(red: 0.2549019754, green: 0.2549019754, blue: 0.2549019754, alpha: 1)
        addChild(middlePathNode)
        
        // internal circle
        
        let internalPath = createCirclePath(with: internalRadius)
        let internalPathNode = SKShapeNode(path: internalPath)
        internalPathNode.strokeColor = #colorLiteral(red: 0.2549019754, green: 0.2549019754, blue: 0.2549019754, alpha: 1)
        addChild(internalPathNode)
        
        // create moving beat
        
        movingBeatNode = SKShapeNode(circleOfRadius: config.beatRadius)
        movingBeatNode.fillColor = .clear
        movingBeatNode.strokeColor = .clear
        movingBeatNode.position = CGPoint(x: 0, y: config.pathRadius)
        addChild(movingBeatNode)
        
        // beats
        
        let beat1 = createBeat(kind: .secondary)
        beat1.position = positionForSector(315, radius: middleRadius)
        beat1.setScale(0.8)
        allBeats.append(beat1)
        addChild(beat1)
        
        let beat2 = createBeat(kind: .secondary)
        beat2.position = positionForSector(45, radius: middleRadius)
        beat2.setScale(0.8)
        allBeats.append(beat2)
        addChild(beat2)
        
        let beat3 = createBeat(kind: .main)
        beat3.position = positionForSector(180, radius: middleRadius)
        beat3.setScale(0.8)
        allBeats.append(beat3)
        addChild(beat3)
        
        let beat4 = createBeat(kind: .secondary)
        beat4.position = positionForSector(225, radius: middleRadius)
        beat4.setScale(0.8)
        allBeats.append(beat4)
        addChild(beat4)
        
        let beat5 = createBeat(kind: .main)
        beat5.position = positionForSector(0, radius: externalRadius)
        allBeats.append(beat5)
        addChild(beat5)
        
        let beat6 = createBeat(kind: .main)
        beat6.position = positionForSector(90, radius: externalRadius)
        allBeats.append(beat6)
        addChild(beat6)
        
        let beat7 = createBeat(kind: .main)
        beat7.position = positionForSector(180, radius: internalRadius)
        beat7.setScale(0.6)
        allBeats.append(beat7)
        addChild(beat7)
        
        let beat8 = createBeat(kind: .main)
        beat8.position = positionForSector(90, radius: internalRadius)
        beat8.setScale(0.6)
        allBeats.append(beat8)
        addChild(beat8)
        
        let beat9 = createBeat(kind: .main)
        beat9.position = positionForSector(270, radius: internalRadius)
        beat9.setScale(0.6)
        allBeats.append(beat9)
        addChild(beat9)
        
        let beat10 = createBeat(kind: .main)
        beat10.position = positionForSector(0, radius: internalRadius)
        beat10.setScale(0.6)
        allBeats.append(beat10)
        addChild(beat10)
        
        let beat11 = createBeat(kind: .secondary)
        beat11.position = positionForSector(135, radius: middleRadius)
        beat11.setScale(0.8)
        allBeats.append(beat11)
        addChild(beat11)
        
        let beat12 = createBeat(kind: .main)
        beat12.position = positionForSector(0, radius: middleRadius)
        beat12.setScale(0.8)
        allBeats.append(beat12)
        addChild(beat12)
        
        let beat13 = createBeat(kind: .main)
        beat13.position = positionForSector(90, radius: middleRadius)
        beat13.setScale(0.8)
        allBeats.append(beat13)
        addChild(beat13)
        
        let beat14 = createBeat(kind: .main)
        beat14.position = positionForSector(270, radius: middleRadius)
        beat14.setScale(0.8)
        allBeats.append(beat14)
        addChild(beat14)
        
        let beat15 = createBeat(kind: .main)
        beat15.position = positionForSector(180, radius: externalRadius)
        allBeats.append(beat15)
        addChild(beat15)
        
        let beat16 = createBeat(kind: .main)
        beat16.position = positionForSector(270, radius: externalRadius)
        allBeats.append(beat16)
        addChild(beat16)
        
        let beat17 = createBeat(kind: .secondary)
        beat17.position = positionForSector(45, radius: externalRadius)
        allBeats.append(beat17)
        addChild(beat17)
        
        let beat18 = createBeat(kind: .secondary)
        beat18.position = positionForSector(135, radius: externalRadius)
        allBeats.append(beat18)
        addChild(beat18)
        
        let beat19 = createBeat(kind: .secondary)
        beat19.position = positionForSector(225, radius: externalRadius)
        allBeats.append(beat19)
        addChild(beat19)
        
        let beat20 = createBeat(kind: .secondary)
        beat20.position = positionForSector(315, radius: externalRadius)
        allBeats.append(beat20)
        addChild(beat20)
        
        let beat21 = createBeat(kind: .off)
        beat21.position = positionForSector(22.5, radius: externalRadius)
        allBeats.append(beat21)
        addChild(beat21)
        
        let beat22 = createBeat(kind: .off)
        beat22.position = positionForSector(112.5, radius: externalRadius)
        allBeats.append(beat22)
        addChild(beat22)
        // animation
        
        let followAction = SKAction.follow(externalPath, asOffset: false, orientToPath: false, duration: circleDuration)
        let circleRepeatAction = SKAction.repeatForever(followAction)
        movingBeatNode.run(circleRepeatAction)
        
    }
    
    override func update(_ currentTime: TimeInterval) {
        animateAllBeats()
    }
}

// MARK: - Private methods

extension HomeScene {
    
    func createCirclePath(with radius: CGFloat) -> CGPath {
        
        let path = CGMutablePath()
        
        path.addArc(center: .zero, radius: radius, startAngle: 0.5 * CGFloat.pi, endAngle: 1.5 * CGFloat.pi, clockwise: true)
        path.addArc(center: .zero, radius: radius, startAngle: 1.5 * CGFloat.pi, endAngle: 0.5 * CGFloat.pi, clockwise: true)
        
        return path
    }
    
    func createBeat(kind: BeatType) -> SKShapeNode {
        
        let newBeat = SKShapeNode(circleOfRadius: config.beatRadius)
        let beatColor: UIColor = .white
        
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
        
        return newBeat
    }
    
    func positionForSector(_ sectorInDegrees: CGFloat, radius: CGFloat) -> CGPoint {
        
        let newAngle = helper.translateAngleToHalfCircle(sectorInDegrees)
        let x = radius * cos(newAngle * helper.degreesToRadians)
        let y = radius * sin(newAngle * helper.degreesToRadians)
        let position = CGPoint(x: x, y: y)
        
        return position
    }
    
    func animateAllBeats() {
        
        let testAngle = atan2(movingBeatNode.position.y, movingBeatNode.position.x)
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
