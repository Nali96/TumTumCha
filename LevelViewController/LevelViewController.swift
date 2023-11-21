//
//  LevelViewController.swift
//  TumTumCha
//
//  Created by Alexey Titov on 19/05/2019.
//  Copyright © 2019 Apple Academy. All rights reserved.
//

import UIKit
import SpriteKit

class LevelViewController: UIViewController {
    
    @IBOutlet var skView: SKView!
    var pauseButton: UIButton!
    var levelLabel: UILabel!
    var elementsStackView: UIStackView!
    
    var currentLevel: Level!
    
//    var scene: SKScene!
    var logics: GameLogics!
    let decoder = LevelsProvider()
    
    var gameMode: GameMode = .normal
    
    var isPaused = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.isHidden = true
        setupElements()
        createScene()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = true
    }
    
    deinit {
        print("LevelViewController deinit")
    }
    
    func createScene() {
        logics = GameLogics()
        
        switch gameMode {
        case .normal:
            let gameScene = GameScene(size: GameConfiguration().defaultScreenSize)
            gameScene.currentLevel = currentLevel
            gameScene.levelVC = self
            gameScene.gameDelegate = self
            gameScene.backgroundColor = .black
            gameScene.scaleMode = .aspectFit
            gameScene.anchorPoint = CGPoint(x: 0.5, y: 0.5)
            
            skView.presentScene(gameScene)
            if pauseButton != nil {
                pauseButton.isEnabled = false
            }
        case .tutorial:
            let tutorialScene = TutorialScene(size: GameConfiguration().defaultScreenSize)
            tutorialScene.currentLevel = currentLevel
            tutorialScene.levelVC = self
            tutorialScene.gameDelegate = self
            tutorialScene.backgroundColor = .black
            tutorialScene.scaleMode = .aspectFit
            tutorialScene.anchorPoint = CGPoint(x: 0.5, y: 0.5)
            
            skView.presentScene(tutorialScene)
        }
        skView.ignoresSiblingOrder = true
    }
    
    func killScene() {
        skView.presentScene(nil)
    }
    
    func setupElements() {
        let buttonSize = CGSize(width: 50, height: 50)
        let buttonPosition = CGPoint(x: view.frame.size.width - buttonSize.width - 10, y: 40)
        
        pauseButton = UIButton(frame: CGRect(origin: buttonPosition, size: buttonSize))
        pauseButton.setImage(PopUpButtonKind.pause.image, for: .normal)
        pauseButton.addTarget(self, action: #selector(pauseButtonAction), for: .touchUpInside)
        pauseButton.isEnabled = false
        
        levelLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 100, height: 30))
        levelLabel.textAlignment = .left
        
        levelLabel.text = "LEVEL \(currentLevel.id)"
        if gameMode == .tutorial {
            levelLabel.text = "TUTORIAL"
        }
        levelLabel.textColor = .white
        levelLabel.font = UIFont(name: FontName.caviarDreams, size: 16)
        
        elementsStackView = UIStackView()
        elementsStackView.axis = .horizontal
        elementsStackView.distribution = .equalSpacing
        elementsStackView.alignment = .fill
        elementsStackView.spacing = self.view.frame.width / 1.5

        elementsStackView.addArrangedSubview(levelLabel)
        elementsStackView.addArrangedSubview(pauseButton)
        elementsStackView.translatesAutoresizingMaskIntoConstraints = false

        skView.addSubview(elementsStackView)

        //Constraints
        elementsStackView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        elementsStackView.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 30).isActive = true
    }
    
    func getMessages() -> [String] {
        var messages: [String] = []
        
        switch gameMode {
        case .normal:
            let scene = skView.scene as! GameScene
            scene.pausePlayers()
            messages = ["Level \(currentLevel.id)"]
            let highscore = logics.getHighscore(levelId: currentLevel.id, worldId: 1)
            if highscore > 0 {
                messages.append("Highscore: \(highscore)%")
            }
        case .tutorial:
            let scene = skView.scene as! TutorialScene
            if !scene.isPlaying() {
                isPaused = true
            }
            scene.pausePlayers()
            messages = ["Tutorial"]
        }
        
        return messages
    }
    
    @objc func pauseButtonAction(sender: UIButton!) {
        showPopUp(messages: getMessages(), buttons: [.restart, .levels, .resume])
    }

    func showPopUp(messages: [String], buttons: [PopUpButtonKind]) {
        
        let popUp = UIStoryboard(name: "Level", bundle: nil).instantiateViewController(withIdentifier: "PopUp") as! PopUpViewController
        
        popUp.delegate = self
        present(popUp, animated: true, completion: nil)
        popUp.setLabels(messages: messages)
        popUp.setButtons(buttonsKind: buttons)
    }
}

// MARK: - GameSceneDelegate

extension LevelViewController: PopUpDelegate {
    func didTapResume() {
        switch gameMode {
        case .normal:
            let scene = skView.scene as! GameScene
            scene.playPlayers()
        case .tutorial:
            let scene = skView.scene as! TutorialScene
            if !isPaused {
                scene.playPlayers()
                isPaused = false
            }
        }
    }
    
    func didTapRestart() {
        killScene()
        createScene()
    }
    
    func didTapLevels() {
        killScene()
        navigationController?.popViewController(animated: false)
    }
    
    func didTapNext() {
        if let nextLevel = decoder.getLevelById(id: currentLevel.id + 1, worldFileName: JSONFiles.worldOne) {
            currentLevel = nextLevel
            if currentLevel.isTutorial {
                gameMode = .tutorial
                levelLabel.text = "Tutorial"
            } else {
                gameMode = .normal
                levelLabel.text = "Level \(currentLevel.id)"
            }
            killScene()
            createScene()
        } else {
            killScene()
            navigationController?.popViewController(animated: false)
        }
    }
}

extension LevelViewController: GameSceneDelegate {
    
    func didStartPlaying() {
        pauseButton.isEnabled = true
    }
}

enum GameMode {
    case tutorial
    case normal
}
