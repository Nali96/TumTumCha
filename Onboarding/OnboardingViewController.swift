//
//  OnboardingViewController.swift
//  TumTumCha
//
//  Created by Melania Conte on 27/05/2019.
//  Copyright © 2019 Apple Academy. All rights reserved.
//

import SpriteKit

class OnboardingViewController: UIViewController {
    
    @IBOutlet var skView: SKView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let scene = OnboardingScene(size: GameConfiguration().defaultScreenSize)
        scene.scaleMode = .aspectFit
        scene.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        scene.onboardingDelegate = self
        
        skView.presentScene(scene)
        skView.ignoresSiblingOrder = true
    }
}

// MARK: - OnboardingSceneDelegate

extension OnboardingViewController: OnboardingSceneDelegate {
    
    func didFinishOnboarding() {
        UserDefaults.standard.set(true, forKey: UserDefaultsKeys.isMoreThanFirstLaunch)
        performSegue(withIdentifier: SegueNames.showHome, sender: nil)
    }
}
