//
//  PlayWheelState.swift
//  TumTumCha
//
//  Created by Alexey Titov on 06/06/2019.
//  Copyright © 2019 Apple Academy. All rights reserved.
//

import UIKit

enum PlayWheelState {
    case initial
    case started(position: CGFloat)
    case finished
}

extension PlayWheelState: Equatable {
    
    static func ==(lhs: PlayWheelState, rhs: PlayWheelState) -> Bool {
        switch (lhs, rhs) {
        case (.initial, .initial):
            return true
        case (.started(let leftPosition), .started(let rightPosition)):
            return leftPosition == rightPosition
        case (.finished, .finished):
            return true
        default:
            return false
        }
    }
}
