//
//  LaunchViewController.swift
//  TumTumCha
//
//  Created by Alexey Titov on 27/05/2019.
//  Copyright © 2019 Apple Academy. All rights reserved.
//

import UIKit

class LaunchViewController: UIViewController {
    
    @IBOutlet private var imageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imageView.delegate = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if let gifImage = try? UIImage(gifName: "Launchscreen.gif") {
            imageView.setGifImage(gifImage, manager: .defaultManager, loopCount: 1)
        }
    }
}

// MARK: - SwiftyGifDelegate

extension LaunchViewController: SwiftyGifDelegate {
    
    func gifDidStop(sender: UIImageView) {
        if UserDefaults.standard.bool(forKey: UserDefaultsKeys.isMoreThanFirstLaunch) {
            performSegue(withIdentifier: SegueNames.showHome, sender: nil)
        } else {
            performSegue(withIdentifier: SegueNames.showOnboarding, sender: nil)
        }
    }
}
