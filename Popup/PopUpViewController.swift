//
//  PopUpViewController.swift
//  TumTumCha
//
//  Created by Marco Di Fiandra on 24/05/2019.
//  Copyright © 2019 Apple Academy. All rights reserved.
//

import UIKit
import SpriteKit

protocol PopUpDelegate: AnyObject {
    func didTapResume()
    func didTapRestart()
    func didTapLevels()
    func didTapNext()
}

class PopUpViewController: UIViewController {
    
    weak var delegate: PopUpDelegate?
    
    var labels: [UILabel] = []

    @IBOutlet weak var mainLabel: UILabel!
    @IBOutlet weak var label2: UILabel!
    @IBOutlet weak var label3: UILabel!
    
    var buttons: [PopUpButton] = []
    
    @IBOutlet weak var button1: PopUpButton!
    @IBOutlet weak var button2: PopUpButton!
    @IBOutlet weak var button3: PopUpButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        labels = [mainLabel, label2, label3]
        for label in labels {
            label.isHidden = true
        }
        
        buttons = [button1, button2, button3]
        for button in buttons {
            button.isHidden = true
        }
        
        view.backgroundColor = .black
    }
    
    deinit {
        print("PopUpViewController deinit")
    }
    
    func setLabels(messages: [String]) {
        for (index, message) in messages.enumerated() {
            if index == 0 {
                labels[index].font = UIFont(name: FontName.caviarDreams, size: 40)
            } else {
                labels[index].font = UIFont(name: FontName.caviarDreams, size: 25)
            }
            labels[index].isHidden = false
            labels[index].text = message
        }
    }
    
    func setButtons(buttonsKind: [PopUpButtonKind]) {
        for (index, kind) in buttonsKind.enumerated() {
            buttons[index].isHidden = false
            buttons[index].setTitle(kind.title, for: .normal)
            buttons[index].setImage(kind.image, for: .normal)
            buttons[index].kind = kind
            buttons[index].centerVertically()
            buttons[index].titleLabel?.font = UIFont(name: FontName.caviarDreams, size: 20)
        }
    }
    
    @IBAction func buttonOneTapped(_ sender: UIButton) {
        runButtonAction(button: button1)
    }
    
    @IBAction func buttonTwoTapped(_ sender: Any) {
        runButtonAction(button: button2)
    }
    
    @IBAction func buttonThreeTapped(_ sender: Any) {
        runButtonAction(button: button3)
    }
    
    func runButtonAction(button: PopUpButton) {
        switch button.kind {
        case .levels:
            delegate?.didTapLevels()
        case .next:
            delegate?.didTapNext()
        case .restart:
            delegate?.didTapRestart()
        case .resume:
            delegate?.didTapResume()
        case .pause:
            print("pause")
        case .exit:
            print("exit")
        }
        dismiss(animated: false, completion: nil)
    }
}

