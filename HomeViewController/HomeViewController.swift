//
//  HomeViewController.swift
//  TumTumCha
//
//  Created by annalisa tarantino on 24/05/2019.
//  Copyright © 2019 Apple Academy. All rights reserved.
//

import UIKit
import SpriteKit

class HomeViewController: UIViewController {
    
    @IBOutlet var skView: SKView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let scene = HomeScene(size: GameConfiguration().defaultScreenSize)
        scene.backgroundColor = .black
        scene.scaleMode = .aspectFit
        scene.anchorPoint = CGPoint(x: 0.5, y: 0.55)
        
        skView.presentScene(scene)
        skView.ignoresSiblingOrder = true
        
        addSettingsButton()
        
        navigationController?.isNavigationBarHidden = false
        
        navigationController?.navigationBar.isHidden = false
        navigationController?.navigationBar.prefersLargeTitles = false
        navigationController?.navigationBar.barTintColor = .black
        navigationController?.navigationBar.isTranslucent = false
        navigationController?.navigationBar.topItem?.backBarButtonItem?.title = ""
        navigationController?.navigationBar.topItem?.backBarButtonItem?.tintColor = .white
        
        navigationController?.navigationBar.topItem?.title = ""
        navigationController?.navigationBar.tintColor = .white
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == SegueNames.showMain {
            (segue.destination as? LevelsListViewController)?.delegate = self
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
//        (skView.scene as? HomeScene)?.player?.stop()
        performSegue(withIdentifier: SegueNames.showMain, sender: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        (skView.scene as? HomeScene)?.player?.play()
    }
    
    func addSettingsButton() {
        
        let settingsItem = UIBarButtonItem(image: UIImage(named: "GearIcon"), style: .plain, target: self, action: #selector(showSettings))
        navigationItem.rightBarButtonItem = settingsItem
    }
    
    @objc
    func showSettings() {
        performSegue(withIdentifier: SegueNames.showSettings, sender: nil)
    }
}

// MARK: - LevelsListViewControllerDelegate

extension HomeViewController: LevelsListViewControllerDelegate {
    
    func pausePlayer() {
        (skView.scene as? HomeScene)?.player?.pause()
    }
    
//    func resumePlayer() {
//        (skView.scene as? HomeScene)?.player?.play()
//    }
}
