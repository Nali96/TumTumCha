//
//  GameHelper.swift
//  TumTumCha
//
//  Created by Alexey Titov on 20/05/2019.
//  Copyright © 2019 Apple Academy. All rights reserved.
//

import SpriteKit

struct GameHelper {
    
    let degreesToRadians = CGFloat.pi / 180
    let radiansToDegrees = 180 / CGFloat.pi
    
    func adjustAngleInDegrees(_ angle: CGFloat) -> CGFloat {
        
        var result = (angle < 0) ? -angle : 360 - angle
        result += 90
        
        return (result > 360) ? result - 360 : result
    }
    
    func translateAngleToHalfCircle(_ angle: CGFloat) -> CGFloat {
        
        var result = -(angle - 90)
        
        if result < -180 {
            result += 360
        }
        
        return result
    }
    
    func getSector(for angle: CGFloat, config: GameConfiguration) -> CGFloat {
        
        var sectors: [CGFloat] = []
        
        for i in 0..<config.numberOfSectors {
            let sector = CGFloat(i) * config.sectorAngle
            sectors.append(sector)
        }
        
        for sector in sectors {
            if ((sector - config.delta)...(sector + config.delta)).contains(angle) {
                return sector
            }
        }
        
        if ((360 - config.delta)...360).contains(angle) {
            return 0
        }
        
        return -1
    }
}
