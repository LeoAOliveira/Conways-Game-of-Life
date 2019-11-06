//
//  GameViewController.swift
//  Leo's Game of Life
//
//  Created by Leonardo Oliveira on 31/10/19.
//  Copyright © 2019 Leonardo Oliveira. All rights reserved.
//

import UIKit
import QuartzCore
import SceneKit

class GameViewController: UIViewController {

    var scene: SCNScene = SCNScene()
    
    var grid: Grid?
    
    var time: Float = 0.00
    var timer: Timer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // create a new scene
        guard let gameOfLifeScene = SCNScene(named: "art.scnassets/gameOfLife.scn") else {
            return
        }
        
        scene = gameOfLifeScene
        
        // create and add a camera to the scene
        let cameraNode = SCNNode()
        cameraNode.camera = SCNCamera()
        
        scene.rootNode.addChildNode(cameraNode)
        
        // place the camera
        cameraNode.position = SCNVector3(x: 0, y: 50, z: 0)
        
        // create and add a light to the scene
        let lightNode = SCNNode()
        lightNode.light = SCNLight()
        lightNode.light!.type = .omni
        lightNode.position = SCNVector3(x: 0, y: 10, z: 10)
        scene.rootNode.addChildNode(lightNode)
        
        // create and add an ambient light to the scene
        let ambientLightNode = SCNNode()
        ambientLightNode.light = SCNLight()
        ambientLightNode.light!.type = .ambient
        ambientLightNode.light!.color = UIColor.darkGray
        scene.rootNode.addChildNode(ambientLightNode)
        
        // retrieve the ship node
        // let ship = scene.rootNode.childNode(withName: "box", recursively: true)!
        
        let worldOrigin = SCNNode()
        worldOrigin.position = SCNVector3(0.0, 0.0, 0.0)
        
        let constraint = SCNLookAtConstraint(target: worldOrigin)
        
        constraint.isGimbalLockEnabled = true
        cameraNode.constraints = [constraint]
        
        // animate the 3d object
        // ship.runAction(SCNAction.repeatForever(SCNAction.rotateBy(x: 0, y: 2, z: 0, duration: 1)))
        
        // retrieve the SCNView
        guard let scnView = self.view as? SCNView else {
            return
        }
        
        // set the scene to the view
        scnView.scene = scene
        
        // allows the user to manipulate the camera
        scnView.allowsCameraControl = true
        
        // show statistics such as fps and timing information
        scnView.showsStatistics = true
        
        // configure the view
        scnView.backgroundColor = UIColor.black
        
        grid = Grid(sceneView: scnView)
        
        let startButton: UIButton = UIButton(frame: CGRect(x: CGFloat(20), y: CGFloat(50), width: CGFloat(70), height: CGFloat(30)))
        
        startButton.setTitle("Play", for: .normal)
        
        startButton.tintColor = UIColor.white
        startButton.backgroundColor = #colorLiteral(red: 0.02378969267, green: 0.8090010285, blue: 0, alpha: 1)
        startButton.layer.cornerRadius = 10.0
        
        scnView.addSubview(startButton)
        
        startButton.addTarget(self, action: #selector(playButtonPressed), for: .touchUpInside)
        
        // add a tap gesture recognizer
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        scnView.addGestureRecognizer(tapGesture)
    }
    
    @objc func playButtonPressed(_ sender: UIButton) {
        
        if sender.titleLabel?.text == "Play" {
            
            sender.setTitle("Stop", for: .normal)
            sender.backgroundColor = #colorLiteral(red: 0.8720628619, green: 0, blue: 0, alpha: 1)
            
            timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(counter), userInfo: nil, repeats: true)
        
        } else {
            
            sender.setTitle("Play", for: .normal)
            sender.backgroundColor = #colorLiteral(red: 0.02378969267, green: 0.8090010285, blue: 0, alpha: 1)
            
            timer?.invalidate()
        }
    }
    
    @objc func counter() {
        
        guard let grid = self.grid else {
            return
        }
        
        guard let scnView = self.view as? SCNView else {
            return
        }
        scnView.scene = scene
        
        grid.createGrid(onScene: scnView, isFirstGeneration: false)
    }
    
    @objc
    func handleTap(_ gestureRecognize: UIGestureRecognizer) {
        // retrieve the SCNView
        let scnView = self.view as! SCNView
        
        // check what nodes are tapped
        let p = gestureRecognize.location(in: scnView)
        let hitResults = scnView.hitTest(p, options: [:])
        // check that we clicked on at least one object
        if hitResults.count > 0 {
            // retrieved the first clicked object
            let result = hitResults[0]
            
            guard let selectedCell = result.node as? Cell else {
                return
            }
            
            selectedCell.changeState()
        }
    }
    
    override var shouldAutorotate: Bool {
        return true
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return .allButUpsideDown
        } else {
            return .all
        }
    }

}
