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
    var timer: Timer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        createScene()
        
        createLight()
        
        createCamera()
        
        guard let sceneView = self.view as? SCNView else {
            return
        }
        
        setUpScene(inSceneView: sceneView)
        
        createPlayButton(inSceneView: sceneView)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        sceneView.addGestureRecognizer(tapGesture)
    }
    
    // MARK: - Set up scene
    
    func createScene() {
        
        guard let gameOfLifeScene = SCNScene(named: "art.scnassets/gameOfLife.scn") else {
            return
        }
        
        scene = gameOfLifeScene
    }
    
    func createLight() {
        
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
    }
    
    func createCamera() {
        
        // create and add a camera to the scene
        let cameraNode = SCNNode()
        cameraNode.camera = SCNCamera()
        
        scene.rootNode.addChildNode(cameraNode)
        
        // place the camera
        cameraNode.position = SCNVector3(x: 0, y: 50, z: 0)
        
        let worldOrigin = SCNNode()
        worldOrigin.position = SCNVector3(0.0, 0.0, 0.0)
        
        let constraint = SCNLookAtConstraint(target: worldOrigin)
        
        constraint.isGimbalLockEnabled = true
        cameraNode.constraints = [constraint]
    }
    
    func setUpScene(inSceneView sceneView: SCNView) {
        
        sceneView.scene = scene
        sceneView.allowsCameraControl = true
        sceneView.backgroundColor = UIColor.black
        
        grid = Grid(sceneView: sceneView)
    }
    
    // MARK: - Play button and Timer
    
    func createPlayButton(inSceneView sceneView: SCNView) {
        
        let startButton: UIButton = UIButton(frame: CGRect(x: CGFloat(20), y: CGFloat(50), width: CGFloat(70), height: CGFloat(30)))
        
        startButton.setTitle("Play", for: .normal)
        
        startButton.tintColor = UIColor.white
        startButton.backgroundColor = #colorLiteral(red: 0.02378969267, green: 0.8090010285, blue: 0, alpha: 1)
        startButton.layer.cornerRadius = 10.0
        
        sceneView.addSubview(startButton)
        
        startButton.addTarget(self, action: #selector(playButtonPressed), for: .touchUpInside)
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
        
        guard let sceneView = self.view as? SCNView else {
            return
        }
        sceneView.scene = scene
        
        grid.createGrid(onScene: sceneView, isFirstGeneration: false)
    }
    
    // MARK: - Handle tap on cell
    
    @objc func handleTap(_ gestureRecognize: UIGestureRecognizer) {
        
        // retrieve the SCNView
        guard let sceneView = self.view as? SCNView else {
            return
        }
        
        // check what nodes are tapped
        let p = gestureRecognize.location(in: sceneView)
        let hitResults = sceneView.hitTest(p, options: [:])
        
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
    
    // MARK: - Preferences
    
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
