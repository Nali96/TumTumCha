//
//  ButtonWithKind.swift
//  TumTumCha
//
//  Created by Eduardo Curupana on 28/05/2019.
//  Copyright © 2019 Apple Academy. All rights reserved.
//

import Foundation
import UIKit

class PopUpButton: UIButton {
    var kind: PopUpButtonKind
    
    required init?(coder aDecoder: NSCoder) {
        self.kind = .next
        
        super.init(coder: aDecoder)
    }
}

enum PopUpButtonKind {
    case levels
    case next
    case restart
    case resume
    case pause
    case exit
    
    var title: String {
        switch self {
        case .levels:
            return "Levels"
        case .next:
            return "Next"
        case .restart:
            return "Restart"
        case .resume:
            return "Resume"
        case .pause:
            return "Pause"
        case .exit:
            return "Exit"
        }
    }
    
    var image: UIImage {
        switch self {
        case .levels:
            return UIImage(named: "Levels")!
        case .next:
            return UIImage(named: "Next")!
        case .restart:
            return UIImage(named: "Restart")!
        case .resume:
            return UIImage(named: "Resume")!
        case .pause:
            return UIImage(named: "Pause")!
        case .exit:
            return UIImage(named: "Exit")!
        }
    }
}

extension UIButton {
    
    func centerVertically(padding: CGFloat = 6.0) {
        guard
            let imageViewSize = self.imageView?.frame.size,
            let titleLabelSize = self.titleLabel?.frame.size else {
                return
        }
        
        let totalHeight = imageViewSize.height + titleLabelSize.height + padding
        
        self.imageEdgeInsets = UIEdgeInsets(
            top: -(totalHeight - imageViewSize.height),
            left: 0.0,
            bottom: 0.0,
            right: -titleLabelSize.width
        )
        
        self.titleEdgeInsets = UIEdgeInsets(
            top: 0.0,
            left: -imageViewSize.width,
            bottom: -(totalHeight - titleLabelSize.height),
            right: 0.0
        )
        
        self.contentEdgeInsets = UIEdgeInsets(
            top: 0.0,
            left: 0.0,
            bottom: titleLabelSize.height,
            right: 0.0
        )
    }
    
}
