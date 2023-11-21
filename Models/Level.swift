//
//  Level.swift
//  Wheel Logics
//
//  Created by Eduardo Curupana on 14/05/2019.
//  Copyright © 2019 Eduardo Curupana. All rights reserved.
//

import Foundation

struct Level: Decodable {
    var id: Int
    var wheels: [Wheel]
    var duration: TimeInterval
    var average: Int = 0
    var isTutorial: Bool = false
    var tutorial: Tutorial?
    
    func numberOfAllBeats(for wheel: Int) -> Int {
        var totalBeats = 0
        for i in 0 ... wheel {
            totalBeats += wheels[i].beats.count
        }
        return totalBeats
    }
    
    func allBeats(for wheel: Int) -> [Beat] {
        var beats: [Beat] = []
        for i in 0 ... wheel {
            beats.append(contentsOf: wheels[i].beats)
        }
        return beats
    }
}
