//
//  SettingsCell.swift
//  TumTumCha
//
//  Created by Marco Di Fiandra on 05/06/2019.
//  Copyright © 2019 Apple Academy. All rights reserved.
//

import UIKit

protocol SettingsCellDelegate: AnyObject {
    func didSwitchStatusChange(cell: SettingsCell, isOn: Bool)
}

class SettingsCell: UITableViewCell {
    
    weak var delegate: SettingsCellDelegate?
    
    var sectionType: SectionType? {
        didSet{
            guard let sectionType = sectionType else { return }
            textLabel?.text = sectionType.description
            switchControl.isHidden = !sectionType.containsSwitch
            selectionStyle = .none
        }
    }
    
    lazy var switchControl: UISwitch = {
        let switchControl = UISwitch()
        switchControl.isOn = false
        switchControl.onTintColor = UIColor.white
        switchControl.translatesAutoresizingMaskIntoConstraints = false
        switchControl.addTarget(self, action: #selector(switchChangeStatus(_:)), for: .valueChanged)
        return switchControl
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        addSubview(switchControl)
        switchControl.rightAnchor.constraint(equalTo: rightAnchor, constant: -12).isActive = true
        switchControl.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc
    func switchChangeStatus(_ sender: UISwitch) {
        delegate?.didSwitchStatusChange(cell: self, isOn: sender.isOn)
    }
}
