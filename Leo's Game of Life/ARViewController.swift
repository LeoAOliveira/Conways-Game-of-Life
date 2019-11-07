//
//  ARViewController.swift
//  Leo's Game of Life
//
//  Created by Leonardo Oliveira on 07/11/19.
//  Copyright © 2019 Leonardo Oliveira. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

class ARViewController: UIViewController, ARSCNViewDelegate {

    @IBOutlet var sceneView: ARSCNView!
    
    var scene: SCNScene = SCNScene()
    var saturnVNode: SCNNode?
    var timer: Timer?
    var grid: Grid?
    var gridOfCells: [Array<Cell>] = []
    var nextStates: [Array<CellStateEnum>] = []
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self
        
        sceneView.autoenablesDefaultLighting = true
        
        guard let saturnVNode = SCNScene(named: "art.scnassets/gameOfLife.scn") else {
            return
        }
        
        sceneView.scene = saturnVNode
        
        createScene()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let configuration = ARWorldTrackingConfiguration()
        
        configuration.planeDetection = [.horizontal]

        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
    
    func createScene() {
        
        guard let gameOfLifeScene = SCNScene(named: "art.scnassets/gameOfLife.scn") else {
            return
        }
        
        scene = gameOfLifeScene
    }
    
    @objc func handleDoor(rec: UITapGestureRecognizer) {
    
        if rec.state == .ended {
            
            let location: CGPoint = rec.location(in: sceneView)
            let hits = self.sceneView.hitTest(location, options: nil)
            
            if !hits.isEmpty {
                
            }
        }
    }

    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {

        let node = SCNNode()

        if let planeAnchor = anchor as? ARPlaneAnchor {

            guard let container = sceneView.scene.rootNode.childNode(withName: "container", recursively: false) else {
                return node
            }
    
            container.removeFromParentNode()
            node.addChildNode(container)
            container.isHidden = false
            
        }

        return node
    }
    
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
    
}


