//
//  TouchDivisor.swift
//  TumTumCha
//
//  Created by Eduardo Curupana on 07/06/2019.
//  Copyright © 2019 Apple Academy. All rights reserved.
//

import Foundation
import SpriteKit

class TouchDivisor: SKNode {
    
    var type: TouchDivisorType!
    var screenSize: Int!
    let config = GameConfiguration()
    
    init(of type: TouchDivisorType, view: UIView) {
        let y = (view.frame.height - (((Multipliers.singleTapMultiplier * 100) * view.frame.height) / 100)) * -1
        
        switch type {
        case .vertical:
            super.init()
            var p1 = CGPoint(x: 0, y: config.pathRadius * -1)
            var p2 = CGPoint(x: 0, y: y)
            addChild(getDottedLine(from: p1, to: p2))
            
            p1 = CGPoint(x: 0, y: view.frame.width)
            p2 = CGPoint(x: 0, y: config.pathRadius)
            addChild(getDottedLine(from: p1, to: p2))
        case .horizontal:
            super.init()
            let p1 = CGPoint(x: -(view.frame.width / 2), y: y)
            let p2 = CGPoint(x: view.frame.width / 2, y: y)
            addChild(getDottedLine(from: p1, to: p2))
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func getDottedLine(from point1: CGPoint, to point2: CGPoint) -> SKShapeNode {
        let linePath = UIBezierPath()
        linePath.move(to: point1)
        linePath.addLine(to: point2)
        
        let pattern: [CGFloat] = [10.0, 10.0]
        let dashed = SKShapeNode(path: linePath.cgPath.copy(dashingWithPhase: 2, lengths: pattern))
        
        dashed.strokeColor = #colorLiteral(red: 0.4039215686, green: 0.4039215686, blue: 0.4039215686, alpha: 1)
        
        return dashed
    }
}

enum TouchDivisorType {
    case vertical
    case horizontal
}
