//
//  OnboardingLabel.swift
//
//  Created by Melania Conte on 27/05/2019.
//  Copyright © 2019 Melania Conte. All rights reserved.
//

import Foundation
import SpriteKit

enum OnboardingLabelType{
    case title
    case desc
}

class OnboardingLabel: SKLabelNode {
    
    var type: OnboardingLabel!
    
    init(of type: OnboardingLabelType, position: CGPoint, text: String){
        
        switch type {
        case .title:
            super.init()
            self.text = text
            self.fontName = FontName.caviarDreams
            self.fontSize = 34
            self.position = position
            self.fontColor = .white
            self.alpha = 0
        case .desc:
            super.init()
            self.text = text
            self.numberOfLines = 4
            self.verticalAlignmentMode = .center
            self.horizontalAlignmentMode = .center
            self.fontName = FontName.caviarDreams
            self.fontColor = .white
            self.position = position
            self.fontSize = 20
            self.alpha = 0
        }
    }
    
    func showOnboardingLabel(of type: OnboardingLabelType, duration: TimeInterval){
        switch type {
        case .title:
            self.run(.fadeIn(withDuration: 2))
        case .desc:
            self.run(.fadeIn(withDuration: 1))
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
