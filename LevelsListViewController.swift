//
//  LevelViewController.swift
//  TumTumCha test
//
//  Created by Melania Conte on 14/05/2019.
//  Copyright © 2019 Melania Conte. All rights reserved.
//

import Foundation
import UIKit

protocol LevelsListViewControllerDelegate: AnyObject {
    func pausePlayer()
//    func resumePlayer()
}

class LevelsListViewController: UICollectionViewController {
    
    var currentWorld = 1
    var decoder = LevelsProvider()
    var levels: [Level] = []
    var worldFileName = JSONFiles.worldOne
    let fakeCellsNumber = 10
    
    weak var delegate: LevelsListViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        levels = decoder.getAllLevelFromWorld(worldFileName: JSONFiles.worldOne)
        
        collectionView.backgroundColor = .black
        
        collectionView.collectionViewLayout = getLayout()
        collectionView.register(TumTumCell.self, forCellWithReuseIdentifier: "cell")
        
        collectionView.register(UICollectionReusableView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "header")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.navigationBar.isHidden = false
//        delegate?.resumePlayer()
        collectionView.reloadData()
    }
    
    deinit {
        print("LevelsListViewController deinit")
    }
    
    func getLevels(fileName: String) -> [Level] {
        var levels: [Level] = []
        if let world = decoder.getWorldFromJSON(filename: fileName) as World? {
            for path in world.levelPaths {
                if let level = decoder.getLevelFromJSON(filename: path) as Level? {
                    levels.append(level)
                }
            }
        }
        return levels
    }
    
    func getNumberOfLevelsUnlocked() -> Int {
        let dataManager = SaveDataManager()
        let accuracies = dataManager.loadData(idWorld: String(currentWorld)) as! [Accuracy]
        
        guard let lastRecord = accuracies.last else {
            return 1
        }
        
        if lastRecord.accuracy < 50 {
            return accuracies.count
        } else {
            return accuracies.count + 1
        }
    }
    
    func getHeader(indexPath: IndexPath, title: String)  -> UICollectionReusableView {
        let view = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "header", for: indexPath)
        view.backgroundColor = .clear
        
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .white
        label.text = title
        label.textAlignment = .center
        
        label.font = UIFont(name: FontName.caviarDreams, size: 42)
        view .addSubview(label)
        
        label.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        label.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        label.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        label.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        label.trailingAnchor.constraint(equalToSystemSpacingAfter: view.trailingAnchor, multiplier: -90)
        
        return view
    }
    
    func getLayout() -> UICollectionViewFlowLayout {
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: 54, height: 54)
        layout.minimumLineSpacing = 40
        layout.minimumInteritemSpacing = 40
        layout.sectionInset = UIEdgeInsets(top: 39, left: 39, bottom: 0, right: 39)
        return layout
    }
}

extension LevelsListViewController {
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        return getHeader(indexPath: indexPath, title: "Levels")
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        delegate?.pausePlayer()
        guard indexPath.row <  levels.count else {
            let alert = UIAlertController(title: "Coming soon!", message: "We've been working hard to make more levels for you!", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            return
        }
        
        if indexPath.row < getNumberOfLevelsUnlocked() {
            let storyboard = UIStoryboard(name: "Level", bundle: nil)
            let levelVC = storyboard.instantiateViewController(withIdentifier: "LevelViewController") as! LevelViewController
            
            let levelSelected = levels[indexPath.row]
            
            if levelSelected.isTutorial {
                if indexPath.row == getNumberOfLevelsUnlocked() - 1 {
                    levelVC.gameMode = .tutorial
                } else {
                    levelVC.gameMode = .normal
                }
            } else {
                levelVC.gameMode = .normal
            }
            levelVC.currentLevel = levelSelected
            
            navigationController?.pushViewController(levelVC, animated: false)
        } else {
            print("LEVEL LOCKED!!!")
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return levels.count + fakeCellsNumber
    }
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! TumTumCell
        
        cell.text.text = "\(indexPath.row + 1)"
        
        if indexPath.row >= getNumberOfLevelsUnlocked() || indexPath.row >= levels.count {
            cell.alpha = 0.5
        }
        
        return cell
    }
}

extension LevelsListViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: 1000, height: 200)
    }
}
