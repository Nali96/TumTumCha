//
//  OnboardingElement.swift
//  Onboarding
//
//  Created by Melania Conte on 27/05/2019.
//  Copyright © 2019 Melania Conte. All rights reserved.
//

import Foundation
import SpriteKit

enum OnboardingElementType {
    case firstLoopRing
    case mainBeat
    case headphones
    case leftPointer
    case rightPointer
}

class OnboardingElement: SKNode {
    
    var type: OnboardingElementType!
    var config = GameConfiguration()

    init(of type: OnboardingElementType) {
        switch type {
        case .firstLoopRing:
            super.init()
            let path = CGMutablePath()
            let externalRadius = config.homePathRadius
            path.addArc(center: .zero, radius: externalRadius, startAngle: 0.5 * CGFloat.pi, endAngle: 1.5 * CGFloat.pi, clockwise: true)
            path.addArc(center: .zero, radius: externalRadius, startAngle: 1.5 * CGFloat.pi, endAngle: 0.5 * CGFloat.pi, clockwise: true)
            let ring = SKShapeNode(path: path)
            ring.lineWidth = 4
            ring.strokeColor = #colorLiteral(red: 0.2549019754, green: 0.2549019754, blue: 0.2549019754, alpha: 1)
            addChild(ring)
            
        case .mainBeat:
            super.init()
            let path = CGMutablePath()
            let externalRadius = 60
            path.addArc(center: .zero, radius: CGFloat(externalRadius), startAngle: 0.5 * CGFloat.pi, endAngle: 1.5 * CGFloat.pi, clockwise: true)
            path.addArc(center: .zero, radius: CGFloat(externalRadius), startAngle: 1.5 * CGFloat.pi, endAngle: 0.5 * CGFloat.pi, clockwise: true)
            let ring = SKShapeNode(path: path)
            ring.lineWidth = 0
            ring.glowWidth = 130
            ring.fillColor = #colorLiteral(red: 0.968627451, green: 1, blue: 0.3294117647, alpha: 1)
            ring.strokeColor = #colorLiteral(red: 0.968627451, green: 1, blue: 0.3294117647, alpha: 1)
            addChild(ring)
            print("generate mainBeat")
            
        case .headphones:
            super.init()
            let headphones = SKSpriteNode(imageNamed: "Headphones")
            headphones.position = .zero
            headphones.size = .init(width: 80, height: 80)
            addChild(headphones)
            
        case .leftPointer:
            super.init()
            let leftPointer = SKSpriteNode(imageNamed: "Pointer2")
            leftPointer.position.x -= 90
            leftPointer.size = CGSize(width: (leftPointer.size.width) * 0.15, height: (leftPointer.size.height) * 0.15)
            addChild(leftPointer)
            let circleNode = SKSpriteNode()
            circleNode.anchorPoint = (leftPointer.frame.origin)
            let circle = SKShapeNode(circleOfRadius: 20)
            circle.fillColor = .gray
            circle.strokeColor = .clear
            leftPointer.addChild(circleNode)
            circleNode.position.y += 20
            circleNode.position.x += 10
            circleNode.addChild(circle)
            
        case .rightPointer:
            super.init()
            let rightPointer = SKSpriteNode(imageNamed: "Pointer")
            rightPointer.position.x += 90
            rightPointer.size = CGSize(width: (rightPointer.size.width) * 0.15, height: (rightPointer.size.height) * 0.15)
            addChild(rightPointer)
            let circleNode = SKSpriteNode()
            circleNode.anchorPoint = (rightPointer.frame.origin)
            let circle = SKShapeNode(circleOfRadius: 20)
            circle.fillColor = .gray
            circle.strokeColor = .clear
            rightPointer.addChild(circleNode)
            circleNode.position.y += 20
            circleNode.position.x -= 10
            circleNode.addChild(circle)
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
