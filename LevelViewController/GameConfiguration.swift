//
//  GameConfiguration.swift
//  TumTumCha
//
//  Created by Alexey Titov on 20/05/2019.
//  Copyright © 2019 Apple Academy. All rights reserved.
//

import SpriteKit

struct GameConfiguration {
    
    var homePathRadius: CGFloat = 120
    var pathRadius: CGFloat = 120
    var pathPadding: CGFloat = 50
    var beatRadius: CGFloat = 12
    var numberOfSectors: Int = 16
    var numberOfLoops = 0
    
    var movingBeatColor: UIColor = .white
    var wheelColor: UIColor = UIColor(named: "Gray") ?? .gray
    var wheelWidth: CGFloat = 2
    
    var defaultScreenSize = CGSize(width: 375, height: 667)
    
    var sectorAngle: CGFloat {
        return 360 / CGFloat(numberOfSectors)
    }
    
    var delta: CGFloat {
        return sectorAngle / 2
    }
}
