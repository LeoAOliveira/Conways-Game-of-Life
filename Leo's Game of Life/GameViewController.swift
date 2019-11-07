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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        createScene()
        
        createLight()
        
        createCamera()
        
        guard let sceneView = self.view as? SCNView else {
            return
        }
        
        setUpScene(inSceneView: sceneView)
        
        createNextButton(inSceneView: sceneView)
        
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
        sceneView.showsStatistics = true
        sceneView.backgroundColor = UIColor.black
        
        grid = Grid(sceneView: sceneView)
    }
    
    // MARK: - Play button and Timer
    
    func createNextButton(inSceneView sceneView: SCNView) {
        
        let nextButton: UIButton = UIButton(frame: CGRect(x: CGFloat(UIScreen.main.bounds.width - 100), y: CGFloat(50), width: CGFloat(70), height: CGFloat(30)))
        
        nextButton.setTitle("Next", for: .normal)
        
        nextButton.tintColor = UIColor.white
        nextButton.backgroundColor = #colorLiteral(red: 0.1434306978, green: 0.461659897, blue: 0.8090010285, alpha: 1)
        nextButton.layer.cornerRadius = 10.0
        
        sceneView.addSubview(nextButton)
        
        nextButton.addTarget(self, action: #selector(nextButtonPressed), for: .touchUpInside)
    }
    
    @objc func nextButtonPressed(_ sender: UIButton) {
        
        performSegue(withIdentifier: "nextSegue", sender: self)
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
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

        if segue.identifier == "nextSegue"{

            let destination = segue.destination as! ARViewController
            
            guard let gridOfCells = grid?.gridOfCells else {
                return
            }
            
            guard let nextStates = grid?.nextStates else {
                return
            }
            
            destination.gridOfCells = gridOfCells
            destination.nextStates = nextStates
        }
    }

}
