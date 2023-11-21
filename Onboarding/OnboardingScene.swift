//
//  GameScene.swift
//  Onboarding
//
//  Created by Melania Conte on 24/05/2019.
//  Copyright © 2019 Melania Conte. All rights reserved.
//

import SpriteKit
import GameplayKit

protocol OnboardingSceneDelegate: AnyObject {
    func didFinishOnboarding()
}

class OnboardingScene: SKScene {
    
    weak var onboardingDelegate: OnboardingSceneDelegate?

    private var pointers: [SKSpriteNode]?
    private var mainBeat: OnboardingElement!
    private var count: Int!
    private var desc: OnboardingLabel!
    private var ring: OnboardingElement!
    
    override func didMove(to view: SKView) {
        self.backgroundColor = .black
        self.isUserInteractionEnabled = false
        self.count = 5
        loadHeadphones()
    }
    
    func loadHeadphones(){
        let headphones = OnboardingElement(of: .headphones)
        self.addChild(headphones)
        headphones.run(.fadeIn(withDuration: 2))
        let lable = OnboardingLabel(of: .desc, position: CGPoint(x: 0, y: -headphones.frame.size.height*2 - 100), text: "Use your headphones\nfor better experience.")
        self.addChild(lable)
        lable.run(SKAction.sequence([.fadeIn(withDuration: 2), .wait(forDuration: 6)]), completion: {
            self.onboardingDelegate?.didFinishOnboarding()
        })
    }
    
    func loadOnboarding(){
        loadRing()
        
        let title = OnboardingLabel(of: .title, position: CGPoint(x: ((self.ring?.frame.origin.x)! + (self.ring?.frame.size.width)!/2), y: (self.ring?.frame.maxY)! + 200), text: String("Welcome to Rhitme"))
        self.addChild(title)
        title.showOnboardingLabel(of: .title, duration: 1)
        
        desc = OnboardingLabel(of: .desc, position: CGPoint(x: (self.ring?.frame.origin.x)! + ((self.ring?.frame.size.width)!/2), y: (self.ring?.frame.minY)! - 250), text: String("This is a loop ring"))
        self.addChild(desc)
        desc.showOnboardingLabel(of: .desc, duration: 3)
        
        self.isUserInteractionEnabled = true
    }
    
    func loadRing(){
        ring = OnboardingElement(of: .firstLoopRing)
        self.addChild(ring)
        ring.run(.fadeIn(withDuration: 3), completion: {
            self.ring.run(.wait(forDuration: 2))
        })
    }
    
    func loadMainBeat(){
        self.isUserInteractionEnabled = false
        mainBeat = OnboardingElement(of: .mainBeat)
        self.addChild(mainBeat)
        mainBeat?.run(.fadeIn(withDuration: 2), completion: {
            self.mainBeat?.run(.wait(forDuration: 2))
            self.isUserInteractionEnabled = true
        })
    }
    
    func loadPointers(){
        self.pointers = [SKSpriteNode(imageNamed: "Pointer"), SKSpriteNode(imageNamed: "Pointer2")]
        self.pointers?[0].position = CGPoint(x: self.frame.width/4, y: -300)
        self.pointers?[0].size = CGSize(width: (self.pointers?[0].size.width)! * 0.15, height: (self.pointers?[0].size.height)! * 0.15)
        self.addChild(pointers![0])
        let circleNode = SKSpriteNode()
        circleNode.anchorPoint = (self.pointers?[0].frame.origin)!
        let circle = SKShapeNode(circleOfRadius: 20)
        circle.fillColor = .gray
        circle.strokeColor = .clear
        self.pointers?[0].addChild(circleNode)
        circleNode.position.x -= 15
        circleNode.position.y += 30
        circleNode.addChild(circle)
    pointers?[0].run(SKAction.repeatForever(SKAction.sequence([SKAction.group([SKAction.scale(by: 0.6, duration: 1), SKAction.fadeOut(withDuration: 1)]), SKAction.group([SKAction.scale(to: 1, duration: 1), SKAction.fadeIn(withDuration: 1)])])))
        
        self.pointers?[1].position = CGPoint(x: -self.frame.width/4, y: -300)
        self.pointers?[1].size = CGSize(width: (self.pointers?[1].size.width)! * 0.15, height: (self.pointers?[1].size.height)! * 0.15)
        self.addChild(pointers![1])
        let circleNode2 = SKSpriteNode()
        circleNode2.anchorPoint = (self.pointers?[1].frame.origin)!
        let circle2 = SKShapeNode(circleOfRadius: 20)
        circle2.fillColor = .gray
        circle2.strokeColor = .clear
        self.pointers?[1].addChild(circleNode2)
        circleNode2.position.x += 15
        circleNode2.position.y += 30
        circleNode2.addChild(circle2)
    pointers?[1].run(SKAction.repeatForever(SKAction.sequence([SKAction.group([SKAction.scale(by: 0.6, duration: 1), SKAction.fadeOut(withDuration: 1)]), SKAction.group([SKAction.scale(to: 1, duration: 1), SKAction.fadeIn(withDuration: 1)])])))
        
        pointers?[1].run(.wait(forDuration: 2), completion: {
            self.isUserInteractionEnabled = true
        })
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        switch count {
        case 5:
            desc.run(.fadeOut(withDuration: 1)) {
                self.desc.text = String("Every loop ring is related\nto an audio loop that will give\nyou the pattern to follow.")
                self.desc.showOnboardingLabel(of: .desc, duration: 2)
            }
            count -= 1
        case 4:
            desc.run(.fadeOut(withDuration: 1)) {
                self.desc.text = String("You can hear the audio loop\nas long as you want.\nWhen you're ready you can\nstart placing the beats.")
                self.desc.showOnboardingLabel(of: .desc, duration: 2)
            }
            count -= 1
        case 3:
            ring.run(.fadeOut(withDuration: 1))
            desc.run(.fadeOut(withDuration: 1)) {
                self.loadMainBeat()
                self.desc.text = String("This is a main beat")
                self.desc.showOnboardingLabel(of: .desc, duration: 2)
            }
            count -= 1
        case 2:
            desc.run(.fadeOut(withDuration: 1)) {
                self.desc.text = String("Tap with both your thumbs\non the two sides of the screen\nto place it whenever you\nhear the kick sound.")
                self.desc.showOnboardingLabel(of: .desc, duration: 2)
                self.loadPointers()
            }
            count -= 1
        case 1:
            desc.run(.fadeOut(withDuration: 1)) {
                self.pointers?[0].run(.fadeOut(withDuration: 1), completion: {
                    self.pointers?[0].removeFromParent()
                })
                self.pointers?[1].run(.fadeOut(withDuration: 1),completion: {
                    self.pointers?[1].removeFromParent()
                })
                self.desc.text = String("Tap to continue.")
                self.desc.showOnboardingLabel(of: .desc, duration: 2)
            }
            count -= 1
        case 0:
            count -= 1
            self.onboardingDelegate?.didFinishOnboarding()
        default:
            print("GameScene")
        }
    }
    
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
    }
}
