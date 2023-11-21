//
//  TumTumCells.swift
//  TumTumCha test
//
//  Created by Melania Conte on 14/05/2019.
//  Copyright © 2019 Melania Conte. All rights reserved.
//

import Foundation
import UIKit

var label = UILabel()
class TumTumCell: UICollectionViewCell{
    
    var text: UILabel!
    var bg: UIView!
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = .clear
        
        self.bg = UIView()
        bg.translatesAutoresizingMaskIntoConstraints = false
        bg.backgroundColor = .clear
        bg.layer.cornerRadius = 27
        bg.layer.masksToBounds = true
        bg.layer.borderColor = #colorLiteral(red: 0.4039215686, green: 0.4039215686, blue: 0.4039215686, alpha: 1)
        //        bg.layer.borderColor = UIColor.gray.cgColor
        bg.layer.borderWidth = 1
        self.addSubview(bg)
        
        bg.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        bg.topAnchor.constraint(equalTo: topAnchor).isActive = true
        bg.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        bg.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        
        self.text = UILabel()
        text.translatesAutoresizingMaskIntoConstraints = false
        text.textAlignment = .center
        text.textColor = .white
        text.baselineAdjustment = .alignCenters
        text.font = UIFont(name: FontName.caviarDreams, size: 30)
        self.addSubview(text)
        
        text.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        text.topAnchor.constraint(equalTo: topAnchor).isActive = true
        text.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        text.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //    override var contentView: UIView{
    //        self.backgroundView = UIImageView(image: UIImage.init(named: "lvl 1"), highlightedImage: UIImage.init(named: "lvl 1 pressed"))
    ////        label.text = "LABEL"
    ////        self.addSubview(label)
    //        return self
    //    }
}
